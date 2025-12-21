"use strict";
/**
 * Economy Agent
 * Diamond flow optimization, spending analysis, and economy health monitoring
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.optimizeRewardsFlow = exports.analyzeSpendingFlow = exports.analyzeEconomyHealthFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const logger_1 = require("../../utils/logger");
const metrics_1 = require("../../utils/metrics");
const logger = (0, logger_1.createLogger)('economyAgent');
// Initialize Genkit
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// ============================================
// Economy Analysis Functions
// ============================================
/**
 * Calculate diamond burn rate and runway
 */
function calculateBurnRate(data) {
    const last7DaysNet = data.lastSevenDaysActivity.diamondsWon - data.lastSevenDaysActivity.diamondsLost;
    const dailyBurnRate = -last7DaysNet / 7; // Negative if earning
    if (dailyBurnRate <= 0) {
        return { burnRate: 0, runwayDays: 999 }; // Infinite runway if earning
    }
    const runwayDays = Math.floor(data.diamondBalance / dailyBurnRate);
    return { burnRate: dailyBurnRate, runwayDays };
}
/**
 * Analyze spending patterns
 */
function analyzeSpendingPatterns(data) {
    if (data.spendingHistory.length === 0) {
        return {
            primaryCategory: 'none',
            averageSpend: 0,
            spendingVelocity: 'conservative',
        };
    }
    // Count by category
    const categoryCounts = {};
    let totalSpend = 0;
    for (const spend of data.spendingHistory) {
        categoryCounts[spend.category] = (categoryCounts[spend.category] || 0) + spend.amount;
        totalSpend += spend.amount;
    }
    const primaryCategory = Object.entries(categoryCounts)
        .sort(([, a], [, b]) => b - a)[0]?.[0] || 'game_entry';
    const averageSpend = totalSpend / data.spendingHistory.length;
    // Determine velocity based on daily spend rate
    const dailySpendRate = totalSpend / Math.max(data.accountAgeDays, 1);
    let spendingVelocity;
    if (dailySpendRate < 50) {
        spendingVelocity = 'conservative';
    }
    else if (dailySpendRate < 200) {
        spendingVelocity = 'moderate';
    }
    else {
        spendingVelocity = 'aggressive';
    }
    return { primaryCategory, averageSpend, spendingVelocity };
}
// ============================================
// Economy Flows
// ============================================
/**
 * Analyze economy health for a user
 */
exports.analyzeEconomyHealthFlow = ai.defineFlow({
    name: 'analyzeEconomyHealth',
    inputSchema: genkit_1.z.object({
        userData: genkit_1.z.object({
            userId: genkit_1.z.string(),
            diamondBalance: genkit_1.z.number(),
            diamondsEarnedTotal: genkit_1.z.number(),
            diamondsSpentTotal: genkit_1.z.number(),
            purchaseHistory: genkit_1.z.array(genkit_1.z.object({
                date: genkit_1.z.string(),
                amount: genkit_1.z.number(),
                type: genkit_1.z.enum(['iap', 'ad_reward', 'bonus']),
            })),
            spendingHistory: genkit_1.z.array(genkit_1.z.object({
                date: genkit_1.z.string(),
                amount: genkit_1.z.number(),
                category: genkit_1.z.enum(['game_entry', 'cosmetics', 'gifts', 'tips']),
            })),
            lastSevenDaysActivity: genkit_1.z.object({
                gamesPlayed: genkit_1.z.number(),
                diamondsWon: genkit_1.z.number(),
                diamondsLost: genkit_1.z.number(),
                adsWatched: genkit_1.z.number(),
            }),
            accountAgeDays: genkit_1.z.number(),
            isPremium: genkit_1.z.boolean(),
        }),
    }),
    outputSchema: genkit_1.z.object({
        userId: genkit_1.z.string(),
        healthScore: genkit_1.z.number(),
        burnRate: genkit_1.z.number(),
        runwayDays: genkit_1.z.number(),
        riskLevel: genkit_1.z.enum(['healthy', 'watch', 'at_risk', 'critical']),
        recommendations: genkit_1.z.array(genkit_1.z.string()),
        suggestedRewards: genkit_1.z.array(genkit_1.z.object({
            type: genkit_1.z.enum(['daily_bonus', 'ad_reward', 'achievement', 'comeback']),
            amount: genkit_1.z.number(),
            reason: genkit_1.z.string(),
        })),
    }),
}, async (input) => {
    const startTime = Date.now();
    const data = input.userData;
    logger.info('Analyzing economy health', { userId: data.userId });
    // Calculate metrics
    const { burnRate, runwayDays } = calculateBurnRate(data);
    const spending = analyzeSpendingPatterns(data);
    // Calculate health score
    let healthScore = 100;
    // Deduct for low balance
    if (data.diamondBalance < 100)
        healthScore -= 30;
    else if (data.diamondBalance < 500)
        healthScore -= 15;
    // Deduct for high burn rate
    if (runwayDays < 3)
        healthScore -= 30;
    else if (runwayDays < 7)
        healthScore -= 15;
    // Bonus for earning pattern
    if (burnRate < 0)
        healthScore = Math.min(100, healthScore + 10);
    healthScore = Math.max(0, Math.min(100, healthScore));
    // Determine risk level
    let riskLevel;
    if (healthScore >= 70)
        riskLevel = 'healthy';
    else if (healthScore >= 50)
        riskLevel = 'watch';
    else if (healthScore >= 25)
        riskLevel = 'at_risk';
    else
        riskLevel = 'critical';
    // Generate AI recommendations
    const { output } = await ai.generate({
        prompt: `
Analyze this user's diamond economy and suggest interventions:

Current State:
- Balance: ${data.diamondBalance} diamonds
- Daily Burn Rate: ${burnRate.toFixed(1)} diamonds/day
- Runway: ${runwayDays} days
- Spending Pattern: ${spending.spendingVelocity} (mainly ${spending.primaryCategory})
- Account Age: ${data.accountAgeDays} days
- Premium User: ${data.isPremium}

Last 7 Days:
- Games Played: ${data.lastSevenDaysActivity.gamesPlayed}
- Diamonds Won: ${data.lastSevenDaysActivity.diamondsWon}
- Diamonds Lost: ${data.lastSevenDaysActivity.diamondsLost}
- Ads Watched: ${data.lastSevenDaysActivity.adsWatched}

Provide:
1. 2-3 personalized recommendations to improve their economy
2. Suggested rewards with amounts and reasons

Focus on retention - we want users to stay engaged without running out of diamonds.
            `,
        output: {
            schema: genkit_1.z.object({
                recommendations: genkit_1.z.array(genkit_1.z.string()),
                suggestedRewards: genkit_1.z.array(genkit_1.z.object({
                    type: genkit_1.z.enum(['daily_bonus', 'ad_reward', 'achievement', 'comeback']),
                    amount: genkit_1.z.number(),
                    reason: genkit_1.z.string(),
                })),
            }),
        },
    });
    const result = {
        userId: data.userId,
        healthScore,
        burnRate,
        runwayDays: Math.min(runwayDays, 999),
        riskLevel,
        recommendations: output?.recommendations || [],
        suggestedRewards: output?.suggestedRewards || [],
    };
    await metrics_1.BusinessMetrics.aiAgentAction('economy', 'health_analysis', Date.now() - startTime);
    logger.info('Economy health analyzed', {
        userId: data.userId,
        healthScore,
        riskLevel,
    });
    return result;
});
/**
 * Analyze spending patterns for a user
 */
exports.analyzeSpendingFlow = ai.defineFlow({
    name: 'analyzeSpending',
    inputSchema: genkit_1.z.object({
        userData: genkit_1.z.object({
            userId: genkit_1.z.string(),
            spendingHistory: genkit_1.z.array(genkit_1.z.object({
                date: genkit_1.z.string(),
                amount: genkit_1.z.number(),
                category: genkit_1.z.enum(['game_entry', 'cosmetics', 'gifts', 'tips']),
                context: genkit_1.z.string().optional(),
            })),
            recentGames: genkit_1.z.array(genkit_1.z.object({
                stakeLevel: genkit_1.z.number(),
                result: genkit_1.z.enum(['win', 'loss']),
                amount: genkit_1.z.number(),
            })),
        }),
    }),
    outputSchema: genkit_1.z.object({
        userId: genkit_1.z.string(),
        primaryCategory: genkit_1.z.string(),
        spendingVelocity: genkit_1.z.enum(['conservative', 'moderate', 'aggressive']),
        peakSpendingTime: genkit_1.z.string(),
        averageBetSize: genkit_1.z.number(),
        riskAppetite: genkit_1.z.number(),
        insights: genkit_1.z.array(genkit_1.z.string()),
    }),
}, async (input) => {
    const startTime = Date.now();
    const data = input.userData;
    logger.info('Analyzing spending patterns', { userId: data.userId });
    // Calculate basic patterns
    const spending = analyzeSpendingPatterns({
        userId: data.userId,
        diamondBalance: 0,
        diamondsEarnedTotal: 0,
        diamondsSpentTotal: 0,
        purchaseHistory: [],
        spendingHistory: data.spendingHistory,
        lastSevenDaysActivity: { gamesPlayed: 0, diamondsWon: 0, diamondsLost: 0, adsWatched: 0 },
        accountAgeDays: 30,
        isPremium: false,
    });
    // Calculate average bet and risk appetite
    let totalBetSize = 0;
    let lossChasing = 0;
    for (let i = 0; i < data.recentGames.length; i++) {
        totalBetSize += data.recentGames[i].stakeLevel;
        // Check for loss chasing (bigger bets after losses)
        if (i > 0 && data.recentGames[i - 1].result === 'loss') {
            if (data.recentGames[i].stakeLevel > data.recentGames[i - 1].stakeLevel) {
                lossChasing++;
            }
        }
    }
    const averageBetSize = data.recentGames.length > 0
        ? totalBetSize / data.recentGames.length
        : 0;
    // Risk appetite based on bet sizes and loss chasing behavior
    const maxBet = Math.max(...data.recentGames.map(g => g.stakeLevel), 1);
    const lossChasingRatio = data.recentGames.length > 1
        ? lossChasing / (data.recentGames.length - 1)
        : 0;
    const riskAppetite = Math.min(1, (averageBetSize / maxBet * 0.5) + (lossChasingRatio * 0.5));
    // Generate insights
    const insights = [];
    if (spending.spendingVelocity === 'aggressive') {
        insights.push('High spending velocity detected - consider stake limits');
    }
    if (lossChasingRatio > 0.3) {
        insights.push('Loss chasing behavior detected - implement cooling off periods');
    }
    if (spending.primaryCategory === 'cosmetics') {
        insights.push('User values customization - offer exclusive cosmetic bundles');
    }
    if (spending.primaryCategory === 'gifts') {
        insights.push('Social spender - encourage friend invites');
    }
    const result = {
        userId: data.userId,
        primaryCategory: spending.primaryCategory,
        spendingVelocity: spending.spendingVelocity,
        peakSpendingTime: 'evening', // Would need time analysis
        averageBetSize,
        riskAppetite,
        insights,
    };
    await metrics_1.BusinessMetrics.aiAgentAction('economy', 'spending_analysis', Date.now() - startTime);
    return result;
});
/**
 * Optimize reward distribution for a user
 */
exports.optimizeRewardsFlow = ai.defineFlow({
    name: 'optimizeRewards',
    inputSchema: genkit_1.z.object({
        userId: genkit_1.z.string(),
        currentBalance: genkit_1.z.number(),
        recentActivity: genkit_1.z.object({
            lastLoginDays: genkit_1.z.number(),
            gamesPlayedLast7Days: genkit_1.z.number(),
            adsWatchedLast7Days: genkit_1.z.number(),
        }),
        economyHealth: genkit_1.z.enum(['healthy', 'watch', 'at_risk', 'critical']),
    }),
    outputSchema: genkit_1.z.object({
        dailyReward: genkit_1.z.number(),
        bonusMultiplier: genkit_1.z.number(),
        specialOffer: genkit_1.z.string().optional(),
        urgency: genkit_1.z.enum(['none', 'low', 'medium', 'high']),
        message: genkit_1.z.string(),
    }),
}, async (input) => {
    const startTime = Date.now();
    logger.info('Optimizing rewards', { userId: input.userId });
    // Base daily reward
    let dailyReward = 100;
    let bonusMultiplier = 1;
    let specialOffer;
    let urgency = 'none';
    // Adjust based on economy health
    switch (input.economyHealth) {
        case 'critical':
            dailyReward = 300;
            bonusMultiplier = 3;
            urgency = 'high';
            specialOffer = 'Emergency Recovery Pack: 500 diamonds for watching 3 ads';
            break;
        case 'at_risk':
            dailyReward = 200;
            bonusMultiplier = 2;
            urgency = 'medium';
            specialOffer = 'Boost Pack: Double winnings for next 3 games';
            break;
        case 'watch':
            dailyReward = 150;
            bonusMultiplier = 1.5;
            urgency = 'low';
            break;
        case 'healthy':
            dailyReward = 100;
            bonusMultiplier = 1;
            break;
    }
    // Comeback bonus
    if (input.recentActivity.lastLoginDays > 3) {
        dailyReward += 100 * Math.min(input.recentActivity.lastLoginDays, 7);
        specialOffer = `Welcome back! ${dailyReward} diamonds waiting for you!`;
        urgency = 'high';
    }
    // Activity bonus
    if (input.recentActivity.gamesPlayedLast7Days > 20) {
        bonusMultiplier += 0.5;
    }
    // Generate personalized message
    const { output } = await ai.generate({
        prompt: `
Create a short, engaging message for a user based on:
- Economy status: ${input.economyHealth}
- Daily reward: ${dailyReward} diamonds
- Last login: ${input.recentActivity.lastLoginDays} days ago
- Games played this week: ${input.recentActivity.gamesPlayedLast7Days}

Make it encouraging and fun. Max 100 characters.
            `,
        output: {
            schema: genkit_1.z.object({
                message: genkit_1.z.string(),
            }),
        },
    });
    await metrics_1.BusinessMetrics.aiAgentAction('economy', 'reward_optimization', Date.now() - startTime);
    return {
        dailyReward,
        bonusMultiplier,
        specialOffer,
        urgency,
        message: output?.message || `Claim your ${dailyReward} diamonds!`,
    };
});
exports.default = {
    analyzeEconomyHealthFlow: exports.analyzeEconomyHealthFlow,
    analyzeSpendingFlow: exports.analyzeSpendingFlow,
    optimizeRewardsFlow: exports.optimizeRewardsFlow,
};
//# sourceMappingURL=economyAgent.js.map