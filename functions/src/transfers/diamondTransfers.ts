/**
 * Diamond Transfer Cloud Functions
 * 
 * Handles P2P transfer completion and expiry
 */

import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';

// Lazy initialization
const db = () => getFirestore();

/**
 * Complete transfer when both parties confirm
 */
export const onTransferConfirmed = onDocumentUpdated('diamond_transfers/{transferId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    // Check if this is a confirmation update
    if (after.status !== 'pending') return;
    if (!after.senderConfirmed || !after.receiverConfirmed) return;
    if (before.receiverConfirmed === after.receiverConfirmed) return;

    // Both confirmed - complete the transfer
    const fromUserId = after.fromUserId;
    const toUserId = after.toUserId;
    const amount = after.amount;

    const batch = db().batch();

    // Remove from sender's escrow
    const senderWalletRef = db().collection('wallets').doc(fromUserId);
    batch.update(senderWalletRef, {
        escrowedBalance: FieldValue.increment(-amount),
        totalTransferredOut: FieldValue.increment(amount),
        lastUpdated: FieldValue.serverTimestamp(),
    });

    // Credit to receiver
    const receiverWalletRef = db().collection('wallets').doc(toUserId);
    batch.update(receiverWalletRef, {
        balance: FieldValue.increment(amount),
        totalTransferredIn: FieldValue.increment(amount),
        lastUpdated: FieldValue.serverTimestamp(),
    });

    // Update transfer status
    const transferRef = db().collection('diamond_transfers').doc(event.params.transferId);
    batch.update(transferRef, {
        status: 'completed',
        completedAt: FieldValue.serverTimestamp(),
    });

    // Record transactions
    const senderTxRef = db().collection('transactions').doc();
    batch.set(senderTxRef, {
        userId: fromUserId,
        amount: -amount,
        type: 'transfer_out',
        description: `Sent to ${after.toUserName}`,
        transferId: event.params.transferId,
        createdAt: FieldValue.serverTimestamp(),
    });

    const receiverTxRef = db().collection('transactions').doc();
    batch.set(receiverTxRef, {
        userId: toUserId,
        amount: amount,
        type: 'transfer_in',
        description: `Received from ${after.fromUserName}`,
        transferId: event.params.transferId,
        createdAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
    console.log(`Transfer ${event.params.transferId} completed: ${amount} diamonds from ${fromUserId} to ${toUserId}`);
});

/**
 * Expire stale transfers (runs every hour)
 */
export const expireStaleTransfers = onSchedule('every 1 hours', async () => {
    const now = Timestamp.now();

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
            balance: FieldValue.increment(amount),
            escrowedBalance: FieldValue.increment(-amount),
            lastUpdated: FieldValue.serverTimestamp(),
        });

        // Update transfer status
        batch.update(doc.ref, {
            status: 'expired',
            expiredAt: FieldValue.serverTimestamp(),
        });

        await batch.commit();
        expiredCount++;

        console.log(`Transfer ${doc.id} expired: ${amount} diamonds returned to ${fromUserId}`);
    }

    console.log(`Expired ${expiredCount} stale transfers`);
});
