"use strict";
/**
 * Gameplay Reward Granting
 *
 * Securely grants diamonds for gameplay wins.
 * - Anti-cheat verification
 * - Tier-based daily earning caps
 * - Origin tracking (weighted higher for governance)
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.grantGameplayReward = void 0;
const https_1 = require("firebase-functions/v2/https");
const config_1 = require("./config");
const utils_1 = require("./utils");
exports.grantGameplayReward = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'Must be logged in');
    }
    const data = request.data;
    const { gameType, result, gameId } = data;
    // 1. Verify game result (anti-cheat)
    // In a real implementation this checks the game state in Firestore
    const gameVerification = await (0, utils_1.verifyGameResult)(gameId, userId, result);
    if (!gameVerification.verified) {
        console.warn(`[CHEAT ATTEMPT] User ${userId} tried to claim invalid reward for game ${gameId}`);
        throw new https_1.HttpsError('invalid-argument', 'Invalid game result or reward already claimed');
    }
    // 2. Calculate reward
    // e.g. 'callbreak_win' or 'teenPatti_showdown'
    const rewardKey = `${gameType}_${result}`;
    const rewardAmount = config_1.GAMEPLAY_REWARDS[rewardKey] || 0;
    if (rewardAmount === 0) {
        return { success: true, earned: 0 };
    }
    // 3. Check daily earning cap
    const user = await (0, utils_1.getUser)(userId);
    const userTier = (user.tier || 'basic');
    const tierLimits = config_1.TIER_LIMITS[userTier];
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
    await (0, utils_1.grantDiamondsToUser)(userId, actualReward, 'gameplayWin', `Won ${gameType} (${result})`);
    return {
        success: true,
        earned: actualReward,
        dailyTotal: todayEarned + actualReward,
        dailyCap: tierLimits.dailyEarningCap,
    };
});
//# sourceMappingURL=grantGameplayReward.js.map