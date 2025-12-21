/**
 * Economy Agent
 * Diamond flow optimization, spending analysis, and economy health monitoring
 */

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { createLogger } from '../../utils/logger';
import { BusinessMetrics } from '../../utils/metrics';

const logger = createLogger('economyAgent');

// Initialize Genkit
const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// ============================================
// Types
// ============================================

interface UserEconomyData {
    userId: string;
    diamondBalance: number;
    diamondsEarnedTotal: number;
    diamondsSpentTotal: number;
    purchaseHistory: {
        date: string;
        amount: number;
        type: 'iap' | 'ad_reward' | 'bonus';
    }[];
    spendingHistory: {
        date: string;
        amount: number;
        category: 'game_entry' | 'cosmetics' | 'gifts' | 'tips';
    }[];
    lastSevenDaysActivity: {
        gamesPlayed: number;
        diamondsWon: number;
        diamondsLost: number;
        adsWatched: number;
    };
    accountAgeDays: number;
    isPremium: boolean;
}

interface EconomyHealth {
    userId: string;
    healthScore: number; // 0-100
    burnRate: number; // diamonds per day
    runwayDays: number; // days until 0 at current rate
    riskLevel: 'healthy' | 'watch' | 'at_risk' | 'critical';
    recommendations: string[];
    suggestedRewards: {
        type: 'daily_bonus' | 'ad_reward' | 'achievement' | 'comeback';
        amount: number;
        reason: string;
    }[];
}

interface SpendingPattern {
    userId: string;
    primaryCategory: string;
    spendingVelocity: 'conservative' | 'moderate' | 'aggressive';
    peakSpendingTime: string;
    averageBetSize: number;
    riskAppetite: number; // 0-1
    insights: string[];
}

// ============================================
// Economy Analysis Functions
// ============================================

/**
 * Calculate diamond burn rate and runway
 */
function calculateBurnRate(data: UserEconomyData): { burnRate: number; runwayDays: number } {
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
function analyzeSpendingPatterns(data: UserEconomyData): {
    primaryCategory: string;
    averageSpend: number;
    spendingVelocity: 'conservative' | 'moderate' | 'aggressive';
} {
    if (data.spendingHistory.length === 0) {
        return {
            primaryCategory: 'none',
            averageSpend: 0,
            spendingVelocity: 'conservative',
        };
    }

    // Count by category
    const categoryCounts: Record<string, number> = {};
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
    let spendingVelocity: 'conservative' | 'moderate' | 'aggressive';

    if (dailySpendRate < 50) {
        spendingVelocity = 'conservative';
    } else if (dailySpendRate < 200) {
        spendingVelocity = 'moderate';
    } else {
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
export const analyzeEconomyHealthFlow = ai.defineFlow(
    {
        name: 'analyzeEconomyHealth',
        inputSchema: z.object({
            userData: z.object({
                userId: z.string(),
                diamondBalance: z.number(),
                diamondsEarnedTotal: z.number(),
                diamondsSpentTotal: z.number(),
                purchaseHistory: z.array(z.object({
                    date: z.string(),
                    amount: z.number(),
                    type: z.enum(['iap', 'ad_reward', 'bonus']),
                })),
                spendingHistory: z.array(z.object({
                    date: z.string(),
                    amount: z.number(),
                    category: z.enum(['game_entry', 'cosmetics', 'gifts', 'tips']),
                })),
                lastSevenDaysActivity: z.object({
                    gamesPlayed: z.number(),
                    diamondsWon: z.number(),
                    diamondsLost: z.number(),
                    adsWatched: z.number(),
                }),
                accountAgeDays: z.number(),
                isPremium: z.boolean(),
            }),
        }),
        outputSchema: z.object({
            userId: z.string(),
            healthScore: z.number(),
            burnRate: z.number(),
            runwayDays: z.number(),
            riskLevel: z.enum(['healthy', 'watch', 'at_risk', 'critical']),
            recommendations: z.array(z.string()),
            suggestedRewards: z.array(z.object({
                type: z.enum(['daily_bonus', 'ad_reward', 'achievement', 'comeback']),
                amount: z.number(),
                reason: z.string(),
            })),
        }),
    },
    async (input) => {
        const startTime = Date.now();
        const data = input.userData;

        logger.info('Analyzing economy health', { userId: data.userId });

        // Calculate metrics
        const { burnRate, runwayDays } = calculateBurnRate(data);
        const spending = analyzeSpendingPatterns(data);

        // Calculate health score
        let healthScore = 100;

        // Deduct for low balance
        if (data.diamondBalance < 100) healthScore -= 30;
        else if (data.diamondBalance < 500) healthScore -= 15;

        // Deduct for high burn rate
        if (runwayDays < 3) healthScore -= 30;
        else if (runwayDays < 7) healthScore -= 15;

        // Bonus for earning pattern
        if (burnRate < 0) healthScore = Math.min(100, healthScore + 10);

        healthScore = Math.max(0, Math.min(100, healthScore));

        // Determine risk level
        let riskLevel: 'healthy' | 'watch' | 'at_risk' | 'critical';
        if (healthScore >= 70) riskLevel = 'healthy';
        else if (healthScore >= 50) riskLevel = 'watch';
        else if (healthScore >= 25) riskLevel = 'at_risk';
        else riskLevel = 'critical';

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
                schema: z.object({
                    recommendations: z.array(z.string()),
                    suggestedRewards: z.array(z.object({
                        type: z.enum(['daily_bonus', 'ad_reward', 'achievement', 'comeback']),
                        amount: z.number(),
                        reason: z.string(),
                    })),
                }),
            },
        });

        const result: EconomyHealth = {
            userId: data.userId,
            healthScore,
            burnRate,
            runwayDays: Math.min(runwayDays, 999),
            riskLevel,
            recommendations: output?.recommendations || [],
            suggestedRewards: output?.suggestedRewards || [],
        };

        await BusinessMetrics.aiAgentAction('economy', 'health_analysis', Date.now() - startTime);

        logger.info('Economy health analyzed', {
            userId: data.userId,
            healthScore,
            riskLevel,
        });

        return result;
    }
);

/**
 * Analyze spending patterns for a user
 */
export const analyzeSpendingFlow = ai.defineFlow(
    {
        name: 'analyzeSpending',
        inputSchema: z.object({
            userData: z.object({
                userId: z.string(),
                spendingHistory: z.array(z.object({
                    date: z.string(),
                    amount: z.number(),
                    category: z.enum(['game_entry', 'cosmetics', 'gifts', 'tips']),
                    context: z.string().optional(),
                })),
                recentGames: z.array(z.object({
                    stakeLevel: z.number(),
                    result: z.enum(['win', 'loss']),
                    amount: z.number(),
                })),
            }),
        }),
        outputSchema: z.object({
            userId: z.string(),
            primaryCategory: z.string(),
            spendingVelocity: z.enum(['conservative', 'moderate', 'aggressive']),
            peakSpendingTime: z.string(),
            averageBetSize: z.number(),
            riskAppetite: z.number(),
            insights: z.array(z.string()),
        }),
    },
    async (input) => {
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
        const insights: string[] = [];

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

        const result: SpendingPattern = {
            userId: data.userId,
            primaryCategory: spending.primaryCategory,
            spendingVelocity: spending.spendingVelocity,
            peakSpendingTime: 'evening', // Would need time analysis
            averageBetSize,
            riskAppetite,
            insights,
        };

        await BusinessMetrics.aiAgentAction('economy', 'spending_analysis', Date.now() - startTime);

        return result;
    }
);

/**
 * Optimize reward distribution for a user
 */
export const optimizeRewardsFlow = ai.defineFlow(
    {
        name: 'optimizeRewards',
        inputSchema: z.object({
            userId: z.string(),
            currentBalance: z.number(),
            recentActivity: z.object({
                lastLoginDays: z.number(),
                gamesPlayedLast7Days: z.number(),
                adsWatchedLast7Days: z.number(),
            }),
            economyHealth: z.enum(['healthy', 'watch', 'at_risk', 'critical']),
        }),
        outputSchema: z.object({
            dailyReward: z.number(),
            bonusMultiplier: z.number(),
            specialOffer: z.string().optional(),
            urgency: z.enum(['none', 'low', 'medium', 'high']),
            message: z.string(),
        }),
    },
    async (input) => {
        const startTime = Date.now();

        logger.info('Optimizing rewards', { userId: input.userId });

        // Base daily reward
        let dailyReward = 100;
        let bonusMultiplier = 1;
        let specialOffer: string | undefined;
        let urgency: 'none' | 'low' | 'medium' | 'high' = 'none';

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
                schema: z.object({
                    message: z.string(),
                }),
            },
        });

        await BusinessMetrics.aiAgentAction('economy', 'reward_optimization', Date.now() - startTime);

        return {
            dailyReward,
            bonusMultiplier,
            specialOffer,
            urgency,
            message: output?.message || `Claim your ${dailyReward} diamonds!`,
        };
    }
);

export default {
    analyzeEconomyHealthFlow,
    analyzeSpendingFlow,
    optimizeRewardsFlow,
};
