"use strict";
/**
 * Analytics Agent
 * Churn prediction y engagement scoring
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateEngagementFlow = exports.predictChurnFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const logger_1 = require("../../utils/logger");
const metrics_1 = require("../../utils/metrics");
const logger = (0, logger_1.createLogger)('analyticsAgent');
// Initialize Genkit
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// ============================================
// Churn Prediction
// ============================================
/**
 * Calculate base churn risk factors
 */
function calculateChurnFactors(data) {
    let score = 0;
    const factors = [];
    // Days since last login
    const daysSinceLogin = Math.floor((Date.now() - new Date(data.lastLogin).getTime()) / (1000 * 60 * 60 * 24));
    if (daysSinceLogin > 30) {
        score += 0.4;
        factors.push('Inactive for 30+ days');
    }
    else if (daysSinceLogin > 14) {
        score += 0.25;
        factors.push('Inactive for 14+ days');
    }
    else if (daysSinceLogin > 7) {
        score += 0.1;
        factors.push('Inactive for 7+ days');
    }
    // Login streak broken
    if (data.loginStreak === 0 && data.totalGamesPlayed > 10) {
        score += 0.15;
        factors.push('Login streak broken');
    }
    // Declining activity
    if (data.gamesLast7Days === 0 && data.gamesLast30Days > 0) {
        score += 0.2;
        factors.push('No activity in last 7 days');
    }
    // Low engagement for new users
    if (data.accountAgedays < 30 && data.totalGamesPlayed < 5) {
        score += 0.15;
        factors.push('New user with low engagement');
    }
    // No social connections
    if (data.friendCount === 0 && data.clubMemberships === 0) {
        score += 0.1;
        factors.push('No social connections');
    }
    // Low diamond balance (may have run out)
    if (data.diamondBalance < 10 && data.diamondSpentTotal > 100) {
        score += 0.1;
        factors.push('Low diamonds, was active spender');
    }
    return { score: Math.min(score, 1), factors };
}
/**
 * Predict churn risk for a user
 */
exports.predictChurnFlow = ai.defineFlow({
    name: 'predictChurn',
    inputSchema: genkit_1.z.object({
        userData: genkit_1.z.object({
            userId: genkit_1.z.string(),
            lastLogin: genkit_1.z.string(),
            loginStreak: genkit_1.z.number(),
            totalGamesPlayed: genkit_1.z.number(),
            gamesLast7Days: genkit_1.z.number(),
            gamesLast30Days: genkit_1.z.number(),
            diamondBalance: genkit_1.z.number(),
            diamondSpentTotal: genkit_1.z.number(),
            friendCount: genkit_1.z.number(),
            clubMemberships: genkit_1.z.number(),
            accountAgedays: genkit_1.z.number(),
            lastPurchase: genkit_1.z.string().optional(),
        }),
    }),
    outputSchema: genkit_1.z.object({
        riskLevel: genkit_1.z.enum(['low', 'medium', 'high', 'critical']),
        riskScore: genkit_1.z.number(),
        factors: genkit_1.z.array(genkit_1.z.string()),
        recommendedActions: genkit_1.z.array(genkit_1.z.string()),
        predictedChurnDays: genkit_1.z.number().optional(),
    }),
}, async (input) => {
    const startTime = Date.now();
    const data = input.userData;
    logger.info('Predicting churn', { userId: data.userId });
    // Calculate base factors
    const { score, factors } = calculateChurnFactors(data);
    // Determine risk level
    let riskLevel;
    if (score >= 0.7) {
        riskLevel = 'critical';
    }
    else if (score >= 0.5) {
        riskLevel = 'high';
    }
    else if (score >= 0.25) {
        riskLevel = 'medium';
    }
    else {
        riskLevel = 'low';
    }
    // Generate recommended actions using AI
    const { output } = await ai.generate({
        prompt: `
User churn risk analysis:
- Risk Level: ${riskLevel}
- Risk Score: ${(score * 100).toFixed(0)}%
- Factors: ${factors.join(', ')}

User Profile:
- Account Age: ${data.accountAgedays} days
- Total Games: ${data.totalGamesPlayed}
- Friends: ${data.friendCount}
- Diamond Balance: ${data.diamondBalance}

Suggest 2-4 specific actions to retain this user.
Focus on personalized re-engagement strategies.
      `,
        output: {
            schema: genkit_1.z.object({
                actions: genkit_1.z.array(genkit_1.z.string()),
                predictedDays: genkit_1.z.number().optional(),
            }),
        },
    });
    const result = {
        userId: data.userId,
        riskLevel,
        riskScore: score,
        factors,
        recommendedActions: output?.actions || [
            'Send re-engagement notification',
            'Offer bonus diamonds',
        ],
        predictedChurnDays: output?.predictedDays,
    };
    await metrics_1.BusinessMetrics.aiAgentAction('analytics', 'churn_prediction', Date.now() - startTime);
    logger.info('Churn prediction complete', {
        userId: data.userId,
        riskLevel,
        riskScore: score,
    });
    return result;
});
// ============================================
// Engagement Scoring
// ============================================
/**
 * Calculate engagement score for a user
 */
exports.calculateEngagementFlow = ai.defineFlow({
    name: 'calculateEngagement',
    inputSchema: genkit_1.z.object({
        userData: genkit_1.z.object({
            userId: genkit_1.z.string(),
            lastLogin: genkit_1.z.string(),
            loginStreak: genkit_1.z.number(),
            totalGamesPlayed: genkit_1.z.number(),
            gamesLast7Days: genkit_1.z.number(),
            gamesLast30Days: genkit_1.z.number(),
            diamondBalance: genkit_1.z.number(),
            diamondSpentTotal: genkit_1.z.number(),
            friendCount: genkit_1.z.number(),
            clubMemberships: genkit_1.z.number(),
            accountAgedays: genkit_1.z.number(),
            messagesLast30Days: genkit_1.z.number().optional(),
            storiesPosted: genkit_1.z.number().optional(),
        }),
    }),
    outputSchema: genkit_1.z.object({
        overallScore: genkit_1.z.number(),
        dimensions: genkit_1.z.object({
            activity: genkit_1.z.number(),
            social: genkit_1.z.number(),
            spending: genkit_1.z.number(),
            loyalty: genkit_1.z.number(),
        }),
        tier: genkit_1.z.enum(['casual', 'regular', 'engaged', 'power_user', 'whale']),
        insights: genkit_1.z.array(genkit_1.z.string()),
    }),
}, async (input) => {
    const startTime = Date.now();
    const data = input.userData;
    logger.info('Calculating engagement', { userId: data.userId });
    // Activity dimension (0-100)
    const gamesPerDay = data.gamesLast30Days / 30;
    const activityScore = Math.min(gamesPerDay * 20, 100);
    // Social dimension (0-100)
    const socialScore = Math.min((data.friendCount * 5) +
        (data.clubMemberships * 10) +
        ((data.messagesLast30Days || 0) * 0.5) +
        ((data.storiesPosted || 0) * 5), 100);
    // Spending dimension (0-100)
    const spendingScore = Math.min(data.diamondSpentTotal / 10, 100);
    // Loyalty dimension (0-100)
    const loyaltyScore = Math.min((data.loginStreak * 2) +
        (data.accountAgedays / 3), 100);
    // Overall score (weighted average)
    const overallScore = Math.round((activityScore * 0.35) +
        (socialScore * 0.25) +
        (spendingScore * 0.2) +
        (loyaltyScore * 0.2));
    // Determine tier
    let tier;
    if (overallScore >= 80 && spendingScore >= 60) {
        tier = 'whale';
    }
    else if (overallScore >= 70) {
        tier = 'power_user';
    }
    else if (overallScore >= 50) {
        tier = 'engaged';
    }
    else if (overallScore >= 25) {
        tier = 'regular';
    }
    else {
        tier = 'casual';
    }
    // Generate insights
    const insights = [];
    if (activityScore > 70) {
        insights.push('Highly active player');
    }
    if (socialScore > 60) {
        insights.push('Strong social engagement');
    }
    if (loyaltyScore > 50 && data.loginStreak > 7) {
        insights.push(`${data.loginStreak} day login streak!`);
    }
    if (spendingScore > 50) {
        insights.push('Valuable spender');
    }
    if (activityScore < 30 && data.accountAgedays > 14) {
        insights.push('May need re-engagement');
    }
    const result = {
        userId: data.userId,
        overallScore,
        dimensions: {
            activity: Math.round(activityScore),
            social: Math.round(socialScore),
            spending: Math.round(spendingScore),
            loyalty: Math.round(loyaltyScore),
        },
        tier,
        insights,
    };
    await metrics_1.BusinessMetrics.aiAgentAction('analytics', 'engagement_score', Date.now() - startTime);
    logger.info('Engagement score calculated', {
        userId: data.userId,
        overallScore,
        tier,
    });
    return result;
});
exports.default = {
    predictChurnFlow: exports.predictChurnFlow,
    calculateEngagementFlow: exports.calculateEngagementFlow,
};
//# sourceMappingURL=analyticsAgent.js.map