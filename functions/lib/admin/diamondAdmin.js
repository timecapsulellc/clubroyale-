"use strict";
/**
 * Admin Diamond Cloud Functions
 *
 * Handles admin grant execution after cooling period
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.notifyAdminNewChat = exports.executeCooledGrants = exports.onGrantApproved = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_2 = require("firebase-admin/firestore");
// Lazy initialization
const db = () => (0, firestore_2.getFirestore)();
// Approval thresholds
const SINGLE_APPROVAL_LIMIT = 999;
const DUAL_APPROVAL_LIMIT = 9999;
const COOLING_PERIOD_THRESHOLD = 10000;
/**
 * Execute grant when fully approved (no cooling period)
 */
exports.onGrantApproved = (0, firestore_1.onDocumentUpdated)('diamond_requests/{requestId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after)
        return;
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
exports.executeCooledGrants = (0, scheduler_1.onSchedule)('every 1 hours', async () => {
    const now = firestore_2.Timestamp.now();
    const cooledGrants = await db()
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
async function executeGrant(requestId, requestData) {
    const targetUserId = requestData.targetUserId;
    const amount = requestData.amount;
    const batch = db().batch();
    // Update wallet balance
    const walletRef = db().collection('wallets').doc(targetUserId);
    batch.update(walletRef, {
        balance: firestore_2.FieldValue.increment(amount),
        totalPurchased: firestore_2.FieldValue.increment(amount),
        lastUpdated: firestore_2.FieldValue.serverTimestamp(),
    });
    // Record transaction
    const txRef = db().collection('transactions').doc();
    batch.set(txRef, {
        userId: targetUserId,
        amount: amount,
        type: 'admin_grant',
        description: 'Admin diamond grant',
        grantRequestId: requestId,
        createdAt: firestore_2.FieldValue.serverTimestamp(),
    });
    // Update request status
    const requestRef = db().collection('diamond_requests').doc(requestId);
    batch.update(requestRef, {
        status: 'executed',
        executedAt: firestore_2.FieldValue.serverTimestamp(),
    });
    await batch.commit();
    console.log(`Grant executed: ${amount} diamonds to ${targetUserId}`);
}
/**
 * Send notification to admins for new chat messages
 */
exports.notifyAdminNewChat = (0, firestore_1.onDocumentUpdated)('admin_chats/{chatId}', async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after)
        return;
    // Only notify if unreadByAdmin changed from false to true
    if (!before.unreadByAdmin && after.unreadByAdmin) {
        console.log(`New unread message in chat ${event.params.chatId}`);
        // TODO: Send FCM notification to admins
    }
});
//# sourceMappingURL=diamondAdmin.js.map