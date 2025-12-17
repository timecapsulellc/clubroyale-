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

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { multiFactorToT } from '../tot/tot_utils';

const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// SCHEMAS
// =============================================================================

const EngagementPredictionInputSchema = z.object({
    userId: z.string(),
    userMetrics: z.object({
        totalGames: z.number(),
        gamesThisWeek: z.number(),
        avgSessionLength: z.number(),
        friendCount: z.number(),
        diamondBalance: z.number(),
        lastLoginDaysAgo: z.number(),
    }),
    recentActivity: z.array(z.string()).optional(),
});

const EngagementPredictionOutputSchema = z.object({
    engagementScore: z.number(),
    churnRisk: z.enum(['low', 'medium', 'high']),
    predictedNextAction: z.string(),
    retentionStrategies: z.array(z.string()),
    upsellOpportunities: z.array(z.string()).optional(),
});

const TrendAnalysisInputSchema = z.object({
    timeRange: z.enum(['day', 'week', 'month']),
    metrics: z.object({
        totalUsers: z.number(),
        activeUsers: z.number(),
        gamesPlayed: z.number(),
        storiesPosted: z.number(),
        diamondsTransferred: z.number(),
    }),
    previousPeriod: z.object({
        totalUsers: z.number(),
        activeUsers: z.number(),
        gamesPlayed: z.number(),
        storiesPosted: z.number(),
        diamondsTransferred: z.number(),
    }).optional(),
    topContent: z.array(z.object({
        id: z.string(),
        type: z.string(),
        engagement: z.number(),
    })).optional(),
});

const TrendAnalysisOutputSchema = z.object({
    insights: z.array(z.object({
        metric: z.string(),
        trend: z.enum(['up', 'down', 'stable']),
        change: z.number(),
        insight: z.string(),
    })),
    recommendations: z.array(z.string()),
    highlights: z.array(z.string()),
    concerns: z.array(z.string()).optional(),
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
export const predictEngagementFlow = ai.defineFlow(
    {
        name: 'predictEngagement',
        inputSchema: EngagementPredictionInputSchema,
        outputSchema: EngagementPredictionOutputSchema,
    },
    async (input) => {
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
            const { result, factorScores, confidence } = await multiFactorToT(
                factors,
                evaluationGoal,
                EngagementPredictionOutputSchema
            );

            // Calculate engagement score from factor scores if not provided
            const calculatedScore = Object.values(factorScores).reduce((sum, score) => sum + score, 0) / Object.keys(factorScores).length * 100;

            return {
                engagementScore: result.engagementScore || calculatedScore,
                churnRisk: result.churnRisk,
                predictedNextAction: result.predictedNextAction,
                retentionStrategies: result.retentionStrategies || [],
                upsellOpportunities: result.upsellOpportunities,
            };
        } catch (error) {
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
                churnRisk: 'medium' as const,
                predictedNextAction: 'Play a game',
                retentionStrategies: ['Send daily reward notification'],
            };
        }
    }
);

export const analyzeTrendsFlow = ai.defineFlow(
    {
        name: 'analyzeTrends',
        inputSchema: TrendAnalysisInputSchema,
        outputSchema: TrendAnalysisOutputSchema,
    },
    async (input) => {
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
    }
);

// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================

export const predictEngagement = onCall(
    { maxInstances: 10, timeoutSeconds: 15 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await predictEngagementFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);

export const analyzeTrends = onCall(
    { maxInstances: 5, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) throw new HttpsError('unauthenticated', 'Auth required');
        try {
            return await analyzeTrendsFlow(request.data);
        } catch (error: any) {
            throw new HttpsError('internal', error.message);
        }
    }
);
