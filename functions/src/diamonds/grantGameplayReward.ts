/**
 * Gameplay Reward Granting
 * 
 * Securely grants diamonds for gameplay wins.
 * - Anti-cheat verification
 * - Tier-based daily earning caps
 * - Origin tracking (weighted higher for governance)
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { TIER_LIMITS, GAMEPLAY_REWARDS, UserTier } from './config';
import { grantDiamondsToUser, getUser, verifyGameResult } from './utils';
import * as admin from 'firebase-admin';

interface GameplayRewardRequest {
    gameType: string;
    result: string;
    gameId: string;
}

interface GameplayRewardResponse {
    success: boolean;
    earned: number;
    message?: string;
    dailyTotal?: number;
    dailyCap?: number;
}

export const grantGameplayReward = onCall(async (request): Promise<GameplayRewardResponse> => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'Must be logged in');
    }

    const data = request.data as GameplayRewardRequest;
    const { gameType, result, gameId } = data;

    // 1. Verify game result (anti-cheat)
    // In a real implementation this checks the game state in Firestore
    const gameVerification = await verifyGameResult(gameId, userId, result);
    if (!gameVerification.verified) {
        console.warn(`[CHEAT ATTEMPT] User ${userId} tried to claim invalid reward for game ${gameId}`);
        throw new HttpsError('invalid-argument', 'Invalid game result or reward already claimed');
    }

    // 2. Calculate reward
    // e.g. 'callbreak_win' or 'teenPatti_showdown'
    const rewardKey = `${gameType}_${result}`;
    const rewardAmount = GAMEPLAY_REWARDS[rewardKey] || 0;

    if (rewardAmount === 0) {
        return { success: true, earned: 0 };
    }

    // 3. Check daily earning cap
    const user = await getUser(userId);
    const userTier = (user.tier || 'basic') as UserTier;
    const tierLimits = TIER_LIMITS[userTier];
    const todayEarned = user.dailyEarned || 0;

    if (tierLimits.dailyEarningCap !== -1 &&
        todayEarned >= tierLimits.dailyEarningCap) {
        return {
            success: true,
            earned: 0,
            message: 'Daily earning cap reached. Play more tomorrow or upgrade tier!',
            dailyTotal: todayEarned,
            dailyCap: tierLimits.dailyEarningCap
        };
    }

    // 4. Calculate actual reward (respecting cap)
    // If cap is 200, earned 190, reward is 20 -> can only earn 10
    const remainingCap = tierLimits.dailyEarningCap === -1
        ? rewardAmount
        : Math.max(0, tierLimits.dailyEarningCap - todayEarned);

    const actualReward = Math.min(rewardAmount, remainingCap);

    if (actualReward <= 0) {
        return {
            success: true,
            earned: 0,
            message: 'Daily earning cap reached.',
            dailyTotal: todayEarned,
            dailyCap: tierLimits.dailyEarningCap
        };
    }

    // 5. Grant diamonds
    await grantDiamondsToUser(
        userId,
        actualReward,
        'gameplayWin',
        `Won ${gameType} (${result})`
    );

    return {
        success: true,
        earned: actualReward,
        dailyTotal: todayEarned + actualReward,
        dailyCap: tierLimits.dailyEarningCap,
    };
});
