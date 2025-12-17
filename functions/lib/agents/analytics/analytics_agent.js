"use strict";
/**
 * Analytics Agent - User Insights & Engagement Analysis
 *
 * Features:
 * - Engagement prediction with Tree of Thoughts reasoning
 * - Trend analysis
 * - User behavior insights with multi-factor analysis
 * - Churn prediction with backtracking
 *
 * Enhanced with Tree of Thoughts (ToT) for deliberate problem-solving
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.analyzeTrends = exports.predictEngagement = exports.analyzeTrendsFlow = exports.predictEngagementFlow = void 0;
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
const EngagementPredictionInputSchema = genkit_1.z.object({
    userId: genkit_1.z.string(),
    userMetrics: genkit_1.z.object({
        totalGames: genkit_1.z.number(),
        gamesThisWeek: genkit_1.z.number(),
        avgSessionLength: genkit_1.z.number(),
        friendCount: genkit_1.z.number(),
        diamondBalance: genkit_1.z.number(),
        lastLoginDaysAgo: genkit_1.z.number(),
    }),
    recentActivity: genkit_1.z.array(genkit_1.z.string()).optional(),
});
const EngagementPredictionOutputSchema = genkit_1.z.object({
    engagementScore: genkit_1.z.number(),
    churnRisk: genkit_1.z.enum(['low', 'medium', 'high']),
    predictedNextAction: genkit_1.z.string(),
    retentionStrategies: genkit_1.z.array(genkit_1.z.string()),
    upsellOpportunities: genkit_1.z.array(genkit_1.z.string()).optional(),
});
const TrendAnalysisInputSchema = genkit_1.z.object({
    timeRange: genkit_1.z.enum(['day', 'week', 'month']),
    metrics: genkit_1.z.object({
        totalUsers: genkit_1.z.number(),
        activeUsers: genkit_1.z.number(),
        gamesPlayed: genkit_1.z.number(),
        storiesPosted: genkit_1.z.number(),
        diamondsTransferred: genkit_1.z.number(),
    }),
    previousPeriod: genkit_1.z.object({
        totalUsers: genkit_1.z.number(),
        activeUsers: genkit_1.z.number(),
        gamesPlayed: genkit_1.z.number(),
        storiesPosted: genkit_1.z.number(),
        diamondsTransferred: genkit_1.z.number(),
    }).optional(),
    topContent: genkit_1.z.array(genkit_1.z.object({
        id: genkit_1.z.string(),
        type: genkit_1.z.string(),
        engagement: genkit_1.z.number(),
    })).optional(),
});
const TrendAnalysisOutputSchema = genkit_1.z.object({
    insights: genkit_1.z.array(genkit_1.z.object({
        metric: genkit_1.z.string(),
        trend: genkit_1.z.enum(['up', 'down', 'stable']),
        change: genkit_1.z.number(),
        insight: genkit_1.z.string(),
    })),
    recommendations: genkit_1.z.array(genkit_1.z.string()),
    highlights: genkit_1.z.array(genkit_1.z.string()),
    concerns: genkit_1.z.array(genkit_1.z.string()).optional(),
});
// =============================================================================
// GENKIT FLOWS
// =============================================================================
/**
 * Predict Engagement - Enhanced with Tree of Thoughts
 *
 * Multi-factor analysis with backtracking:
 * 1. Session Patterns (frequency, duration, time of day)
 * 2. Social Connections (friend count, interaction rate)
 * 3. Spending Behavior (diamond balance, transactions)
 * 4. Engagement Trajectory (week-over-week change)
 */
exports.predictEngagementFlow = ai.defineFlow({
    name: 'predictEngagement',
    inputSchema: EngagementPredictionInputSchema,
    outputSchema: EngagementPredictionOutputSchema,
}, async (input) => {
    // Define factors for ToT multi-factor analysis
    const factors = [
        {
            name: 'Session Patterns',
            context: `User has played ${input.userMetrics.totalGames} total games, ${input.userMetrics.gamesThisWeek} this week. Average session: ${input.userMetrics.avgSessionLength} min. Last login: ${input.userMetrics.lastLoginDaysAgo} days ago. ${input.userMetrics.gamesThisWeek > 5 ? 'High activity' : input.userMetrics.gamesThisWeek > 2 ? 'Moderate activity' : 'Low activity'}. ${input.userMetrics.lastLoginDaysAgo > 7 ? 'WARNING: Lapsed user!' : input.userMetrics.lastLoginDaysAgo > 3 ? 'Cooling off' : 'Recently active'}.`,
        },
        {
            name: 'Social Connections',
            context: `User has ${input.userMetrics.friendCount} friends. ${input.userMetrics.friendCount > 10 ? 'Strong social network - likely to stay' : input.userMetrics.friendCount > 3 ? 'Growing network' : 'Low social investment - higher churn risk'}. Social engagement is a key retention factor.`,
        },
        {
            name: 'Spending Behavior',
            context: `Diamond balance: ${input.userMetrics.diamondBalance}. ${input.userMetrics.diamondBalance > 1000 ? 'Active spender - invested in platform' : input.userMetrics.diamondBalance > 100 ? 'Moderate investment' : 'Minimal spending - may not see value yet'}. Higher investment = lower churn risk.`,
        },
        {
            name: 'Engagement Trajectory',
            context: `Games this week: ${input.userMetrics.gamesThisWeek}, Total games: ${input.userMetrics.totalGames}. ${input.recentActivity?.length ? `Recent activity: ${input.recentActivity.join(', ')}` : 'No recent activity data'}. ${input.userMetrics.gamesThisWeek > (input.userMetrics.totalGames / 4) ? 'Trajectory: INCREASING' : 'Trajectory: STABLE or DECLINING'}.`,
        },
    ];
    const evaluationGoal = `Predict user churn risk and engagement for ClubRoyale. Consider:
- Low churn = active, social, invested
- Medium churn = showing some warning signs
- High churn = lapsed, low social, minimal investment

Look for CONTRADICTIONS:
- High activity but low spending = engaged but not monetizing (opportunity, not risk)
- Low activity but many friends = social but not gaming (re-engagement opportunity)
- High spending but low activity = might be frustrated`;
    try {
        // Run multi-factor ToT analysis with backtracking
        const { result, factorScores, confidence } = await (0, tot_utils_1.multiFactorToT)(factors, evaluationGoal, EngagementPredictionOutputSchema);
        // Calculate engagement score from factor scores if not provided
        const calculatedScore = Object.values(factorScores).reduce((sum, score) => sum + score, 0) / Object.keys(factorScores).length * 100;
        return {
            engagementScore: result.engagementScore || calculatedScore,
            churnRisk: result.churnRisk,
            predictedNextAction: result.predictedNextAction,
            retentionStrategies: result.retentionStrategies || [],
            upsellOpportunities: result.upsellOpportunities,
        };
    }
    catch (error) {
        // Fallback to simple prediction if ToT fails
        console.error('ToT engagement prediction failed, using fallback:', error);
        const prompt = `Analyze user engagement for ClubRoyale.

User Metrics:
- Total games: ${input.userMetrics.totalGames}
- Games this week: ${input.userMetrics.gamesThisWeek}
- Avg session: ${input.userMetrics.avgSessionLength} min
- Friends: ${input.userMetrics.friendCount}
- Diamonds: ${input.userMetrics.diamondBalance}
- Last login: ${input.userMetrics.lastLoginDaysAgo} days ago

${input.recentActivity?.length ? `Recent: ${input.recentActivity.join(', ')}` : ''}

Predict:
1. Engagement score (0-100)
2. Churn risk level
3. Most likely next action
4. Retention strategies if at risk
5. Upsell opportunities if engaged`;
        const { output } = await ai.generate({
            prompt,
            output: { schema: EngagementPredictionOutputSchema },
        });
        return output ?? {
            engagementScore: 50,
            churnRisk: 'medium',
            predictedNextAction: 'Play a game',
            retentionStrategies: ['Send daily reward notification'],
        };
    }
});
exports.analyzeTrendsFlow = ai.defineFlow({
    name: 'analyzeTrends',
    inputSchema: TrendAnalysisInputSchema,
    outputSchema: TrendAnalysisOutputSchema,
}, async (input) => {
    const prompt = `Analyze platform trends for ClubRoyale.

${input.timeRange.toUpperCase()} METRICS:
- Total users: ${input.metrics.totalUsers}
- Active users: ${input.metrics.activeUsers}
- Games played: ${input.metrics.gamesPlayed}
- Stories posted: ${input.metrics.storiesPosted}
- Diamonds transferred: ${input.metrics.diamondsTransferred}

${input.previousPeriod ? `
PREVIOUS ${input.timeRange.toUpperCase()}:
- Active users: ${input.previousPeriod.activeUsers}
- Games played: ${input.previousPeriod.gamesPlayed}
` : ''}

${input.topContent?.length ? `
TOP CONTENT:
${input.topContent.slice(0, 5).map(c => `- ${c.type}: ${c.engagement} engagement`).join('\n')}
` : ''}

Provide:
1. Key metric trends with % changes
2. Actionable recommendations
3. Platform highlights
4. Areas of concern`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: TrendAnalysisOutputSchema },
    });
    return output ?? {
        insights: [],
        recommendations: [],
        highlights: [],
    };
});
// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================
exports.predictEngagement = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 15 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.predictEngagementFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.analyzeTrends = (0, https_1.onCall)({ maxInstances: 5, timeoutSeconds: 30 }, async (request) => {
    if (!request.auth)
        throw new https_1.HttpsError('unauthenticated', 'Auth required');
    try {
        return await (0, exports.analyzeTrendsFlow)(request.data);
    }
    catch (error) {
        throw new https_1.HttpsError('internal', error.message);
    }
});
//# sourceMappingURL=analytics_agent.js.map