/**
 * TaasClub - Cloud Functions with Genkit AI
 * 
 * Main entry point for all Cloud Functions including:
 * - Anti-cheat validation (existing)
 * - AI-powered game features (Genkit)
 * - Push notifications (FCM)
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

// Import Genkit flows
import { gameTipFlow, GameTipInput } from './genkit/flows/gameTipFlow';
import { botPlayFlow, BotPlayInput } from './genkit/flows/botPlayFlow';
import { moderationFlow, ModerationInput } from './genkit/flows/moderationFlow';
import { bidSuggestionFlow, BidSuggestionInput } from './genkit/flows/bidSuggestionFlow';
import { matchmakingFlow, MatchmakingInput } from './genkit/flows/matchmakingFlow';

// Import game-specific AI flows
import { marriageBotPlayFlow, MarriageBotInput } from './genkit/marriageBotPlayFlow';
import { callBreakBotPlayFlow, CallBreakBotInput } from './genkit/callBreakBotPlayFlow';

// Import audit service
import { AuditService, logMove, logSuspiciousActivity } from './services/auditService';

// Export LiveKit token functions
export { generateLiveKitToken, validateSpectatorAccess } from './livekit/tokenService';

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();
const messaging = getMessaging();

// =====================================================
// GENKIT AI FUNCTIONS
// =====================================================

/**
 * Get AI-powered game tip for current play
 */
export const getGameTip = onCall(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const input: GameTipInput = request.data;

    // Validate required fields
    if (!input.hand || !Array.isArray(input.hand) || input.hand.length === 0) {
        throw new HttpsError('invalid-argument', 'Hand is required');
    }

    try {
        const result = await gameTipFlow(input);
        return { success: true, ...result };
    } catch (error) {
        console.error('Game tip error:', error);
        throw new HttpsError('internal', 'Failed to generate game tip');
    }
});

/**
 * Get AI bot's card selection
 */
export const getBotPlay = onCall(async (request) => {
    const input: BotPlayInput = request.data;

    if (!input.hand || !Array.isArray(input.hand) || input.hand.length === 0) {
        throw new HttpsError('invalid-argument', 'Hand is required');
    }

    try {
        const result = await botPlayFlow(input);
        return { success: true, ...result };
    } catch (error) {
        console.error('Bot play error:', error);
        throw new HttpsError('internal', 'Failed to get bot play');
    }
});

/**
 * Moderate a chat message
 */
export const moderateChat = onCall(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const input: ModerationInput = request.data;

    if (!input.message || typeof input.message !== 'string') {
        throw new HttpsError('invalid-argument', 'Message is required');
    }

    try {
        const result = await moderationFlow(input);

        // Log blocked messages for review
        if (!result.isAllowed) {
            await db.collection('moderation_logs').add({
                userId,
                message: input.message,
                roomId: input.roomId,
                result,
                timestamp: FieldValue.serverTimestamp(),
            });
        }

        return { success: true, ...result };
    } catch (error) {
        console.error('Moderation error:', error);
        // Default to allow on error (better UX)
        return { success: true, isAllowed: true, category: 'clean', action: 'allow' };
    }
});

/**
 * Get AI-powered bid suggestion
 */
export const getBidSuggestion = onCall(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const input: BidSuggestionInput = request.data;

    if (!input.hand || input.hand.length !== 13) {
        throw new HttpsError('invalid-argument', 'Hand must contain exactly 13 cards');
    }

    try {
        const result = await bidSuggestionFlow(input);
        return { success: true, ...result };
    } catch (error) {
        console.error('Bid suggestion error:', error);
        throw new HttpsError('internal', 'Failed to generate bid suggestion');
    }
});

/**
 * Get AI-powered matchmaking suggestions
 */
export const getMatchSuggestions = onCall(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const input: MatchmakingInput = request.data;

    if (!input.gameType) {
        throw new HttpsError('invalid-argument', 'Game type is required');
    }

    try {
        const result = await matchmakingFlow({
            ...input,
            userId: userId,
        });
        return { success: true, ...result };
    } catch (error) {
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
export const onInviteCreated = onDocumentCreated('invites/{inviteId}', async (event) => {
    const invite = event.data?.data();
    if (!invite) return;

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
    } catch (error) {
        console.error('FCM send error:', error);
    }
});

/**
 * Send push notification for friend request
 */
export const onFriendRequestCreated = onDocumentCreated('friendRequests/{requestId}', async (event) => {
    const request = event.data?.data();
    if (!request) return;

    const toUserId = request.toUserId;
    const fromName = request.fromDisplayName || 'Someone';

    // Get the recipient's FCM token
    const userDoc = await db.collection('users').doc(toUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) return;

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
    } catch (error) {
        console.error('FCM send error:', error);
    }
});

// =====================================================
// EXISTING ANTI-CHEAT FUNCTIONS
// =====================================================

/**
 * Card suits and their properties
 */
const SUITS: Record<string, { symbol: string; isRed: boolean; isTrump: boolean }> = {
    spades: { symbol: '♠', isRed: false, isTrump: true },
    hearts: { symbol: '♥', isRed: true, isTrump: false },
    diamonds: { symbol: '♦', isRed: true, isTrump: false },
    clubs: { symbol: '♣', isRed: false, isTrump: false },
};

/**
 * Card rank values (Ace high)
 */
const RANK_VALUES: Record<string, number> = {
    '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
    '8': 8, '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14,
};

/**
 * Validate a bid in Call Break
 */
export const validateBid = onCall(async (request) => {
    const { gameId, bid } = request.data;
    const userId = request.auth?.uid;

    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    if (!Number.isInteger(bid) || bid < 1 || bid > 13) {
        throw new HttpsError('invalid-argument', 'Bid must be between 1 and 13');
    }

    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();

    if (!gameDoc.exists) {
        throw new HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data()!;
    const playerIds = game.players?.map((p: { id: string }) => p.id) || Object.keys(game.scores || {});

    if (!playerIds.includes(userId)) {
        throw new HttpsError('permission-denied', 'You are not in this game');
    }

    if (game.currentTurn !== userId) {
        throw new HttpsError('failed-precondition', 'Not your turn to bid');
    }

    if (game.gamePhase !== 'bidding') {
        throw new HttpsError('failed-precondition', 'Game is not in bidding phase');
    }

    const bids = game.bids || {};
    if (bids[userId] !== undefined && bids[userId] !== null) {
        throw new HttpsError('already-exists', 'You have already bid this round');
    }

    return { success: true, message: 'Bid is valid' };
});

/**
 * Validate a card move in Call Break
 */
export const validateMove = onCall(async (request) => {
    const { gameId, card } = request.data;
    const userId = request.auth?.uid;

    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    if (!card || !card.suit || !card.rank) {
        throw new HttpsError('invalid-argument', 'Invalid card format');
    }

    if (!SUITS[card.suit]) {
        throw new HttpsError('invalid-argument', `Invalid suit: ${card.suit}`);
    }

    if (!RANK_VALUES[card.rank]) {
        throw new HttpsError('invalid-argument', `Invalid rank: ${card.rank}`);
    }

    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();

    if (!gameDoc.exists) {
        throw new HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data()!;
    const playerIds = game.players?.map((p: { id: string }) => p.id) || Object.keys(game.scores || {});

    if (!playerIds.includes(userId)) {
        throw new HttpsError('permission-denied', 'You are not in this game');
    }

    if (game.currentTurn !== userId) {
        throw new HttpsError('failed-precondition', 'Not your turn to play');
    }

    if (game.gamePhase !== 'playing') {
        throw new HttpsError('failed-precondition', 'Game is not in playing phase');
    }

    const playerHands = game.playerHands || {};
    const hand = playerHands[userId] || [];

    const hasCard = hand.some((c: { suit: string; rank: string }) =>
        c.suit === card.suit && c.rank === card.rank
    );

    if (!hasCard) {
        throw new HttpsError('failed-precondition', "You don't have this card");
    }

    const currentTrick = game.currentTrick || [];

    if (currentTrick.length > 0) {
        const ledSuit = currentTrick[0].suit;
        const hasLedSuit = hand.some((c: { suit: string }) => c.suit === ledSuit);

        if (hasLedSuit && card.suit !== ledSuit) {
            throw new HttpsError('failed-precondition', `Must follow suit: ${ledSuit}`);
        }
    }

    return { success: true, message: 'Move is valid' };
});

/**
 * Process settlement after game ends
 */
export const processSettlement = onCall(async (request) => {
    const { gameId } = request.data;
    const userId = request.auth?.uid;

    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    const gameRef = db.collection('games').doc(gameId);
    const gameDoc = await gameRef.get();

    if (!gameDoc.exists) {
        throw new HttpsError('not-found', 'Game not found');
    }

    const game = gameDoc.data()!;

    if (game.status !== 'finished' && game.status !== 'completed') {
        throw new HttpsError('failed-precondition', 'Game is not finished');
    }

    if (game.isSettled) {
        throw new HttpsError('already-exists', 'Game has already been settled');
    }

    const scores = game.scores || {};
    const config = game.config || {};
    const unitsPerPoint = config.unitsPerPoint || 1;

    const playerIds = Object.keys(scores);
    if (playerIds.length < 2) {
        throw new HttpsError('failed-precondition', 'Need at least 2 players');
    }

    // Calculate net positions
    const avgScore = Object.values(scores as Record<string, number>).reduce((a, b) => a + b, 0) / playerIds.length;
    const netPositions: Record<string, number> = {};

    for (const playerId of playerIds) {
        netPositions[playerId] = Math.round((scores[playerId] - avgScore) * unitsPerPoint);
    }

    // Create settlements
    const settlements: Array<{ from: string; to: string; amount: number; timestamp: string }> = [];
    const creditors = playerIds.filter(p => netPositions[p] > 0)
        .sort((a, b) => netPositions[b] - netPositions[a]);
    const debtors = playerIds.filter(p => netPositions[p] < 0)
        .sort((a, b) => netPositions[a] - netPositions[b]);

    let creditorIdx = 0;
    let debtorIdx = 0;

    while (creditorIdx < creditors.length && debtorIdx < debtors.length) {
        const creditor = creditors[creditorIdx];
        const debtor = debtors[debtorIdx];

        const amount = Math.min(
            netPositions[creditor],
            Math.abs(netPositions[debtor])
        );

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

        if (netPositions[creditor] === 0) creditorIdx++;
        if (netPositions[debtor] === 0) debtorIdx++;
    }

    // Batch write for atomicity
    const batch = db.batch();
    batch.update(gameRef, { isSettled: true, settlements: settlements });

    for (const settlement of settlements) {
        const debtorWalletRef = db.collection('wallets').doc(settlement.from);
        batch.update(debtorWalletRef, {
            balance: FieldValue.increment(-settlement.amount),
        });

        const creditorWalletRef = db.collection('wallets').doc(settlement.to);
        batch.update(creditorWalletRef, {
            balance: FieldValue.increment(settlement.amount),
        });

        const txRef = db.collection('transactions').doc();
        batch.set(txRef, {
            gameId: gameId,
            fromUserId: settlement.from,
            toUserId: settlement.to,
            amount: settlement.amount,
            type: 'settlement',
            timestamp: FieldValue.serverTimestamp(),
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
