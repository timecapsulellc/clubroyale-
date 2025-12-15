/**
 * Diamond Transfer Validation & Execution
 * 
 * P2P diamond transfers with:
 * - Tier-based limits
 * - 5% burn fee
 * - Full audit trail
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { TIER_LIMITS, TRANSFER_FEE_PERCENT, UserTier, DiamondOrigin } from './config';
import { getUser, generateAuditHash, getLastLedgerEntry } from './utils';

const firestore = admin.firestore();

interface TransferRequest {
    receiverId: string;
    amount: number;
    message?: string;
}

interface TransferResult {
    success: boolean;
    sent: number;
    received: number;
    feeBurned: number;
}

/**
 * Validate and execute P2P diamond transfer
 */
export const validateTransfer = onCall(async (request): Promise<TransferResult> => {
    const senderId = request.auth?.uid;
    if (!senderId) {
        throw new HttpsError('unauthenticated', 'Must be logged in');
    }

    const data = request.data as TransferRequest;
    const { receiverId, amount, message } = data;

    // Validate input
    if (!receiverId || !amount || amount <= 0) {
        throw new HttpsError('invalid-argument', 'Invalid transfer parameters');
    }

    if (senderId === receiverId) {
        throw new HttpsError('invalid-argument', 'Cannot transfer to yourself');
    }

    // 1. Get sender data and validate tier
    const sender = await getUser(senderId);
    const senderTier = (sender.tier || 'basic') as UserTier;

    if (senderTier === 'basic') {
        throw new HttpsError(
            'permission-denied',
            'Upgrade to Verified (100💎) to unlock transfers'
        );
    }

    // 2. Get tier limits
    const tierLimits = TIER_LIMITS[senderTier];

    // 3. Check daily transfer limit
    const todayTransferred = sender.dailyTransferred || 0;
    if (tierLimits.dailyTransferLimit !== -1 &&
        todayTransferred + amount > tierLimits.dailyTransferLimit) {
        throw new HttpsError(
            'resource-exhausted',
            `Daily transfer limit reached (${tierLimits.dailyTransferLimit}💎/day)`
        );
    }

    // 4. Check balance
    const senderBalance = sender.diamondBalance || 0;
    if (senderBalance < amount) {
        throw new HttpsError(
            'failed-precondition',
            `Insufficient diamond balance. You have ${senderBalance}💎`
        );
    }

    // 5. Calculate fee (5% burned)
    const transferFee = Math.floor(amount * TRANSFER_FEE_PERCENT);
    const netAmount = amount - transferFee;

    // 6. Execute transfer atomically
    await firestore.runTransaction(async (transaction) => {
        const senderRef = firestore.collection('users').doc(senderId);
        const receiverRef = firestore.collection('users').doc(receiverId);

        // Verify receiver exists
        const receiverDoc = await transaction.get(receiverRef);
        if (!receiverDoc.exists) {
            throw new HttpsError('not-found', 'Recipient not found');
        }

        // Check receiver daily limit
        const receiver = receiverDoc.data()!;
        const receiverTier = (receiver.tier || 'basic') as UserTier;
        const receiverLimits = TIER_LIMITS[receiverTier];
        const todayReceived = receiver.dailyReceived || 0;

        if (receiverLimits.dailyReceiveLimit !== -1 &&
            todayReceived + netAmount > receiverLimits.dailyReceiveLimit) {
            throw new HttpsError(
                'resource-exhausted',
                'Recipient has reached their daily receive limit'
            );
        }

        // Deduct from sender (including fee)
        transaction.update(senderRef, {
            diamondBalance: admin.firestore.FieldValue.increment(-amount),
            dailyTransferred: admin.firestore.FieldValue.increment(amount),
            'diamondsByOrigin.spent': admin.firestore.FieldValue.increment(amount),
        });

        // Credit to receiver
        transaction.update(receiverRef, {
            diamondBalance: admin.firestore.FieldValue.increment(netAmount),
            dailyReceived: admin.firestore.FieldValue.increment(netAmount),
            'diamondsByOrigin.p2pTransfer': admin.firestore.FieldValue.increment(netAmount),
        });

        // Record transfer in ledger
        const previousEntry = await getLastLedgerEntry();
        const auditHash = generateAuditHash({
            type: 'transfer',
            from: senderId,
            to: receiverId,
            amount: netAmount,
            fee: transferFee,
            previousHash: previousEntry?.auditHash || 'GENESIS',
            timestamp: Date.now(),
        });

        const ledgerRef = firestore.collection('diamond_ledger').doc();
        transaction.set(ledgerRef, {
            type: 'transfer',
            fromUserId: senderId,
            toUserId: receiverId,
            amount: netAmount,
            fee: transferFee,
            origin: 'p2pTransfer' as DiamondOrigin,
            reason: message || 'Diamond transfer',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            previousHash: previousEntry?.auditHash || 'GENESIS',
            auditHash: auditHash,
            sequenceNumber: (previousEntry?.sequenceNumber || 0) + 1,
        });

        // Record fee burn separately
        const burnRef = firestore.collection('diamond_ledger').doc();
        transaction.set(burnRef, {
            type: 'burn',
            fromUserId: senderId,
            toUserId: null,
            amount: transferFee,
            origin: 'transferFee',
            reason: 'P2P transfer fee (5%)',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
    });

    // 7. Send notification to receiver
    try {
        const senderData = await getUser(senderId);
        await admin.messaging().send({
            topic: `user_${receiverId}`,
            notification: {
                title: '💎 Diamonds Received!',
                body: `You received ${netAmount}💎 from ${senderData.displayName || 'A friend'}`,
            },
            data: {
                type: 'diamond_transfer',
                amount: netAmount.toString(),
                senderId: senderId,
            },
        });
    } catch (e) {
        // Notification failure shouldn't fail the transfer
        console.error('Failed to send transfer notification:', e);
    }

    return {
        success: true,
        sent: amount,
        received: netAmount,
        feeBurned: transferFee,
    };
});
