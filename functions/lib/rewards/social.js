"use strict";
/**
 * Social Diamond Rewards Cloud Functions
 *
 * Part of Diamond Revenue Model V5 - Social Enhancements
 * Handles server-side validation and scheduled engagement tier calculations.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateMonthlyMilestones = exports.calculateWeeklyEngagement = exports.processVoiceRoomTip = exports.grantSocialRewardFunction = void 0;
const https_1 = require("firebase-functions/v2/https");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firebase_functions_1 = require("firebase-functions");
const admin = __importStar(require("firebase-admin"));
// Lazy initialization to avoid "app not initialized" error
const getDb = () => admin.firestore();
// ============================================================================
// CONFIGURATION (Mirror of diamond_config.dart)
// ============================================================================
const SOCIAL_REWARDS = {
    host_voice_room_10_minutes: 10,
    host_voice_room_30_minutes: 25,
    voice_room_regular: 50,
    first_story_posted: 15,
    story_reached_50_views: 10,
    story_reached_100_views: 25,
    daily_story_streak_7: 50,
    game_invite_accepted: 5,
    game_invite_5_players: 25,
    voice_game_completed: 10,
    video_game_completed: 15,
};
const DAILY_CAPS = {
    voice_room_hosting: 50,
    story_views: 50,
    chat_activity: 30,
    game_invites: 50,
};
const ENGAGEMENT_TIERS = {
    casual: { reward: 25, gamesRequired: 5, daysRequired: 3 },
    regular: { reward: 75, gamesRequired: 15, daysRequired: 5 },
    dedicated: { reward: 150, gamesRequired: 30, daysRequired: 7, requiresVoiceRoom: true },
    super_user: { reward: 300, gamesRequired: 50, daysRequired: 7, requiresVoiceRoom: true, requiresStories: true },
};
const MONTHLY_MILESTONES = {
    played_100_games: 500,
    hosted_20_voice_rooms: 300,
    posted_30_stories: 200,
    helped_10_new_players: 400,
    all_achievements_month: 1000,
};
const VOICE_ROOM_TIP_FEE = 0.05; // 5% burned
// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
function getTodayKey() {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
}
function getWeekKey() {
    const now = new Date();
    const weekNumber = Math.floor((now.getDate() - now.getDay() + 10) / 7);
    return `${now.getFullYear()}-W${weekNumber}`;
}
function getMonthKey() {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
}
async function getDailyRewardTotal(userId, category, dateKey) {
    const rewards = await getDb().collection('diamond_rewards')
        .where('userId', '==', userId)
        .where('category', '==', category)
        .where('dateKey', '==', dateKey)
        .get();
    let total = 0;
    rewards.docs.forEach(doc => {
        total += (doc.data().amount || 0);
    });
    return total;
}
async function grantSocialReward(params) {
    if (params.amount <= 0)
        return;
    const batch = getDb().batch();
    // Create reward record
    const rewardRef = getDb().collection('diamond_rewards').doc();
    batch.set(rewardRef, {
        userId: params.userId,
        type: params.type,
        category: params.category,
        amount: params.amount,
        description: params.description,
        dateKey: params.dateKey || null,
        weekKey: params.weekKey || null,
        monthKey: params.monthKey || null,
        metadata: params.metadata || null,
        claimedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Update wallet balance
    const walletRef = getDb().collection('wallets').doc(params.userId);
    batch.update(walletRef, {
        balance: admin.firestore.FieldValue.increment(params.amount),
        totalEarned: admin.firestore.FieldValue.increment(params.amount),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Record transaction
    const txRef = getDb().collection('transactions').doc();
    batch.set(txRef, {
        userId: params.userId,
        amount: params.amount,
        type: 'social_reward',
        rewardType: params.type,
        description: params.description,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    firebase_functions_1.logger.info(`Social reward granted: ${params.amount}💎 (${params.type}) to ${params.userId}`);
}
// ============================================================================
// CALLABLE FUNCTIONS
// ============================================================================
/**
 * Generic social reward granting function
 * Called by client after completing a social action
 */
exports.grantSocialRewardFunction = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be logged in');
    }
    const userId = request.auth.uid;
    const { rewardType, metadata } = request.data;
    const today = getTodayKey();
    // Validate reward type
    const rewardAmount = SOCIAL_REWARDS[rewardType];
    if (!rewardAmount) {
        throw new https_1.HttpsError('invalid-argument', 'Invalid reward type');
    }
    // Determine category for capping
    let category = 'general';
    if (rewardType.includes('voice_room'))
        category = 'voice_room_hosting';
    else if (rewardType.includes('story'))
        category = 'story_views';
    else if (rewardType.includes('game_invite'))
        category = 'game_invites';
    else if (rewardType.includes('chat'))
        category = 'chat_activity';
    // Check daily cap
    const cap = DAILY_CAPS[category] || 999;
    const todayTotal = await getDailyRewardTotal(userId, category, today);
    if (todayTotal >= cap) {
        return { success: false, reason: `Daily cap reached for ${category}` };
    }
    // Apply cap
    const remaining = cap - todayTotal;
    const cappedReward = Math.min(rewardAmount, remaining);
    await grantSocialReward({
        userId,
        type: rewardType,
        category,
        amount: cappedReward,
        description: `Social reward: ${rewardType}`,
        dateKey: today,
        metadata,
    });
    return { success: true, amount: cappedReward };
});
/**
 * Process voice room tip with 5% platform fee
 */
exports.processVoiceRoomTip = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Must be logged in');
    }
    const senderId = request.auth.uid;
    const { receiverId, amount, roomId } = request.data;
    // Validate
    if (!receiverId || !amount || amount < 5) {
        throw new https_1.HttpsError('invalid-argument', 'Invalid tip parameters');
    }
    // Check sender balance
    const senderWallet = await getDb().collection('wallets').doc(senderId).get();
    const senderBalance = (senderWallet.data()?.balance || 0);
    if (senderBalance < amount) {
        return { success: false, reason: 'Insufficient balance' };
    }
    // Calculate fee
    const fee = Math.floor(amount * VOICE_ROOM_TIP_FEE);
    const netAmount = amount - fee;
    // Execute transaction
    const batch = getDb().batch();
    batch.update(getDb().collection('wallets').doc(senderId), {
        balance: admin.firestore.FieldValue.increment(-amount),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.update(getDb().collection('wallets').doc(receiverId), {
        balance: admin.firestore.FieldValue.increment(netAmount),
        totalEarned: admin.firestore.FieldValue.increment(netAmount),
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    const txRef = getDb().collection('transactions').doc();
    batch.set(txRef, {
        type: 'voice_room_tip',
        senderId,
        receiverId,
        amount,
        fee,
        netAmount,
        roomId: roomId || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    firebase_functions_1.logger.info(`Voice room tip: ${amount}💎 from ${senderId} to ${receiverId} (fee: ${fee})`);
    return {
        success: true,
        grossAmount: amount,
        fee,
        netAmount,
        showAnimation: amount >= 50,
        isSuperTip: amount >= 100,
    };
});
// ============================================================================
// SCHEDULED FUNCTIONS
// ============================================================================
/**
 * Weekly engagement tier calculation
 * Runs every Sunday at 23:00 UTC
 */
exports.calculateWeeklyEngagement = (0, scheduler_1.onSchedule)({ schedule: '0 23 * * 0', timeZone: 'UTC' }, async () => {
    firebase_functions_1.logger.info('Starting weekly engagement calculation');
    const weekKey = getWeekKey();
    // Get all users with activity this week
    const usersWithActivity = await getDb().collection('users')
        .where('lastActivityWeek', '==', weekKey)
        .get();
    let processedCount = 0;
    for (const userDoc of usersWithActivity.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        // Get weekly stats (simplified - will be tracked in socialStats subcollection)
        const weeklyStats = userData.weeklyStats?.[weekKey] || {
            gamesPlayed: 0,
            daysActive: 0,
            hostedVoiceRooms: false,
            postedStories: false,
            helpedNewPlayers: false,
        };
        // Determine highest qualifying tier
        let qualifyingTier = null;
        let tierReward = 0;
        for (const [tierKey, tier] of Object.entries(ENGAGEMENT_TIERS)) {
            if (weeklyStats.gamesPlayed >= tier.gamesRequired &&
                weeklyStats.daysActive >= tier.daysRequired) {
                // Check additional requirements
                if ('requiresVoiceRoom' in tier && tier.requiresVoiceRoom && !weeklyStats.hostedVoiceRooms)
                    continue;
                if ('requiresStories' in tier && tier.requiresStories && !weeklyStats.postedStories)
                    continue;
                qualifyingTier = tierKey;
                tierReward = tier.reward;
            }
        }
        if (qualifyingTier && tierReward > 0) {
            // Check if already claimed
            const existingClaim = await getDb().collection('diamond_rewards')
                .where('userId', '==', userId)
                .where('type', '==', 'weekly_engagement')
                .where('weekKey', '==', weekKey)
                .limit(1)
                .get();
            if (existingClaim.empty) {
                await grantSocialReward({
                    userId,
                    type: 'weekly_engagement',
                    category: 'engagement',
                    amount: tierReward,
                    description: `Weekly ${qualifyingTier} tier reward`,
                    weekKey,
                    metadata: { tier: qualifyingTier },
                });
                processedCount++;
            }
        }
    }
    firebase_functions_1.logger.info(`Weekly engagement complete: ${processedCount} users rewarded`);
});
/**
 * Monthly milestone calculation
 * Runs on the 1st of each month at 00:30 UTC
 */
exports.calculateMonthlyMilestones = (0, scheduler_1.onSchedule)({ schedule: '30 0 1 * *', timeZone: 'UTC' }, async () => {
    // Get previous month key
    const now = new Date();
    const prevMonth = now.getMonth() === 0 ? 12 : now.getMonth();
    const prevYear = now.getMonth() === 0 ? now.getFullYear() - 1 : now.getFullYear();
    const monthKey = `${prevYear}-${String(prevMonth).padStart(2, '0')}`;
    firebase_functions_1.logger.info(`Starting monthly milestone calculation for ${monthKey}`);
    // Get users with monthly stats
    const usersWithStats = await getDb().collection('users')
        .where('lastActiveMonth', '==', monthKey)
        .get();
    let processedCount = 0;
    for (const userDoc of usersWithStats.docs) {
        const userId = userDoc.id;
        const monthlyStats = userDoc.data().monthlyStats?.[monthKey] || {};
        // Check each milestone
        const milestonesToGrant = [];
        if (monthlyStats.gamesPlayed >= 100) {
            milestonesToGrant.push('played_100_games');
        }
        if (monthlyStats.voiceRoomsHosted >= 20) {
            milestonesToGrant.push('hosted_20_voice_rooms');
        }
        if (monthlyStats.storiesPosted >= 30) {
            milestonesToGrant.push('posted_30_stories');
        }
        if (monthlyStats.newPlayersHelped >= 10) {
            milestonesToGrant.push('helped_10_new_players');
        }
        for (const milestone of milestonesToGrant) {
            const reward = MONTHLY_MILESTONES[milestone];
            if (!reward)
                continue;
            // Check if already claimed
            const existingClaim = await getDb().collection('diamond_rewards')
                .where('userId', '==', userId)
                .where('type', '==', 'monthly_milestone')
                .where('monthKey', '==', monthKey)
                .where('metadata.milestone', '==', milestone)
                .limit(1)
                .get();
            if (existingClaim.empty) {
                await grantSocialReward({
                    userId,
                    type: 'monthly_milestone',
                    category: 'engagement',
                    amount: reward,
                    description: `Monthly milestone: ${milestone}`,
                    monthKey,
                    metadata: { milestone },
                });
                processedCount++;
            }
        }
    }
    firebase_functions_1.logger.info(`Monthly milestones complete: ${processedCount} rewards granted`);
});
//# sourceMappingURL=social.js.map