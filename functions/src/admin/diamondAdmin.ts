/**
 * Admin Diamond Cloud Functions
 * 
 * Handles admin grant execution after cooling period
 */

import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';

const db = getFirestore();

// Approval thresholds
const SINGLE_APPROVAL_LIMIT = 999;
const DUAL_APPROVAL_LIMIT = 9999;
const COOLING_PERIOD_THRESHOLD = 10000;

/**
 * Execute grant when fully approved (no cooling period)
 */
export const onGrantApproved = onDocumentUpdated('diamond_requests/{requestId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    // Check if status changed to 'approved'
    if (before.status === after.status || after.status !== 'approved') {
        return;
    }

    // Execute the grant immediately
    await executeGrant(event.params.requestId, after);
});

/**
 * Execute grants that passed cooling period (runs every hour)
 */
export const executeCooledGrants = onSchedule('every 1 hours', async () => {
    const now = Timestamp.now();

    const cooledGrants = await db
        .collection('diamond_requests')
        .where('status', '==', 'cooling_period')
        .where('coolingPeriodEnds', '<', now)
        .get();

    let executedCount = 0;

    for (const doc of cooledGrants.docs) {
        const data = doc.data();
        await executeGrant(doc.id, data);
        executedCount++;
    }

    console.log(`Executed ${executedCount} cooled grants`);
});

/**
 * Execute a grant - credit diamonds to user
 */
async function executeGrant(requestId: string, requestData: FirebaseFirestore.DocumentData) {
    const targetUserId = requestData.targetUserId;
    const amount = requestData.amount;

    const batch = db.batch();

    // Update wallet balance
    const walletRef = db.collection('wallets').doc(targetUserId);
    batch.update(walletRef, {
        balance: FieldValue.increment(amount),
        totalPurchased: FieldValue.increment(amount),
        lastUpdated: FieldValue.serverTimestamp(),
    });

    // Record transaction
    const txRef = db.collection('transactions').doc();
    batch.set(txRef, {
        userId: targetUserId,
        amount: amount,
        type: 'admin_grant',
        description: 'Admin diamond grant',
        grantRequestId: requestId,
        createdAt: FieldValue.serverTimestamp(),
    });

    // Update request status
    const requestRef = db.collection('diamond_requests').doc(requestId);
    batch.update(requestRef, {
        status: 'executed',
        executedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
    console.log(`Grant executed: ${amount} diamonds to ${targetUserId}`);
}

/**
 * Send notification to admins for new chat messages
 */
export const notifyAdminNewChat = onDocumentUpdated('admin_chats/{chatId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    // Only notify if unreadByAdmin changed from false to true
    if (!before.unreadByAdmin && after.unreadByAdmin) {
        console.log(`New unread message in chat ${event.params.chatId}`);
        // TODO: Send FCM notification to admins
    }
});
