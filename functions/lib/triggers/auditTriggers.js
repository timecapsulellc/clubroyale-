"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.auditGameUpdate = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const enhancedAuditService_1 = require("../services/enhancedAuditService");
/**
 * Trigger: Audit Game Updates
 *
 * Listens for changes in the 'games' collection.
 * Detects moves, calculates latency, and logs to the audit system.
 */
exports.auditGameUpdate = (0, firestore_1.onDocumentUpdated)('games/{gameId}', async (event) => {
    const gameId = event.params.gameId;
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    if (!beforeData || !afterData)
        return;
    // 1. Detect if a move happened (Generic detection or Game-Specific)
    // For Marriage, we look at 'marriageState'
    const beforeState = beforeData.marriageState;
    const afterState = afterData.marriageState;
    if (!beforeState || !afterState) {
        // Not a marriage game or state didn't exist
        return;
    }
    // 2. Identify the player who moved
    // Usually the 'currentPlayerId' *before* the update is the one who made the move,
    // UNLESS the update is just changing the turn.
    // In MarriageService, 'currentPlayerId' updates AT THE END of the turn (discard).
    // So if currentPlayerId changed, the OLD player finished their turn.
    let playerId = beforeState.currentPlayerId;
    let action = 'unknown';
    let details = {};
    // Check for specific state changes
    // a) Draw Card (Deck count decreased)
    if ((beforeState.deckCards?.length || 0) > (afterState.deckCards?.length || 0)) {
        action = 'drawCard';
        details = { source: 'deck' };
    }
    // b) Draw from Discard (Discard size decreased)
    else if ((beforeState.discardPile?.length || 0) > (afterState.discardPile?.length || 0)) {
        action = 'drawDiscard';
        details = { source: 'discard' };
    }
    // c) Discard/Play (Hand size decreased or Discard size increased)
    // Note: Draw/Discard usually happen in sequence or separate updates.
    else if ((beforeState.discardPile?.length || 0) < (afterState.discardPile?.length || 0)) {
        action = 'playCard'; // Discarding
        const newCard = afterState.discardPile[afterState.discardPile.length - 1];
        details = { cardId: newCard };
    }
    // d) Turn Change (Current Player ID changed)
    else if (beforeState.currentPlayerId !== afterState.currentPlayerId) {
        // This might happen simultaneously with discard in the same batch update
        // We capture the main action above.
        if (action === 'unknown')
            action = 'endTurn';
    }
    if (action === 'unknown')
        return; // No significant game move detected
    // 3. Calculate Latency (Time since last update)
    // Safety check for updateTime
    // event.data might be undefined if event type is wrong, but onDocumentUpdated guarantees it?
    // Types might be strict.
    const beforeDataSnapshot = event.data?.before;
    if (!beforeDataSnapshot)
        return;
    const updateTimeRaw = beforeDataSnapshot.updateTime;
    let lastUpdateTime = 0;
    if (updateTimeRaw) {
        // If it looks like a Timestamp object (has toMillis)
        if (typeof updateTimeRaw.toMillis === 'function') {
            lastUpdateTime = updateTimeRaw.toMillis();
        }
        else {
            // Fallback for ISO string
            lastUpdateTime = Date.parse(String(updateTimeRaw));
        }
    }
    else {
        lastUpdateTime = Date.now();
    }
    const currentTime = Date.parse(event.time);
    const latencyMs = currentTime - lastUpdateTime;
    // 4. Log the move
    await enhancedAuditService_1.EnhancedAuditService.logMove({
        roomId: gameId,
        roundNumber: afterState.currentRound || 1,
        playerId: playerId,
        action: action,
        isValid: true, // We assume valid if written to DB (server-authoritative-ish), but we can add checks
        latencyMs: latencyMs,
        // validationError: ...
    });
    // 5. Special Check: Superhuman Speed
    // If a player makes a complex move (like playing a card) incredibly fast after the previous state change
    await enhancedAuditService_1.EnhancedAuditService.checkMoveAnomalies({
        roomId: gameId,
        roundNumber: afterState.currentRound || 1,
        playerId: playerId,
        action: action,
        isValid: true,
        latencyMs: latencyMs,
    });
});
//# sourceMappingURL=auditTriggers.js.map