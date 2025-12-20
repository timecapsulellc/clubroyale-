/**
 * Recommendation Agent
 * 4D Personalization: Time, Mood, Social, Skill
 */

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { createLogger } from '../../utils/logger';
import { BusinessMetrics } from '../../utils/metrics';

const logger = createLogger('recommendationAgent');

// Initialize Genkit
const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// ============================================
// Types
// ============================================

interface UserContext {
    userId: string;
    currentTime: string; // ISO string
    timezone: string;
    recentGames: string[]; // Last 5 game types played
    friendsOnline: string[]; // User IDs of online friends
    skillLevel: Record<string, number>; // Game type -> ELO
    sessionDuration: number; // Minutes in current session
    lastActivity: string;
    preferences?: {
        favoriteGames?: string[];
        preferredPlayerCount?: number;
        avoidGames?: string[];
    };
}

interface GameRecommendation {
    gameType: string;
    score: number;
    reasoning: string;
    suggestedMode: 'quick_play' | 'with_friends' | 'tournament' | 'practice';
    estimatedDuration: number; // minutes
}

interface FriendRecommendation {
    userId: string;
    displayName: string;
    score: number;
    reasoning: string;
    sharedInterests: string[];
    suggestedActivity: string;
}

interface ContentRecommendation {
    contentType: 'story' | 'club' | 'achievement' | 'challenge';
    contentId: string;
    title: string;
    score: number;
    reasoning: string;
}

// ============================================
// 4D Analysis Functions
// ============================================

/**
 * Time Dimension: Optimal activities based on time of day
 */
function analyzeTimeDimension(context: UserContext): {
    period: 'morning' | 'afternoon' | 'evening' | 'night';
    sessionFreshness: 'fresh' | 'engaged' | 'tired';
    recommendations: string[];
} {
    const hour = new Date(context.currentTime).getHours();

    let period: 'morning' | 'afternoon' | 'evening' | 'night';
    let recommendations: string[] = [];

    if (hour >= 6 && hour < 12) {
        period = 'morning';
        recommendations = ['quick_games', 'daily_bonus', 'practice'];
    } else if (hour >= 12 && hour < 17) {
        period = 'afternoon';
        recommendations = ['multiplayer', 'tournaments', 'clubs'];
    } else if (hour >= 17 && hour < 22) {
        period = 'evening';
        recommendations = ['with_friends', 'voice_rooms', 'extended_games'];
    } else {
        period = 'night';
        recommendations = ['casual_games', 'bot_matches', 'social'];
    }

    let sessionFreshness: 'fresh' | 'engaged' | 'tired';
    if (context.sessionDuration < 15) {
        sessionFreshness = 'fresh';
    } else if (context.sessionDuration < 45) {
        sessionFreshness = 'engaged';
    } else {
        sessionFreshness = 'tired';
    }

    return { period, sessionFreshness, recommendations };
}

/**
 * Social Dimension: Friend activity and social opportunities
 */
function analyzeSocialDimension(context: UserContext): {
    socialLevel: 'solo' | 'few_friends' | 'social';
    friendActivity: string[];
    opportunities: string[];
} {
    const onlineCount = context.friendsOnline.length;

    let socialLevel: 'solo' | 'few_friends' | 'social';
    let opportunities: string[] = [];

    if (onlineCount === 0) {
        socialLevel = 'solo';
        opportunities = ['bot_match', 'practice', 'discover_players'];
    } else if (onlineCount < 4) {
        socialLevel = 'few_friends';
        opportunities = ['invite_friends', 'duo_games', 'voice_chat'];
    } else {
        socialLevel = 'social';
        opportunities = ['group_game', 'tournament', 'party_mode'];
    }

    return {
        socialLevel,
        friendActivity: context.friendsOnline.slice(0, 5),
        opportunities,
    };
}

/**
 * Skill Dimension: Appropriate challenge level
 */
function analyzeSkillDimension(context: UserContext): {
    primaryGame: string;
    skillTier: 'beginner' | 'intermediate' | 'advanced' | 'expert';
    growthAreas: string[];
    masteredGames: string[];
} {
    const skills = context.skillLevel;
    const entries = Object.entries(skills);

    if (entries.length === 0) {
        return {
            primaryGame: 'royal_meld',
            skillTier: 'beginner',
            growthAreas: ['call_break', 'teen_patti'],
            masteredGames: [],
        };
    }

    // Find primary game (highest ELO)
    const sorted = entries.sort(([, a], [, b]) => b - a);
    const primaryGame = sorted[0][0];
    const primaryElo = sorted[0][1];

    let skillTier: 'beginner' | 'intermediate' | 'advanced' | 'expert';
    if (primaryElo < 1000) {
        skillTier = 'beginner';
    } else if (primaryElo < 1400) {
        skillTier = 'intermediate';
    } else if (primaryElo < 1800) {
        skillTier = 'advanced';
    } else {
        skillTier = 'expert';
    }

    // Find growth areas (games with low/no ELO)
    const allGames = ['royal_meld', 'call_break', 'teen_patti', 'in_between'];
    const growthAreas = allGames.filter(
        (game) => !skills[game] || skills[game] < 1200
    );

    // Find mastered games
    const masteredGames = entries
        .filter(([, elo]) => elo >= 1600)
        .map(([game]) => game);

    return { primaryGame, skillTier, growthAreas, masteredGames };
}

// ============================================
// Recommendation Flows
// ============================================

/**
 * Recommend games based on 4D analysis
 */
export const recommendGamesFlow = ai.defineFlow(
    {
        name: 'recommendGames',
        inputSchema: z.object({
            userId: z.string(),
            context: z.record(z.unknown()),
        }),
        outputSchema: z.object({
            recommendations: z.array(z.object({
                gameType: z.string(),
                score: z.number(),
                reasoning: z.string(),
                suggestedMode: z.string(),
                estimatedDuration: z.number(),
            })),
            analysis: z.object({
                time: z.record(z.unknown()),
                social: z.record(z.unknown()),
                skill: z.record(z.unknown()),
            }),
        }),
    },
    async (input) => {
        const startTime = Date.now();
        const userContext = input.context as unknown as UserContext;

        logger.info('Generating game recommendations', { userId: input.userId });

        // Perform 4D analysis
        const timeAnalysis = analyzeTimeDimension(userContext);
        const socialAnalysis = analyzeSocialDimension(userContext);
        const skillAnalysis = analyzeSkillDimension(userContext);

        // Generate recommendations using AI
        const { output } = await ai.generate({
            prompt: `
Based on this user context, recommend the best games to play:

Time Analysis:
- Period: ${timeAnalysis.period}
- Session Freshness: ${timeAnalysis.sessionFreshness}
- Time Recommendations: ${timeAnalysis.recommendations.join(', ')}

Social Analysis:
- Social Level: ${socialAnalysis.socialLevel}
- Friends Online: ${socialAnalysis.friendActivity.length}
- Opportunities: ${socialAnalysis.opportunities.join(', ')}

Skill Analysis:
- Primary Game: ${skillAnalysis.primaryGame}
- Skill Tier: ${skillAnalysis.skillTier}
- Growth Areas: ${skillAnalysis.growthAreas.join(', ')}

Recent Games: ${userContext.recentGames.join(', ') || 'None'}
Preferences: ${JSON.stringify(userContext.preferences || {})}

Recommend 3-4 games with scores (0-1) and reasoning.
Consider variety and learning opportunities.
      `,
            output: {
                schema: z.object({
                    games: z.array(z.object({
                        gameType: z.enum(['royal_meld', 'call_break', 'teen_patti', 'in_between']),
                        score: z.number(),
                        reasoning: z.string(),
                        mode: z.enum(['quick_play', 'with_friends', 'tournament', 'practice']),
                        duration: z.number(),
                    })),
                }),
            },
        });

        const recommendations: GameRecommendation[] = (output?.games || []).map((g) => ({
            gameType: g.gameType,
            score: g.score,
            reasoning: g.reasoning,
            suggestedMode: g.mode as GameRecommendation['suggestedMode'],
            estimatedDuration: g.duration,
        }));

        // Track metrics
        await BusinessMetrics.aiAgentAction('recommendation', 'games', Date.now() - startTime);

        logger.info('Game recommendations generated', {
            userId: input.userId,
            count: recommendations.length,
        });

        return {
            recommendations,
            analysis: {
                time: timeAnalysis,
                social: socialAnalysis,
                skill: skillAnalysis,
            },
        };
    }
);

/**
 * Recommend friends to play with
 */
export const recommendFriendsFlow = ai.defineFlow(
    {
        name: 'recommendFriends',
        inputSchema: z.object({
            userId: z.string(),
            friendsData: z.array(z.object({
                id: z.string(),
                displayName: z.string(),
                isOnline: z.boolean(),
                lastPlayed: z.string().optional(),
                sharedGames: z.array(z.string()),
                skillMatch: z.number(),
            })),
            currentGame: z.string().optional(),
        }),
        outputSchema: z.object({
            recommendations: z.array(z.object({
                userId: z.string(),
                displayName: z.string(),
                score: z.number(),
                reasoning: z.string(),
                sharedInterests: z.array(z.string()),
                suggestedActivity: z.string(),
            })),
        }),
    },
    async (input) => {
        const startTime = Date.now();

        logger.info('Generating friend recommendations', {
            userId: input.userId,
            friendCount: input.friendsData.length,
        });

        // Score friends based on multiple factors
        const scoredFriends = input.friendsData.map((friend) => {
            let score = 0;

            // Online bonus
            if (friend.isOnline) score += 0.3;

            // Skill match bonus (closer = better)
            score += friend.skillMatch * 0.3;

            // Shared games bonus
            score += Math.min(friend.sharedGames.length * 0.1, 0.3);

            // Recent play bonus
            if (friend.lastPlayed) {
                const daysSince = (Date.now() - new Date(friend.lastPlayed).getTime()) / (1000 * 60 * 60 * 24);
                if (daysSince < 7) score += 0.1;
            }

            return {
                userId: friend.id,
                displayName: friend.displayName,
                score: Math.min(score, 1),
                reasoning: friend.isOnline
                    ? `Online now with ${friend.sharedGames.length} shared games`
                    : `Good skill match for ${friend.sharedGames[0] || 'games'}`,
                sharedInterests: friend.sharedGames,
                suggestedActivity: friend.isOnline ? 'Invite to game' : 'Send message',
            };
        });

        // Sort by score and return top 5
        const recommendations = scoredFriends
            .sort((a, b) => b.score - a.score)
            .slice(0, 5);

        await BusinessMetrics.aiAgentAction('recommendation', 'friends', Date.now() - startTime);

        return { recommendations };
    }
);

export default {
    recommendGamesFlow,
    recommendFriendsFlow,
};
