/**
 * Recommendation Agent - Personalized Content & Friend Discovery
 * 
 * Features:
 * - Personalized feed ranking
 * - Friend suggestions
 * - Game recommendations with Tree of Thoughts reasoning
 * - Content discovery
 * 
 * Enhanced with Tree of Thoughts (ToT) for deliberate problem-solving
 * Powered by Google GenKit + Gemini 2.0 Flash
 */

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { runTreeOfThoughts, type ToTResult } from '../tot/tot_utils';

const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// SCHEMAS
// =============================================================================

const FeedRankingInputSchema = z.object({
    userId: z.string(),
    userProfile: z.object({
        interests: z.array(z.string()),
        playedGames: z.array(z.string()),
        followedUsers: z.array(z.string()),
        skillLevel: z.enum(['beginner', 'intermediate', 'advanced', 'expert']).optional(),
    }),
    contentItems: z.array(z.object({
        id: z.string(),
        type: z.enum(['story', 'game_result', 'achievement', 'social', 'reel']),
        creatorId: z.string(),
        tags: z.array(z.string()),
        engagementScore: z.number(),
        createdAt: z.string(),
    })),
    feedType: z.enum(['home', 'discover', 'gaming', 'social']),
    limit: z.number().default(20),
});

const FeedRankingOutputSchema = z.object({
    rankedContent: z.array(z.object({
        contentId: z.string(),
        score: z.number(),
        reason: z.string(),
    })),
    trendingTopics: z.array(z.string()),
    suggestedCreators: z.array(z.string()),
});

const FriendSuggestionInputSchema = z.object({
    userId: z.string(),
    userProfile: z.object({
        games: z.array(z.string()),
        skillLevel: z.string(),
        location: z.string().optional(),
        activeHours: z.array(z.number()).optional(),
    }),
    potentialFriends: z.array(z.object({
        id: z.string(),
        games: z.array(z.string()),
        skillLevel: z.string(),
        mutualFriends: z.number(),
        lastActive: z.string(),
    })),
    limit: z.number().default(10),
});

const FriendSuggestionOutputSchema = z.object({
    suggestions: z.array(z.object({
        userId: z.string(),
        compatibilityScore: z.number(),
        reason: z.string(),
        commonInterests: z.array(z.string()),
    })),
});

const GameRecommendationInputSchema = z.object({
    userId: z.string(),
    playHistory: z.array(z.object({
        game: z.string(),
        timesPlayed: z.number(),
        winRate: z.number(),
        enjoymentScore: z.number().optional(),
    })),
    currentMood: z.enum(['competitive', 'casual', 'social', 'learning']).optional(),
    availableTime: z.enum(['quick', 'medium', 'long']).optional(),
});

const GameRecommendationOutputSchema = z.object({
    recommendations: z.array(z.object({
        game: z.string(),
        reason: z.string(),
        matchScore: z.number(),
        suggestedMode: z.string().optional(),
    })),
    tip: z.string().optional(),
});

// =============================================================================
// GENKIT FLOWS
// =============================================================================

/**
 * Personalized Feed Ranking
 */
export const rankFeedFlow = ai.defineFlow(
    {
        name: 'rankFeed',
        inputSchema: FeedRankingInputSchema,
        outputSchema: FeedRankingOutputSchema,
    },
    async (input) => {
        const prompt = `You are the Recommendation Agent for ClubRoyale.

Rank content for a user's ${input.feedType} feed.

User Profile:
- Interests: ${input.userProfile.interests.join(', ')}
- Games: ${input.userProfile.playedGames.join(', ')}
- Following: ${input.userProfile.followedUsers.length} users
- Skill: ${input.userProfile.skillLevel || 'unknown'}

Content to rank: ${input.contentItems.length} items
${input.contentItems.slice(0, 10).map(c => `- ${c.id}: ${c.type} by ${c.creatorId}, score: ${c.engagementScore}`).join('\n')}

Ranking factors:
1. Relevance to user's interests and games
2. Content freshness (recent content preferred)
3. Creator relationship (following > friends-of-friends > trending)
4. Engagement score (viral content boost)
5. Content diversity (mix of types)

Output top ${input.limit} ranked items with scores (0-100) and brief reasons.`;

        const { output } = await ai.generate({
            prompt,
            output: { schema: FeedRankingOutputSchema },
        });

        return output ?? {
            rankedContent: input.contentItems.slice(0, input.limit).map(c => ({
                contentId: c.id,
                score: c.engagementScore,
                reason: 'Default ranking',
            })),
            trendingTopics: ['#ClubRoyale', '#Gaming'],
            suggestedCreators: [],
        };
    }
);

/**
 * Friend Suggestions
 */
export const suggestFriendsFlow = ai.defineFlow(
    {
        name: 'suggestFriends',
        inputSchema: FriendSuggestionInputSchema,
        outputSchema: FriendSuggestionOutputSchema,
    },
    async (input) => {
        const prompt = `Suggest friends for a ClubRoyale user.

User Profile:
- Games: ${input.userProfile.games.join(', ')}
- Skill: ${input.userProfile.skillLevel}
${input.userProfile.location ? `- Location: ${input.userProfile.location}` : ''}

Potential Friends: ${input.potentialFriends.length} candidates
${input.potentialFriends.slice(0, 10).map(f =>
            `- ${f.id}: plays ${f.games.join(', ')}, skill: ${f.skillLevel}, mutuals: ${f.mutualFriends}`
        ).join('\n')}

Ranking criteria:
1. Game overlap (same games = higher score)
2. Skill level match (similar skill = better games)
3. Mutual friends (social proof)
4. Activity matching (both active = likely to play together)

Return top ${input.limit} suggestions with compatibility scores and reasons.`;

        const { output } = await ai.generate({
            prompt,
            output: { schema: FriendSuggestionOutputSchema },
        });

        return output ?? {
            suggestions: input.potentialFriends.slice(0, input.limit).map(f => ({
                userId: f.id,
                compatibilityScore: 0.5 + (f.mutualFriends * 0.1),
                reason: `${f.mutualFriends} mutual friends`,
                commonInterests: f.games.filter(g => input.userProfile.games.includes(g)),
            })),
        };
    }
);

/**
 * Game Recommendations - Enhanced with Tree of Thoughts
 * 
 * Uses multi-dimensional reasoning:
 * 1. Competition preference analysis
 * 2. Discovery opportunity (games not tried)
 * 3. Time constraint matching
 * 4. Mood alignment
 */
export const recommendGamesFlow = ai.defineFlow(
    {
        name: 'recommendGames',
        inputSchema: GameRecommendationInputSchema,
        outputSchema: GameRecommendationOutputSchema,
    },
    async (input) => {
        const availableGames = ['Call Break', 'Marriage', 'Teen Patti', 'In-Between'];

        // Build problem context for ToT
        const problemDescription = `Game recommendation for ClubRoyale user.

Available Games: ${availableGames.join(', ')}

User's Play History:
${input.playHistory.map(h => `- ${h.game}: ${h.timesPlayed} games, ${(h.winRate * 100).toFixed(0)}% win rate`).join('\n')}

${input.currentMood ? `Current Mood: ${input.currentMood}` : 'Mood: Not specified'}
${input.availableTime ? `Available Time: ${input.availableTime}` : 'Time: Not specified'}`;

        // Define reasoning dimensions for ToT
        const dimensions = [
            `COMPETITION PREFERENCE: Analyze if user prefers competitive games based on their win rates and game choices. High win rate in Call Break = loves competition.`,
            `DISCOVERY OPPORTUNITY: Identify games the user hasn't tried much. Less than 5 plays = discovery opportunity.`,
            `TIME CONSTRAINTS: Match game duration to available time. Quick=${availableGames.filter(g => g === 'In-Between').join(', ')}, Long=${availableGames.filter(g => g === 'Marriage').join(', ')}`,
            `MOOD ALIGNMENT: Match games to current mood. Competitive=Call Break/Teen Patti, Social=Marriage, Casual=In-Between`,
        ];

        const goalDescription = `Recommend 2-3 games that best match this user's preferences, considering all dimensions. Each recommendation should have a clear reason and match score (0-1).`;

        try {
            // Run Tree of Thoughts reasoning
            const totResult = await runTreeOfThoughts(
                problemDescription,
                dimensions,
                goalDescription,
                GameRecommendationOutputSchema,
                {
                    maxDepth: 2,
                    branchingFactor: 3,
                    evaluationThreshold: 0.4,
                    searchStrategy: 'bfs',
                }
            );

            // Add metadata about the reasoning process
            const result = totResult.finalAnswer;
            if (result.recommendations && result.recommendations.length > 0) {
                // Add ToT insight to tip if available
                const totInsight = totResult.bestPath.length > 0
                    ? `(Analyzed ${totResult.totalThoughtsGenerated} possibilities${totResult.backtrackCount > 0 ? `, refined ${totResult.backtrackCount} times` : ''})`
                    : '';

                return {
                    ...result,
                    tip: result.tip
                        ? `${result.tip} ${totInsight}`
                        : totInsight || undefined,
                };
            }

            return result;
        } catch (error) {
            // Fallback to simple recommendation if ToT fails
            console.error('ToT recommendation failed, using fallback:', error);

            const prompt = `Recommend games for a ClubRoyale user.

Available Games: ${availableGames.join(', ')}

User's Play History:
${input.playHistory.map(h => `- ${h.game}: ${h.timesPlayed} games, ${(h.winRate * 100).toFixed(0)}% win rate`).join('\n')}

${input.currentMood ? `Current Mood: ${input.currentMood}` : ''}
${input.availableTime ? `Available Time: ${input.availableTime}` : ''}

Consider:
1. Games they haven't tried much (discovery)
2. Games they're good at (confidence boost)
3. Games that match their mood
4. Time constraints (quick = In-Between, long = Marriage)

Provide 2-3 game recommendations with reasons.`;

            const { output } = await ai.generate({
                prompt,
                output: { schema: GameRecommendationOutputSchema },
            });

            return output ?? {
                recommendations: [
                    { game: 'Call Break', reason: 'Popular choice!', matchScore: 0.8 },
                ],
            };
        }
    }
);

// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================

export const rankFeed = onCall(
    { maxInstances: 20, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await rankFeedFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);

export const suggestFriends = onCall(
    { maxInstances: 10, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await suggestFriendsFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);

export const recommendGames = onCall(
    { maxInstances: 20, timeoutSeconds: 15 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await recommendGamesFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);
