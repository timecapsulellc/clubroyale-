"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.recommendGames = exports.suggestFriends = exports.rankFeed = exports.recommendGamesFlow = exports.suggestFriendsFlow = exports.rankFeedFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const https_1 = require("firebase-functions/v2/https");
const tot_utils_1 = require("../tot/tot_utils");
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// =============================================================================
// SCHEMAS
// =============================================================================
const FeedRankingInputSchema = genkit_1.z.object({
    userId: genkit_1.z.string(),
    userProfile: genkit_1.z.object({
        interests: genkit_1.z.array(genkit_1.z.string()),
        playedGames: genkit_1.z.array(genkit_1.z.string()),
        followedUsers: genkit_1.z.array(genkit_1.z.string()),
        skillLevel: genkit_1.z.enum(['beginner', 'intermediate', 'advanced', 'expert']).optional(),
    }),
    contentItems: genkit_1.z.array(genkit_1.z.object({
        id: genkit_1.z.string(),
        type: genkit_1.z.enum(['story', 'game_result', 'achievement', 'social', 'reel']),
        creatorId: genkit_1.z.string(),
        tags: genkit_1.z.array(genkit_1.z.string()),
        engagementScore: genkit_1.z.number(),
        createdAt: genkit_1.z.string(),
    })),
    feedType: genkit_1.z.enum(['home', 'discover', 'gaming', 'social']),
    limit: genkit_1.z.number().default(20),
});
const FeedRankingOutputSchema = genkit_1.z.object({
    rankedContent: genkit_1.z.array(genkit_1.z.object({
        contentId: genkit_1.z.string(),
        score: genkit_1.z.number(),
        reason: genkit_1.z.string(),
    })),
    trendingTopics: genkit_1.z.array(genkit_1.z.string()),
    suggestedCreators: genkit_1.z.array(genkit_1.z.string()),
});
const FriendSuggestionInputSchema = genkit_1.z.object({
    userId: genkit_1.z.string(),
    userProfile: genkit_1.z.object({
        games: genkit_1.z.array(genkit_1.z.string()),
        skillLevel: genkit_1.z.string(),
        location: genkit_1.z.string().optional(),
        activeHours: genkit_1.z.array(genkit_1.z.number()).optional(),
    }),
    potentialFriends: genkit_1.z.array(genkit_1.z.object({
        id: genkit_1.z.string(),
        games: genkit_1.z.array(genkit_1.z.string()),
        skillLevel: genkit_1.z.string(),
        mutualFriends: genkit_1.z.number(),
        lastActive: genkit_1.z.string(),
    })),
    limit: genkit_1.z.number().default(10),
});
const FriendSuggestionOutputSchema = genkit_1.z.object({
    suggestions: genkit_1.z.array(genkit_1.z.object({
        userId: genkit_1.z.string(),
        compatibilityScore: genkit_1.z.number(),
        reason: genkit_1.z.string(),
        commonInterests: genkit_1.z.array(genkit_1.z.string()),
    })),
});
const GameRecommendationInputSchema = genkit_1.z.object({
    userId: genkit_1.z.string(),
    playHistory: genkit_1.z.array(genkit_1.z.object({
        game: genkit_1.z.string(),
        timesPlayed: genkit_1.z.number(),
        winRate: genkit_1.z.number(),
        enjoymentScore: genkit_1.z.number().optional(),
    })),
    currentMood: genkit_1.z.enum(['competitive', 'casual', 'social', 'learning']).optional(),
    availableTime: genkit_1.z.enum(['quick', 'medium', 'long']).optional(),
});
const GameRecommendationOutputSchema = genkit_1.z.object({
    recommendations: genkit_1.z.array(genkit_1.z.object({
        game: genkit_1.z.string(),
        reason: genkit_1.z.string(),
        matchScore: genkit_1.z.number(),
        suggestedMode: genkit_1.z.string().optional(),
    })),
    tip: genkit_1.z.string().optional(),
});
// =============================================================================
// GENKIT FLOWS
// =============================================================================
/**
 * Personalized Feed Ranking
 */
exports.rankFeedFlow = ai.defineFlow({
    name: 'rankFeed',
    inputSchema: FeedRankingInputSchema,
    outputSchema: FeedRankingOutputSchema,
}, async (input) => {
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
});
/**
 * Friend Suggestions
 */
exports.suggestFriendsFlow = ai.defineFlow({
    name: 'suggestFriends',
    inputSchema: FriendSuggestionInputSchema,
    outputSchema: FriendSuggestionOutputSchema,
}, async (input) => {
    const prompt = `Suggest friends for a ClubRoyale user.

User Profile:
- Games: ${input.userProfile.games.join(', ')}
- Skill: ${input.userProfile.skillLevel}
${input.userProfile.location ? `- Location: ${input.userProfile.location}` : ''}

Potential Friends: ${input.potentialFriends.length} candidates
${input.potentialFriends.slice(0, 10).map(f => `- ${f.id}: plays ${f.games.join(', ')}, skill: ${f.skillLevel}, mutuals: ${f.mutualFriends}`).join('\n')}

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
});
/**
 * Game Recommendations - Enhanced with Tree of Thoughts
 *
 * Uses multi-dimensional reasoning:
 * 1. Competition preference analysis
 * 2. Discovery opportunity (games not tried)
 * 3. Time constraint matching
 * 4. Mood alignment
 */
exports.recommendGamesFlow = ai.defineFlow({
    name: 'recommendGames',
    inputSchema: GameRecommendationInputSchema,
    outputSchema: GameRecommendationOutputSchema,
}, async (input) => {
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
        const totResult = await (0, tot_utils_1.runTreeOfThoughts)(problemDescription, dimensions, goalDescription, GameRecommendationOutputSchema, {
            maxDepth: 2,
            branchingFactor: 3,
            evaluationThreshold: 0.4,
            searchStrategy: 'bfs',
        });
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
    }
    catch (error) {
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
});
// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================
exports.rankFeed = (0, https_1.onCall)({ maxInstances: 20, timeoutSeconds: 30 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.rankFeedFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.suggestFriends = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 30 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.suggestFriendsFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.recommendGames = (0, https_1.onCall)({ maxInstances: 20, timeoutSeconds: 15 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.recommendGamesFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
//# sourceMappingURL=recommendation_agent.js.map