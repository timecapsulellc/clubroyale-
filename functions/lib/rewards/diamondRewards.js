"use strict";
/**
 * Diamond Rewards Cloud Functions
 *
 * Handles reward validation and granting for:
 * - Signup bonuses (triggered on user creation)
 * - Daily login claims
 * - Ad watch rewards
 * - Game completion rewards
 * - Referral bonuses
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.processReferral = exports.grantGameReward = exports.claimAdReward = exports.claimDailyLogin = exports.grantSignupBonus = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("firebase-admin/firestore");
const db = (0, firestore_2.getFirestore)();
// Configuration
const DIAMOND_CONFIG = {
    signupBonus: 100,
    dailyLogin: 10,
    perAdWatch: 20,
    perGameComplete: 5,
    referralBonus: 50,
    weeklyBonus: 100,
    maxAdsPerDay: 6,
    maxGamesPerDay: 15,
    maxReferralsPerMonth: 20,
};
/**
 * Grant signup bonus when a new user is created
 */
exports.grantSignupBonus = (0, firestore_1.onDocumentCreated)('users/{userId}', async (event) => {
    const userId = event.params.userId;
    const userData = event.data?.data();
    if (!userData)
        return;
    // Check if wallet already exists (shouldn't happen for new user)
    const walletDoc = await db.collection('wallets').doc(userId).get();
    if (walletDoc.exists) {
        console.log(`Wallet already exists for user ${userId}`);
        return;
    }
    // Create wallet with signup bonus
    await db.collection('wallets').doc(userId).set({
        userId: userId,
        balance: DIAMOND_CONFIG.signupBonus,
        totalEarned: DIAMOND_CONFIG.signupBonus,
        totalSpent: 0,
        totalTransferredIn: 0,
        totalTransferredOut: 0,
        escrowedBalance: 0,
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    // Record the reward
    await db.collection('diamond_rewards').add({
        userId: userId,
        type: 'signup',
        amount: DIAMOND_CONFIG.signupBonus,
        description: 'Welcome signup bonus',
        claimedAt: firestore_2.FieldValue.serverTimestamp(),
    });
    // Record transaction
    await db.collection('transactions').add({
        userId: userId,
        amount: DIAMOND_CONFIG.signupBonus,
        type: 'reward',
        rewardType: 'signup',
        description: 'Welcome signup bonus',
        createdAt: firestore_2.FieldValue.serverTimestamp(),
    });
    console.log(`Signup bonus granted to ${userId}: ${DIAMOND_CONFIG.signupBonus} diamonds`);
});
/**
 * Claim daily login bonus (callable)
 */
exports.claimDailyLogin = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const today = getTodayKey();
    // Check if already claimed today
    const existing = await db
        .collection('diamond_rewards')
        .where('userId', '==', userId)
        .where('type', '==', 'daily_login')
        .where('dateKey', '==', today)
        .limit(1)
        .get();
    if (!existing.empty) {
        return { success: false, reason: 'Already claimed today' };
    }
    // Grant the reward
    const batch = db.batch();
    const rewardRef = db.collection('diamond_rewards').doc();
    batch.set(rewardRef, {
        userId: userId,
        type: 'daily_login',
        amount: DIAMOND_CONFIG.dailyLogin,
        description: 'Daily login bonus',
        dateKey: today,
        claimedAt: firestore_2.FieldValue.serverTimestamp(),
    });
    const walletRef = db.collection('wallets').doc(userId);
    batch.update(walletRef, {
        balance: firestore_2.FieldValue.increment(DIAMOND_CONFIG.dailyLogin),
        totalEarned: firestore_2.FieldValue.increment(DIAMOND_CONFIG.dailyLogin),
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    const txRef = db.collection('transactions').doc();
    batch.set(txRef, {
        userId: userId,
        amount: DIAMOND_CONFIG.dailyLogin,
        type: 'reward',
        rewardType: 'daily_login',
        description: 'Daily login bonus',
        createdAt: firestore_2.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return { success: true, amount: DIAMOND_CONFIG.dailyLogin };
});
/**
 * Claim ad watch reward (callable)
 */
exports.claimAdReward = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const { adId } = request.data;
    if (!adId) {
        throw new https_1.HttpsError('invalid-argument', 'Ad ID is required');
    }
    const today = getTodayKey();
    // Check daily limit
    const todayAds = await db
        .collection('diamond_rewards')
        .where('userId', '==', userId)
        .where('type', '==', 'ad_watch')
        .where('dateKey', '==', today)
        .get();
    if (todayAds.docs.length >= DIAMOND_CONFIG.maxAdsPerDay) {
        return {
            success: false,
            reason: `Maximum ads for today reached (${DIAMOND_CONFIG.maxAdsPerDay})`,
        };
    }
    // Grant the reward
    const batch = db.batch();
    const rewardRef = db.collection('diamond_rewards').doc();
    batch.set(rewardRef, {
        userId: userId,
        type: 'ad_watch',
        amount: DIAMOND_CONFIG.perAdWatch,
        description: 'Watched ad reward',
        dateKey: today,
        metadata: { adId },
        claimedAt: firestore_2.FieldValue.serverTimestamp(),
    });
    const walletRef = db.collection('wallets').doc(userId);
    batch.update(walletRef, {
        balance: firestore_2.FieldValue.increment(DIAMOND_CONFIG.perAdWatch),
        totalEarned: firestore_2.FieldValue.increment(DIAMOND_CONFIG.perAdWatch),
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return {
        success: true,
        amount: DIAMOND_CONFIG.perAdWatch,
        remaining: DIAMOND_CONFIG.maxAdsPerDay - todayAds.docs.length - 1,
    };
});
/**
 * Grant game completion reward (triggered on game status change)
 */
exports.grantGameReward = (0, firestore_1.onDocumentUpdated)('games/{gameId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after)
        return;
    // Only trigger when game status changes to 'finished'
    if (before.status === after.status || after.status !== 'finished') {
        return;
    }
    const players = after.players || [];
    const today = getTodayKey();
    for (const player of players) {
        const playerId = player.id;
        if (!playerId || player.isBot)
            continue;
        // Check daily limit
        const todayGames = await db
            .collection('diamond_rewards')
            .where('userId', '==', playerId)
            .where('type', '==', 'game_complete')
            .where('dateKey', '==', today)
            .get();
        if (todayGames.docs.length >= DIAMOND_CONFIG.maxGamesPerDay) {
            console.log(`Player ${playerId} hit daily game reward limit`);
            continue;
        }
        // Grant reward
        const batch = db.batch();
        const rewardRef = db.collection('diamond_rewards').doc();
        batch.set(rewardRef, {
            userId: playerId,
            type: 'game_complete',
            amount: DIAMOND_CONFIG.perGameComplete,
            description: 'Game completion reward',
            dateKey: today,
            metadata: { gameId: event.params.gameId },
            claimedAt: firestore_2.FieldValue.serverTimestamp(),
        });
        const walletRef = db.collection('wallets').doc(playerId);
        batch.update(walletRef, {
            balance: firestore_2.FieldValue.increment(DIAMOND_CONFIG.perGameComplete),
            totalEarned: firestore_2.FieldValue.increment(DIAMOND_CONFIG.perGameComplete),
            lastUpdated: firestore_2.FieldValue.serverTimestamp(),
        });
        await batch.commit();
        console.log(`Game reward granted to ${playerId}`);
    }
});
/**
 * Process referral bonus when new user joins with referral code
 */
exports.processReferral = (0, firestore_1.onDocumentCreated)('referrals/{referralId}', async (event) => {
    const data = event.data?.data();
    if (!data)
        return;
    const referrerId = data.referrerId;
    const newUserId = data.newUserId;
    const monthKey = getMonthKey();
    // Check monthly limit
    const monthlyReferrals = await db
        .collection('diamond_rewards')
        .where('userId', '==', referrerId)
        .where('type', '==', 'referral')
        .where('monthKey', '==', monthKey)
        .get();
    if (monthlyReferrals.docs.length >= DIAMOND_CONFIG.maxReferralsPerMonth) {
        console.log(`Referrer ${referrerId} hit monthly referral limit`);
        return;
    }
    // Grant reward
    const batch = db.batch();
    const rewardRef = db.collection('diamond_rewards').doc();
    batch.set(rewardRef, {
        userId: referrerId,
        type: 'referral',
        amount: DIAMOND_CONFIG.referralBonus,
        description: 'Referral bonus',
        monthKey: monthKey,
        metadata: { referredUserId: newUserId },
        claimedAt: firestore_2.FieldValue.serverTimestamp(),
    });
    const walletRef = db.collection('wallets').doc(referrerId);
    batch.update(walletRef, {
        balance: firestore_2.FieldValue.increment(DIAMOND_CONFIG.referralBonus),
        totalEarned: firestore_2.FieldValue.increment(DIAMOND_CONFIG.referralBonus),
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    console.log(`Referral bonus granted to ${referrerId} for referring ${newUserId}`);
});
// Helper functions
function getTodayKey() {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
}
function getMonthKey() {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}
//# sourceMappingURL=diamondRewards.js.map