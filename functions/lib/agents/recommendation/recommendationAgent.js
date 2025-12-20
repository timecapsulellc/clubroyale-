"use strict";
/**
 * Recommendation Agent
 * 4D Personalization: Time, Mood, Social, Skill
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.recommendFriendsFlow = exports.recommendGamesFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const logger_1 = require("../../utils/logger");
const metrics_1 = require("../../utils/metrics");
const logger = (0, logger_1.createLogger)('recommendationAgent');
// Initialize Genkit
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// ============================================
// 4D Analysis Functions
// ============================================
/**
 * Time Dimension: Optimal activities based on time of day
 */
function analyzeTimeDimension(context) {
    const hour = new Date(context.currentTime).getHours();
    let period;
    let recommendations = [];
    if (hour >= 6 && hour < 12) {
        period = 'morning';
        recommendations = ['quick_games', 'daily_bonus', 'practice'];
    }
    else if (hour >= 12 && hour < 17) {
        period = 'afternoon';
        recommendations = ['multiplayer', 'tournaments', 'clubs'];
    }
    else if (hour >= 17 && hour < 22) {
        period = 'evening';
        recommendations = ['with_friends', 'voice_rooms', 'extended_games'];
    }
    else {
        period = 'night';
        recommendations = ['casual_games', 'bot_matches', 'social'];
    }
    let sessionFreshness;
    if (context.sessionDuration < 15) {
        sessionFreshness = 'fresh';
    }
    else if (context.sessionDuration < 45) {
        sessionFreshness = 'engaged';
    }
    else {
        sessionFreshness = 'tired';
    }
    return { period, sessionFreshness, recommendations };
}
/**
 * Social Dimension: Friend activity and social opportunities
 */
function analyzeSocialDimension(context) {
    const onlineCount = context.friendsOnline.length;
    let socialLevel;
    let opportunities = [];
    if (onlineCount === 0) {
        socialLevel = 'solo';
        opportunities = ['bot_match', 'practice', 'discover_players'];
    }
    else if (onlineCount < 4) {
        socialLevel = 'few_friends';
        opportunities = ['invite_friends', 'duo_games', 'voice_chat'];
    }
    else {
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
function analyzeSkillDimension(context) {
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
    let skillTier;
    if (primaryElo < 1000) {
        skillTier = 'beginner';
    }
    else if (primaryElo < 1400) {
        skillTier = 'intermediate';
    }
    else if (primaryElo < 1800) {
        skillTier = 'advanced';
    }
    else {
        skillTier = 'expert';
    }
    // Find growth areas (games with low/no ELO)
    const allGames = ['royal_meld', 'call_break', 'teen_patti', 'in_between'];
    const growthAreas = allGames.filter((game) => !skills[game] || skills[game] < 1200);
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
exports.recommendGamesFlow = ai.defineFlow({
    name: 'recommendGames',
    inputSchema: genkit_1.z.object({
        userId: genkit_1.z.string(),
        context: genkit_1.z.record(genkit_1.z.unknown()),
    }),
    outputSchema: genkit_1.z.object({
        recommendations: genkit_1.z.array(genkit_1.z.object({
            gameType: genkit_1.z.string(),
            score: genkit_1.z.number(),
            reasoning: genkit_1.z.string(),
            suggestedMode: genkit_1.z.string(),
            estimatedDuration: genkit_1.z.number(),
        })),
        analysis: genkit_1.z.object({
            time: genkit_1.z.record(genkit_1.z.unknown()),
            social: genkit_1.z.record(genkit_1.z.unknown()),
            skill: genkit_1.z.record(genkit_1.z.unknown()),
        }),
    }),
}, async (input) => {
    const startTime = Date.now();
    const userContext = input.context;
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
            schema: genkit_1.z.object({
                games: genkit_1.z.array(genkit_1.z.object({
                    gameType: genkit_1.z.enum(['royal_meld', 'call_break', 'teen_patti', 'in_between']),
                    score: genkit_1.z.number(),
                    reasoning: genkit_1.z.string(),
                    mode: genkit_1.z.enum(['quick_play', 'with_friends', 'tournament', 'practice']),
                    duration: genkit_1.z.number(),
                })),
            }),
        },
    });
    const recommendations = (output?.games || []).map((g) => ({
        gameType: g.gameType,
        score: g.score,
        reasoning: g.reasoning,
        suggestedMode: g.mode,
        estimatedDuration: g.duration,
    }));
    // Track metrics
    await metrics_1.BusinessMetrics.aiAgentAction('recommendation', 'games', Date.now() - startTime);
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
});
/**
 * Recommend friends to play with
 */
exports.recommendFriendsFlow = ai.defineFlow({
    name: 'recommendFriends',
    inputSchema: genkit_1.z.object({
        userId: genkit_1.z.string(),
        friendsData: genkit_1.z.array(genkit_1.z.object({
            id: genkit_1.z.string(),
            displayName: genkit_1.z.string(),
            isOnline: genkit_1.z.boolean(),
            lastPlayed: genkit_1.z.string().optional(),
            sharedGames: genkit_1.z.array(genkit_1.z.string()),
            skillMatch: genkit_1.z.number(),
        })),
        currentGame: genkit_1.z.string().optional(),
    }),
    outputSchema: genkit_1.z.object({
        recommendations: genkit_1.z.array(genkit_1.z.object({
            userId: genkit_1.z.string(),
            displayName: genkit_1.z.string(),
            score: genkit_1.z.number(),
            reasoning: genkit_1.z.string(),
            sharedInterests: genkit_1.z.array(genkit_1.z.string()),
            suggestedActivity: genkit_1.z.string(),
        })),
    }),
}, async (input) => {
    const startTime = Date.now();
    logger.info('Generating friend recommendations', {
        userId: input.userId,
        friendCount: input.friendsData.length,
    });
    // Score friends based on multiple factors
    const scoredFriends = input.friendsData.map((friend) => {
        let score = 0;
        // Online bonus
        if (friend.isOnline)
            score += 0.3;
        // Skill match bonus (closer = better)
        score += friend.skillMatch * 0.3;
        // Shared games bonus
        score += Math.min(friend.sharedGames.length * 0.1, 0.3);
        // Recent play bonus
        if (friend.lastPlayed) {
            const daysSince = (Date.now() - new Date(friend.lastPlayed).getTime()) / (1000 * 60 * 60 * 24);
            if (daysSince < 7)
                score += 0.1;
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
    await metrics_1.BusinessMetrics.aiAgentAction('recommendation', 'friends', Date.now() - startTime);
    return { recommendations };
});
exports.default = {
    recommendGamesFlow: exports.recommendGamesFlow,
    recommendFriendsFlow: exports.recommendFriendsFlow,
};
//# sourceMappingURL=recommendationAgent.js.map