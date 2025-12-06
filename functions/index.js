/**
 * TaasClub - Anti-Cheat Cloud Functions
 * 
 * These functions validate game moves server-side to prevent cheating.
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();

/**
 * Card suits and their properties
 */
const SUITS = {
    spades: { symbol: "♠", isRed: false, isTrump: true },
    hearts: { symbol: "♥", isRed: true, isTrump: false },
    diamonds: { symbol: "♦", isRed: true, isTrump: false },
    clubs: { symbol: "♣", isRed: false, isTrump: false },
};

/**
 * Card rank values (Ace high)
 */
const RANK_VALUES = {
    "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7,
    "8": 8, "9": 9, "10": 10, "J": 11, "Q": 12, "K": 13, "A": 14,
};

/**
 * Validate a bid in Call Break
 * 
 * @param {object} request - Contains gameId, bid
 * @returns {object} - Success status or error
 */
exports.validateBid = onCall(async (request) => {
    const { gameId, bid } = request.data;
    const userId = request.auth?.uid;

    // Check authentication
    if (!userId) {
        throw new HttpsError("unauthenticated", "User must be logged in");
    }

    // Validate bid range (1-13 in Call Break)
    if (!Number.isInteger(bid) || bid < 1 || bid > 13) {
        throw new HttpsError("invalid-argument", "Bid must be between 1 and 13");
    }

    // Get game from Firestore
    const gameRef = db.collection("games").doc(gameId);
    const gameDoc = await gameRef.get();

    if (!gameDoc.exists) {
        throw new HttpsError("not-found", "Game not found");
    }

    const game = gameDoc.data();

    // Check if player is in the game
    const playerIds = game.players?.map(p => p.id) || Object.keys(game.scores || {});
    if (!playerIds.includes(userId)) {
        throw new HttpsError("permission-denied", "You are not in this game");
    }

    // Check if it's the player's turn to bid
    if (game.currentTurn !== userId) {
        throw new HttpsError("failed-precondition", "Not your turn to bid");
    }

    // Check game is in bidding phase
    if (game.gamePhase !== "bidding") {
        throw new HttpsError("failed-precondition", "Game is not in bidding phase");
    }

    // Check player hasn't already bid this round
    const bids = game.bids || {};
    if (bids[userId] !== undefined && bids[userId] !== null) {
        throw new HttpsError("already-exists", "You have already bid this round");
    }

    return { success: true, message: "Bid is valid" };
});

/**
 * Validate a card move in Call Break
 * 
 * @param {object} request - Contains gameId, card (suit, rank)
 * @returns {object} - Success status or error
 */
exports.validateMove = onCall(async (request) => {
    const { gameId, card } = request.data;
    const userId = request.auth?.uid;

    // Check authentication
    if (!userId) {
        throw new HttpsError("unauthenticated", "User must be logged in");
    }

    // Validate card format
    if (!card || !card.suit || !card.rank) {
        throw new HttpsError("invalid-argument", "Invalid card format");
    }

    if (!SUITS[card.suit]) {
        throw new HttpsError("invalid-argument", `Invalid suit: ${card.suit}`);
    }

    if (!RANK_VALUES[card.rank]) {
        throw new HttpsError("invalid-argument", `Invalid rank: ${card.rank}`);
    }

    // Get game from Firestore
    const gameRef = db.collection("games").doc(gameId);
    const gameDoc = await gameRef.get();

    if (!gameDoc.exists) {
        throw new HttpsError("not-found", "Game not found");
    }

    const game = gameDoc.data();

    // Check if player is in the game
    const playerIds = game.players?.map(p => p.id) || Object.keys(game.scores || {});
    if (!playerIds.includes(userId)) {
        throw new HttpsError("permission-denied", "You are not in this game");
    }

    // Check if it's the player's turn
    if (game.currentTurn !== userId) {
        throw new HttpsError("failed-precondition", "Not your turn to play");
    }

    // Check game is in playing phase
    if (game.gamePhase !== "playing") {
        throw new HttpsError("failed-precondition", "Game is not in playing phase");
    }

    // Get player's hand
    const playerHands = game.playerHands || {};
    const hand = playerHands[userId] || [];

    // Check if player has this card
    const hasCard = hand.some(c =>
        c.suit === card.suit && c.rank === card.rank
    );

    if (!hasCard) {
        throw new HttpsError("failed-precondition", "You don't have this card");
    }

    // Check follow-suit rule
    const currentTrick = game.currentTrick || [];

    if (currentTrick.length > 0) {
        // There's a led suit - must follow if possible
        const ledSuit = currentTrick[0].suit;

        // Check if player has led suit
        const hasLedSuit = hand.some(c => c.suit === ledSuit);

        if (hasLedSuit && card.suit !== ledSuit) {
            throw new HttpsError(
                "failed-precondition",
                `Must follow suit: ${ledSuit}`
            );
        }
    }

    return { success: true, message: "Move is valid" };
});

/**
 * Process settlement after game ends
 * Transfers diamonds between players based on scores
 * 
 * @param {object} request - Contains gameId
 * @returns {object} - Settlement results
 */
exports.processSettlement = onCall(async (request) => {
    const { gameId } = request.data;
    const userId = request.auth?.uid;

    if (!userId) {
        throw new HttpsError("unauthenticated", "User must be logged in");
    }

    // Get game
    const gameRef = db.collection("games").doc(gameId);
    const gameDoc = await gameRef.get();

    if (!gameDoc.exists) {
        throw new HttpsError("not-found", "Game not found");
    }

    const game = gameDoc.data();

    // Check game is finished
    if (game.status !== "finished" && game.status !== "completed") {
        throw new HttpsError("failed-precondition", "Game is not finished");
    }

    // Check game hasn't been settled already
    if (game.isSettled) {
        throw new HttpsError("already-exists", "Game has already been settled");
    }

    const scores = game.scores || {};
    const config = game.config || {};
    const unitsPerPoint = config.unitsPerPoint || 1;

    const playerIds = Object.keys(scores);
    if (playerIds.length < 2) {
        throw new HttpsError("failed-precondition", "Need at least 2 players");
    }

    // Calculate net positions
    const avgScore = Object.values(scores).reduce((a, b) => a + b, 0) / playerIds.length;
    const netPositions = {};

    for (const playerId of playerIds) {
        netPositions[playerId] = Math.round((scores[playerId] - avgScore) * unitsPerPoint);
    }

    // Create settlements (simplified - largest creditor to largest debtor)
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

    // Use batch write for atomicity
    const batch = db.batch();

    // Mark game as settled
    batch.update(gameRef, { isSettled: true, settlements: settlements });

    // Update wallet balances
    for (const settlement of settlements) {
        // Deduct from debtor
        const debtorWalletRef = db.collection("wallets").doc(settlement.from);
        batch.update(debtorWalletRef, {
            balance: admin.firestore.FieldValue.increment(-settlement.amount),
        });

        // Add to creditor
        const creditorWalletRef = db.collection("wallets").doc(settlement.to);
        batch.update(creditorWalletRef, {
            balance: admin.firestore.FieldValue.increment(settlement.amount),
        });

        // Record transaction
        const txRef = db.collection("transactions").doc();
        batch.set(txRef, {
            gameId: gameId,
            fromUserId: settlement.from,
            toUserId: settlement.to,
            amount: settlement.amount,
            type: "settlement",
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            status: "completed",
        });
    }

    await batch.commit();

    return {
        success: true,
        settlements: settlements,
        message: `Processed ${settlements.length} settlements`,
    };
});
