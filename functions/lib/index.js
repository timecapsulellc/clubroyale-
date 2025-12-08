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
exports.processSettlement = exports.validateMove = exports.validateBid = exports.onFriendRequestCreated = exports.onInviteCreated = exports.getMatchSuggestions = exports.getBidSuggestion = exports.moderateChat = exports.getBotPlay = exports.getGameTip = exports.validateSpectatorAccess = exports.generateLiveKitToken = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const app_1 = require("firebase-admin/app");
const firestore_2 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
// Import Genkit flows
const gameTipFlow_1 = require("./genkit/flows/gameTipFlow");
const botPlayFlow_1 = require("./genkit/flows/botPlayFlow");
const moderationFlow_1 = require("./genkit/flows/moderationFlow");
const bidSuggestionFlow_1 = require("./genkit/flows/bidSuggestionFlow");
const matchmakingFlow_1 = require("./genkit/flows/matchmakingFlow");
// Export LiveKit token functions
var tokenService_1 = require("./livekit/tokenService");
Object.defineProperty(exports, "generateLiveKitToken", { enumerable: true, get: function () { return tokenService_1.generateLiveKitToken; } });
Object.defineProperty(exports, "validateSpectatorAccess", { enumerable: true, get: function () { return tokenService_1.validateSpectatorAccess; } });
// Initialize Firebase Admin
(0, app_1.initializeApp)();
const db = (0, firestore_2.getFirestore)();
const messaging = (0, messaging_1.getMessaging)();
// =====================================================
// GENKIT AI FUNCTIONS
// =====================================================
/**
 * Get AI-powered game tip for current play
 */
exports.getGameTip = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const input = request.data;
    // Validate required fields
    if (!input.hand || !Array.isArray(input.hand) || input.hand.length === 0) {
        throw new https_1.HttpsError('invalid-argument', 'Hand is required');
    }
    try {
        const result = await (0, gameTipFlow_1.gameTipFlow)(input);
        return { success: true, ...result };
    }
    catch (error) {
        console.error('Game tip error:', error);
        throw new https_1.HttpsError('internal', 'Failed to generate game tip');
    }
});
/**
 * Get AI bot's card selection
 */
exports.getBotPlay = (0, https_1.onCall)(async (request) => {
    const input = request.data;
    if (!input.hand || !Array.isArray(input.hand) || input.hand.length === 0) {
        throw new https_1.HttpsError('invalid-argument', 'Hand is required');
    }
    try {
        const result = await (0, botPlayFlow_1.botPlayFlow)(input);
        return { success: true, ...result };
    }
    catch (error) {
        console.error('Bot play error:', error);
        throw new https_1.HttpsError('internal', 'Failed to get bot play');
    }
});
/**
 * Moderate a chat message
 */
exports.moderateChat = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const input = request.data;
    if (!input.message || typeof input.message !== 'string') {
        throw new https_1.HttpsError('invalid-argument', 'Message is required');
    }
    try {
        const result = await (0, moderationFlow_1.moderationFlow)(input);
        // Log blocked messages for review
        if (!result.isAllowed) {
            await db.collection('moderation_logs').add({
                userId,
                message: input.message,
                roomId: input.roomId,
                result,
                timestamp: firestore_2.FieldValue.serverTimestamp(),
            });
        }
        return { success: true, ...result };
    }
    catch (error) {
        console.error('Moderation error:', error);
        // Default to allow on error (better UX)
        return { success: true, isAllowed: true, category: 'clean', action: 'allow' };
    }
});
/**
 * Get AI-powered bid suggestion
 */
exports.getBidSuggestion = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const input = request.data;
    if (!input.hand || input.hand.length !== 13) {
        throw new https_1.HttpsError('invalid-argument', 'Hand must contain exactly 13 cards');
    }
    try {
        const result = await (0, bidSuggestionFlow_1.bidSuggestionFlow)(input);
        return { success: true, ...result };
    }
    catch (error) {
        console.error('Bid suggestion error:', error);
        throw new https_1.HttpsError('internal', 'Failed to generate bid suggestion');
    }
});
/**
 * Get AI-powered matchmaking suggestions
 */
exports.getMatchSuggestions = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    const input = request.data;
    if (!input.gameType) {
        throw new https_1.HttpsError('invalid-argument', 'Game type is required');
    }
    try {
        const result = await (0, matchmakingFlow_1.matchmakingFlow)({
            ...input,
            userId: userId,
        });
        return { success: true, ...result };
    }
    catch (error) {
        console.error('Matchmaking error:', error);
        return {
            success: true,
            suggestions: [],
            reasoning: 'Matchmaking temporarily unavailable',
            waitTimeEstimate: 30,
        };
    }
});
// =====================================================
// FCM PUSH NOTIFICATIONS
// =====================================================
/**
 * Send push notification when a game invite is created
 */
exports.onInviteCreated = (0, firestore_1.onDocumentCreated)('invites/{inviteId}', async (event) => {
    const invite = event.data?.data();
    if (!invite)
        return;
    const toUserId = invite.toUserId;
    const fromName = invite.fromDisplayName || 'Someone';
    const gameType = invite.gameType || 'a game';
    // Get the recipient's FCM token
    const userDoc = await db.collection('users').doc(toUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken) {
        console.log(`No FCM token for user ${toUserId}`);
        return;
    }
    // Send the notification
    try {
        await messaging.send({
            token: fcmToken,
            notification: {
                title: 'Game Invitation! 🎮',
                body: `${fromName} invited you to play ${gameType}`,
            },
            data: {
                type: 'game_invite',
                inviteId: event.params.inviteId,
                roomId: invite.roomId || '',
                gameType: gameType,
            },
            android: {
                priority: 'high',
                notification: {
                    channelId: 'game_invites',
                    icon: 'ic_notification',
                },
            },
            webpush: {
                notification: {
                    icon: '/icons/icon-192.png',
                    badge: '/icons/icon-72.png',
                },
            },
        });
        console.log(`Notification sent to ${toUserId}`);
    }
    catch (error) {
        console.error('FCM send error:', error);
    }
});
/**
 * Send push notification for friend request
 */
exports.onFriendRequestCreated = (0, firestore_1.onDocumentCreated)('friendRequests/{requestId}', async (event) => {
    const request = event.data?.data();
    if (!request)
        return;
    const toUserId = request.toUserId;
    const fromName = request.fromDisplayName || 'Someone';
    // Get the recipient's FCM token
    const userDoc = await db.collection('users').doc(toUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken)
        return;
    try {
        await messaging.send({
            token: fcmToken,
            notification: {
                title: 'Friend Request! 👋',
                body: `${fromName} wants to be your friend`,
            },
            data: {
                type: 'friend_request',
                requestId: event.params.requestId,
            },
        });
    }
    catch (error) {
        console.error('FCM send error:', error);
    }
});
// =====================================================
// EXISTING ANTI-CHEAT FUNCTIONS
// =====================================================
/**
 * Card suits and their properties
 */
const SUITS = {
    spades: { symbol: '♠', isRed: false, isTrump: true },
    hearts: { symbol: '♥', isRed: true, isTrump: false },
    diamonds: { symbol: '♦', isRed: true, isTrump: false },
    clubs: { symbol: '♣', isRed: false, isTrump: false },
};
/**
 * Card rank values (Ace high)
 */
const RANK_VALUES = {
    '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
    '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14,
};
/**
 * Validate a bid in Call Break
 */
exports.validateBid = (0, https_1.onCall)(async (request) => {
    const { gameId, bid } = request.data;
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    if (!Number.isInteger(bid) || bid < 1 || bid > 13) {
        throw new https_1.HttpsError('invalid-argument', 'Bid must be between 1 and 13');
    }
    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();
    if (!gameDoc.exists) {
        throw new https_1.HttpsError('not-found', 'Game not found');
    }
    const game = gameDoc.data();
    const playerIds = game.players?.map((p) => p.id) || Object.keys(game.scores || {});
    if (!playerIds.includes(userId)) {
        throw new https_1.HttpsError('permission-denied', 'You are not in this game');
    }
    if (game.currentTurn !== userId) {
        throw new https_1.HttpsError('failed-precondition', 'Not your turn to bid');
    }
    if (game.gamePhase !== 'bidding') {
        throw new https_1.HttpsError('failed-precondition', 'Game is not in bidding phase');
    }
    const bids = game.bids || {};
    if (bids[userId] !== undefined && bids[userId] !== null) {
        throw new https_1.HttpsError('already-exists', 'You have already bid this round');
    }
    return { success: true, message: 'Bid is valid' };
});
/**
 * Validate a card move in Call Break
 */
exports.validateMove = (0, https_1.onCall)(async (request) => {
    const { gameId, card } = request.data;
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    if (!card || !card.suit || !card.rank) {
        throw new https_1.HttpsError('invalid-argument', 'Invalid card format');
    }
    if (!SUITS[card.suit]) {
        throw new https_1.HttpsError('invalid-argument', `Invalid suit: ${card.suit}`);
    }
    if (!RANK_VALUES[card.rank]) {
        throw new https_1.HttpsError('invalid-argument', `Invalid rank: ${card.rank}`);
    }
    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();
    if (!gameDoc.exists) {
        throw new https_1.HttpsError('not-found', 'Game not found');
    }
    const game = gameDoc.data();
    const playerIds = game.players?.map((p) => p.id) || Object.keys(game.scores || {});
    if (!playerIds.includes(userId)) {
        throw new https_1.HttpsError('permission-denied', 'You are not in this game');
    }
    if (game.currentTurn !== userId) {
        throw new https_1.HttpsError('failed-precondition', 'Not your turn to play');
    }
    if (game.gamePhase !== 'playing') {
        throw new https_1.HttpsError('failed-precondition', 'Game is not in playing phase');
    }
    const playerHands = game.playerHands || {};
    const hand = playerHands[userId] || [];
    const hasCard = hand.some((c) => c.suit === card.suit && c.rank === card.rank);
    if (!hasCard) {
        throw new https_1.HttpsError('failed-precondition', "You don't have this card");
    }
    const currentTrick = game.currentTrick || [];
    if (currentTrick.length > 0) {
        const ledSuit = currentTrick[0].suit;
        const hasLedSuit = hand.some((c) => c.suit === ledSuit);
        if (hasLedSuit && card.suit !== ledSuit) {
            throw new https_1.HttpsError('failed-precondition', `Must follow suit: ${ledSuit}`);
        }
    }
    return { success: true, message: 'Move is valid' };
});
/**
 * Process settlement after game ends
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
        const debtorWalletRef = db.collection('wallets').doc(settlement.from);
        batch.update(debtorWalletRef, {
            balance: firestore_2.FieldValue.increment(-settlement.amount),
        });
        const creditorWalletRef = db.collection('wallets').doc(settlement.to);
        batch.update(creditorWalletRef, {
            balance: firestore_2.FieldValue.increment(settlement.amount),
        });
        const txRef = db.collection('transactions').doc();
        batch.set(txRef, {
            gameId: gameId,
            fromUserId: settlement.from,
            toUserId: settlement.to,
            amount: settlement.amount,
            type: 'settlement',
            timestamp: firestore_2.FieldValue.serverTimestamp(),
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