"use strict";
/**
 * Diamond Transfer Cloud Functions
 *
 * Handles P2P transfer completion and expiry
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.expireStaleTransfers = exports.onTransferConfirmed = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_2 = require("firebase-admin/firestore");
// Lazy initialization
const db = () => (0, firestore_2.getFirestore)();
/**
 * Complete transfer when both parties confirm
 */
exports.onTransferConfirmed = (0, firestore_1.onDocumentUpdated)('diamond_transfers/{transferId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after)
        return;
    // Check if this is a confirmation update
    if (after.status !== 'pending')
        return;
    if (!after.senderConfirmed || !after.receiverConfirmed)
        return;
    if (before.receiverConfirmed === after.receiverConfirmed)
        return;
    // Both confirmed - complete the transfer
    const fromUserId = after.fromUserId;
    const toUserId = after.toUserId;
    const amount = after.amount;
    const batch = db().batch();
    // Remove from sender's escrow
    const senderWalletRef = db().collection('wallets').doc(fromUserId);
    batch.update(senderWalletRef, {
        escrowedBalance: firestore_2.FieldValue.increment(-amount),
        totalTransferredOut: firestore_2.FieldValue.increment(amount),
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    // Credit to receiver
    const receiverWalletRef = db().collection('wallets').doc(toUserId);
    batch.update(receiverWalletRef, {
        balance: firestore_2.FieldValue.increment(amount),
        totalTransferredIn: firestore_2.FieldValue.increment(amount),
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    // Update transfer status
    const transferRef = db().collection('diamond_transfers').doc(event.params.transferId);
    batch.update(transferRef, {
        status: 'completed',
        completedAt: firestore_2.FieldValue.serverTimestamp(),
    });
    // Record transactions
    const senderTxRef = db().collection('transactions').doc();
    batch.set(senderTxRef, {
        userId: fromUserId,
        amount: -amount,
        type: 'transfer_out',
        description: `Sent to ${after.toUserName}`,
        transferId: event.params.transferId,
        createdAt: firestore_2.FieldValue.serverTimestamp(),
    });
    const receiverTxRef = db().collection('transactions').doc();
    batch.set(receiverTxRef, {
        userId: toUserId,
        amount: amount,
        type: 'transfer_in',
        description: `Received from ${after.fromUserName}`,
        transferId: event.params.transferId,
        createdAt: firestore_2.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    console.log(`Transfer ${event.params.transferId} completed: ${amount} diamonds from ${fromUserId} to ${toUserId}`);
});
/**
 * Expire stale transfers (runs every hour)
 */
exports.expireStaleTransfers = (0, scheduler_1.onSchedule)('every 1 hours', async () => {
    const now = firestore_2.Timestamp.now();
    const staleTransfers = await db()
        .collection('diamond_transfers')
        .where('status', '==', 'pending')
        .where('expiresAt', '<', now)
        .get();
    let expiredCount = 0;
    for (const doc of staleTransfers.docs) {
        const data = doc.data();
        const fromUserId = data.fromUserId;
        const amount = data.amount;
        const batch = db().batch();
        // Return from escrow to balance
        const walletRef = db().collection('wallets').doc(fromUserId);
        batch.update(walletRef, {
            balance: firestore_2.FieldValue.increment(amount),
            escrowedBalance: firestore_2.FieldValue.increment(-amount),
            lastUpdated: firestore_2.FieldValue.serverTimestamp(),
        });
        // Update transfer status
        batch.update(doc.ref, {
            status: 'expired',
            expiredAt: firestore_2.FieldValue.serverTimestamp(),
        });
        await batch.commit();
        expiredCount++;
        console.log(`Transfer ${doc.id} expired: ${amount} diamonds returned to ${fromUserId}`);
    }
    console.log(`Expired ${expiredCount} stale transfers`);
});
//# sourceMappingURL=diamondTransfers.js.map