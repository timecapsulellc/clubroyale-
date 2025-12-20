/**
 * Analytics Agent
 * Churn prediction y engagement scoring
 */

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import * as admin from 'firebase-admin';
import { createLogger } from '../../utils/logger';
import { BusinessMetrics } from '../../utils/metrics';

const logger = createLogger('analyticsAgent');

// Initialize Genkit
const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// ============================================
// Types
// ============================================

interface UserActivityData {
    userId: string;
    lastLogin: string;
    loginStreak: number;
    totalGamesPlayed: number;
    gamesLast7Days: number;
    gamesLast30Days: number;
    diamondBalance: number;
    diamondSpentTotal: number;
    friendCount: number;
    clubMemberships: number;
    accountAgedays: number;
    lastPurchase?: string;
}

interface ChurnPrediction {
    userId: string;
    riskLevel: 'low' | 'medium' | 'high' | 'critical';
    riskScore: number; // 0-1
    factors: string[];
    recommendedActions: string[];
    predictedChurnDays?: number;
}

interface EngagementScore {
    userId: string;
    overallScore: number; // 0-100
    dimensions: {
        activity: number;
        social: number;
        spending: number;
        loyalty: number;
    };
    tier: 'casual' | 'regular' | 'engaged' | 'power_user' | 'whale';
    insights: string[];
}

// ============================================
// Churn Prediction
// ============================================

/**
 * Calculate base churn risk factors
 */
function calculateChurnFactors(data: UserActivityData): {
    score: number;
    factors: string[];
} {
    let score = 0;
    const factors: string[] = [];

    // Days since last login
    const daysSinceLogin = Math.floor(
        (Date.now() - new Date(data.lastLogin).getTime()) / (1000 * 60 * 60 * 24)
    );

    if (daysSinceLogin > 30) {
        score += 0.4;
        factors.push('Inactive for 30+ days');
    } else if (daysSinceLogin > 14) {
        score += 0.25;
        factors.push('Inactive for 14+ days');
    } else if (daysSinceLogin > 7) {
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
export const predictChurnFlow = ai.defineFlow(
    {
        name: 'predictChurn',
        inputSchema: z.object({
            userData: z.object({
                userId: z.string(),
                lastLogin: z.string(),
                loginStreak: z.number(),
                totalGamesPlayed: z.number(),
                gamesLast7Days: z.number(),
                gamesLast30Days: z.number(),
                diamondBalance: z.number(),
                diamondSpentTotal: z.number(),
                friendCount: z.number(),
                clubMemberships: z.number(),
                accountAgedays: z.number(),
                lastPurchase: z.string().optional(),
            }),
        }),
        outputSchema: z.object({
            riskLevel: z.enum(['low', 'medium', 'high', 'critical']),
            riskScore: z.number(),
            factors: z.array(z.string()),
            recommendedActions: z.array(z.string()),
            predictedChurnDays: z.number().optional(),
        }),
    },
    async (input) => {
        const startTime = Date.now();
        const data = input.userData;

        logger.info('Predicting churn', { userId: data.userId });

        // Calculate base factors
        const { score, factors } = calculateChurnFactors(data);

        // Determine risk level
        let riskLevel: ChurnPrediction['riskLevel'];
        if (score >= 0.7) {
            riskLevel = 'critical';
        } else if (score >= 0.5) {
            riskLevel = 'high';
        } else if (score >= 0.25) {
            riskLevel = 'medium';
        } else {
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
                schema: z.object({
                    actions: z.array(z.string()),
                    predictedDays: z.number().optional(),
                }),
            },
        });

        const result: ChurnPrediction = {
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

        await BusinessMetrics.aiAgentAction('analytics', 'churn_prediction', Date.now() - startTime);

        logger.info('Churn prediction complete', {
            userId: data.userId,
            riskLevel,
            riskScore: score,
        });

        return result;
    }
);

// ============================================
// Engagement Scoring
// ============================================

/**
 * Calculate engagement score for a user
 */
export const calculateEngagementFlow = ai.defineFlow(
    {
        name: 'calculateEngagement',
        inputSchema: z.object({
            userData: z.object({
                userId: z.string(),
                lastLogin: z.string(),
                loginStreak: z.number(),
                totalGamesPlayed: z.number(),
                gamesLast7Days: z.number(),
                gamesLast30Days: z.number(),
                diamondBalance: z.number(),
                diamondSpentTotal: z.number(),
                friendCount: z.number(),
                clubMemberships: z.number(),
                accountAgedays: z.number(),
                messagesLast30Days: z.number().optional(),
                storiesPosted: z.number().optional(),
            }),
        }),
        outputSchema: z.object({
            overallScore: z.number(),
            dimensions: z.object({
                activity: z.number(),
                social: z.number(),
                spending: z.number(),
                loyalty: z.number(),
            }),
            tier: z.enum(['casual', 'regular', 'engaged', 'power_user', 'whale']),
            insights: z.array(z.string()),
        }),
    },
    async (input) => {
        const startTime = Date.now();
        const data = input.userData;

        logger.info('Calculating engagement', { userId: data.userId });

        // Activity dimension (0-100)
        const gamesPerDay = data.gamesLast30Days / 30;
        const activityScore = Math.min(gamesPerDay * 20, 100);

        // Social dimension (0-100)
        const socialScore = Math.min(
            (data.friendCount * 5) +
            (data.clubMemberships * 10) +
            ((data.messagesLast30Days || 0) * 0.5) +
            ((data.storiesPosted || 0) * 5),
            100
        );

        // Spending dimension (0-100)
        const spendingScore = Math.min(data.diamondSpentTotal / 10, 100);

        // Loyalty dimension (0-100)
        const loyaltyScore = Math.min(
            (data.loginStreak * 2) +
            (data.accountAgedays / 3),
            100
        );

        // Overall score (weighted average)
        const overallScore = Math.round(
            (activityScore * 0.35) +
            (socialScore * 0.25) +
            (spendingScore * 0.2) +
            (loyaltyScore * 0.2)
        );

        // Determine tier
        let tier: EngagementScore['tier'];
        if (overallScore >= 80 && spendingScore >= 60) {
            tier = 'whale';
        } else if (overallScore >= 70) {
            tier = 'power_user';
        } else if (overallScore >= 50) {
            tier = 'engaged';
        } else if (overallScore >= 25) {
            tier = 'regular';
        } else {
            tier = 'casual';
        }

        // Generate insights
        const insights: string[] = [];

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

        const result: EngagementScore = {
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

        await BusinessMetrics.aiAgentAction('analytics', 'engagement_score', Date.now() - startTime);

        logger.info('Engagement score calculated', {
            userId: data.userId,
            overallScore,
            tier,
        });

        return result;
    }
);

export default {
    predictChurnFlow,
    calculateEngagementFlow,
};
