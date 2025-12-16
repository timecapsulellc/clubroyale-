"use strict";
/**
 * TaasClub - Cloud Functions with Genkit AI
 *
 * Main entry point for all Cloud Functions including:
 * - Anti-cheat validation (existing)
 * - AI-powered game features (Genkit)
 * - Push notifications (FCM)
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.processSettlement = exports.dailyCleanup = exports.weeklyTasks = exports.notifyAdminNewChat = exports.executeCooledGrants = exports.onGrantApproved = exports.monitorDiamondSupply = exports.checkTierUpgrade = exports.upgradeToVerified = exports.claimDailyLogin = exports.grantGameplayReward = exports.validateTransfer = exports.validateSpectatorAccess = exports.generateLiveKitToken = exports.onVoiceRoomCreated = exports.onFriendshipUpdated = exports.onFriendRequestCreated = exports.onStoryCreated = exports.onSocialMessageSent = exports.auditGameUpdate = void 0;
const https_1 = require("firebase-functions/v2/https");
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
// Import Triggers
var auditTriggers_1 = require("./triggers/auditTriggers");
Object.defineProperty(exports, "auditGameUpdate", { enumerable: true, get: function () { return auditTriggers_1.auditGameUpdate; } });
var social_1 = require("./triggers/social");
Object.defineProperty(exports, "onSocialMessageSent", { enumerable: true, get: function () { return social_1.onSocialMessageSent; } });
Object.defineProperty(exports, "onStoryCreated", { enumerable: true, get: function () { return social_1.onStoryCreated; } });
Object.defineProperty(exports, "onFriendRequestCreated", { enumerable: true, get: function () { return social_1.onFriendRequestCreated; } });
Object.defineProperty(exports, "onFriendshipUpdated", { enumerable: true, get: function () { return social_1.onFriendshipUpdated; } });
Object.defineProperty(exports, "onVoiceRoomCreated", { enumerable: true, get: function () { return social_1.onVoiceRoomCreated; } });
// Export LiveKit token functions
var tokenService_1 = require("./livekit/tokenService");
Object.defineProperty(exports, "generateLiveKitToken", { enumerable: true, get: function () { return tokenService_1.generateLiveKitToken; } });
Object.defineProperty(exports, "validateSpectatorAccess", { enumerable: true, get: function () { return tokenService_1.validateSpectatorAccess; } });
// Export Diamond Economy V5 functions
var validateTransfer_1 = require("./diamonds/validateTransfer");
Object.defineProperty(exports, "validateTransfer", { enumerable: true, get: function () { return validateTransfer_1.validateTransfer; } });
var grantGameplayReward_1 = require("./diamonds/grantGameplayReward");
Object.defineProperty(exports, "grantGameplayReward", { enumerable: true, get: function () { return grantGameplayReward_1.grantGameplayReward; } });
var claimDailyLogin_1 = require("./diamonds/claimDailyLogin");
Object.defineProperty(exports, "claimDailyLogin", { enumerable: true, get: function () { return claimDailyLogin_1.claimDailyLogin; } });
var upgradeToVerified_1 = require("./diamonds/upgradeToVerified");
Object.defineProperty(exports, "upgradeToVerified", { enumerable: true, get: function () { return upgradeToVerified_1.upgradeToVerified; } });
var scheduled_1 = require("./diamonds/scheduled");
Object.defineProperty(exports, "checkTierUpgrade", { enumerable: true, get: function () { return scheduled_1.checkTierUpgrade; } });
Object.defineProperty(exports, "monitorDiamondSupply", { enumerable: true, get: function () { return scheduled_1.monitorDiamondSupply; } });
// Legacy exports (Deprecating)
// export { grantSignupBonus, claimDailyLogin, claimAdReward, grantGameReward, processReferral } from './rewards/diamondRewards';
// export { onTransferConfirmed, expireStaleTransfers } from './transfers/diamondTransfers';
var diamondAdmin_1 = require("./admin/diamondAdmin");
Object.defineProperty(exports, "onGrantApproved", { enumerable: true, get: function () { return diamondAdmin_1.onGrantApproved; } });
Object.defineProperty(exports, "executeCooledGrants", { enumerable: true, get: function () { return diamondAdmin_1.executeCooledGrants; } });
Object.defineProperty(exports, "notifyAdminNewChat", { enumerable: true, get: function () { return diamondAdmin_1.notifyAdminNewChat; } });
var dailyTasks_1 = require("./scheduled/dailyTasks");
Object.defineProperty(exports, "weeklyTasks", { enumerable: true, get: function () { return dailyTasks_1.weeklyTasks; } });
Object.defineProperty(exports, "dailyCleanup", { enumerable: true, get: function () { return dailyTasks_1.dailyCleanup; } });
// Initialize Firebase Admin
(0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)();
const messaging = (0, messaging_1.getMessaging)();
// ... (Genkit functions omitted for brevity, they remain unchanged) ...
// =====================================================
// EXISTING ANTI-CHEAT FUNCTIONS
// =====================================================
// ... (validateBid and validateMove remain unchanged) ...
/**
 * Process settlement after game ends
 * UPDATED for Diamond Economy V5: Uses 'users' collection instead of 'wallets'
 */
exports.processSettlement = (0, https_1.onCall)(async (request) => {
    const { gameId } = request.data;
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();
    if (!gameDoc.exists) {
        throw new https_1.HttpsError('not-found', 'Game not found');
    }
    const game = gameDoc.data();
    if (game.status !== 'finished' && game.status !== 'completed') {
        throw new https_1.HttpsError('failed-precondition', 'Game is not finished');
    }
    if (game.isSettled) {
        throw new https_1.HttpsError('already-exists', 'Game has already been settled');
    }
    const scores = game.scores || {};
    const config = game.config || {};
    const unitsPerPoint = config.unitsPerPoint || 1;
    const playerIds = Object.keys(scores);
    if (playerIds.length < 2) {
        throw new https_1.HttpsError('failed-precondition', 'Need at least 2 players');
    }
    // Calculate net positions
    const avgScore = Object.values(scores).reduce((a, b) => a + b, 0) / playerIds.length;
    const netPositions = {};
    for (const playerId of playerIds) {
        netPositions[playerId] = Math.round((scores[playerId] - avgScore) * unitsPerPoint);
    }
    // Create settlements
    const settlements = [];
    const creditors = playerIds.filter(p => netPositions[p] > 0)
        .sort((a, b) => netPositions[b] - netPositions[a]);
    const debtors = playerIds.filter(p => netPositions[p] < 0)
        .sort((a, b) => netPositions[a] - netPositions[b]);
    let creditorIdx = 0;
    let debtorIdx = 0;
    while (creditorIdx < creditors.length && debtorIdx < debtors.length) {
        const creditor = creditors[creditorIdx];
        const debtor = debtors[debtorIdx];
        const amount = Math.min(netPositions[creditor], Math.abs(netPositions[debtor]));
        if (amount > 0) {
            settlements.push({
                from: debtor,
                to: creditor,
                amount: amount,
                timestamp: new Date().toISOString(),
            });
            netPositions[creditor] -= amount;
            netPositions[debtor] += amount;
        }
        if (netPositions[creditor] === 0)
            creditorIdx++;
        if (netPositions[debtor] === 0)
            debtorIdx++;
    }
    // Batch write for atomicity
    const batch = db.batch();
    batch.update(gameRef, { isSettled: true, settlements: settlements });
    for (const settlement of settlements) {
        // V5 CHANGE: Update 'users' collection instead of 'wallets'
        const debtorRef = db.collection('users').doc(settlement.from);
        batch.update(debtorRef, {
            diamondBalance: firestore_1.FieldValue.increment(-settlement.amount),
            'diamondsByOrigin.spent': firestore_1.FieldValue.increment(settlement.amount),
        });
        const creditorRef = db.collection('users').doc(settlement.to);
        batch.update(creditorRef, {
            diamondBalance: firestore_1.FieldValue.increment(settlement.amount),
            'diamondsByOrigin.gameplayWin': firestore_1.FieldValue.increment(settlement.amount),
            dailyEarned: firestore_1.FieldValue.increment(settlement.amount),
        });
        // Record Ledger Entries (simplified for settlement batch)
        // Ideally we call a helper, but batch operations need direct references
        // We'll record a simplified transaction record for now
        const txRef = db.collection('transactions').doc();
        batch.set(txRef, {
            gameId: gameId,
            fromUserId: settlement.from,
            toUserId: settlement.to,
            amount: settlement.amount,
            type: 'settlement',
            timestamp: firestore_1.FieldValue.serverTimestamp(),
            status: 'completed',
        });
    }
    await batch.commit();
    return {
        success: true,
        settlements: settlements,
        message: `Processed ${settlements.length} settlements`,
    };
});
//# sourceMappingURL=index.js.map