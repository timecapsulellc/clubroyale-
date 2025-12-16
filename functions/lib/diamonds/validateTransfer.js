"use strict";
/**
 * Diamond Transfer Validation & Execution
 *
 * P2P diamond transfers with:
 * - Tier-based limits
 * - 5% burn fee
 * - Full audit trail
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateTransfer = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const config_1 = require("./config");
const utils_1 = require("./utils");
// Lazy initialization
const getDb = () => admin.firestore();
/**
 * Validate and execute P2P diamond transfer
 */
exports.validateTransfer = (0, https_1.onCall)(async (request) => {
    const senderId = request.auth?.uid;
    if (!senderId) {
        throw new https_1.HttpsError('unauthenticated', 'Must be logged in');
    }
    const data = request.data;
    const { receiverId, amount, message } = data;
    // Validate input
    if (!receiverId || !amount || amount <= 0) {
        throw new https_1.HttpsError('invalid-argument', 'Invalid transfer parameters');
    }
    if (senderId === receiverId) {
        throw new https_1.HttpsError('invalid-argument', 'Cannot transfer to yourself');
    }
    // 1. Get sender data and validate tier
    const sender = await (0, utils_1.getUser)(senderId);
    const senderTier = (sender.tier || 'basic');
    if (senderTier === 'basic') {
        throw new https_1.HttpsError('permission-denied', 'Upgrade to Verified (100💎) to unlock transfers');
    }
    // 2. Get tier limits
    const tierLimits = config_1.TIER_LIMITS[senderTier];
    // 3. Check daily transfer limit
    const todayTransferred = sender.dailyTransferred || 0;
    if (tierLimits.dailyTransferLimit !== -1 &&
        todayTransferred + amount > tierLimits.dailyTransferLimit) {
        throw new https_1.HttpsError('resource-exhausted', `Daily transfer limit reached (${tierLimits.dailyTransferLimit}💎/day)`);
    }
    // 4. Check balance
    const senderBalance = sender.diamondBalance || 0;
    if (senderBalance < amount) {
        throw new https_1.HttpsError('failed-precondition', `Insufficient diamond balance. You have ${senderBalance}💎`);
    }
    // 5. Calculate fee (5% burned)
    const transferFee = Math.floor(amount * config_1.TRANSFER_FEE_PERCENT);
    const netAmount = amount - transferFee;
    // 6. Execute transfer atomically
    await getDb().runTransaction(async (transaction) => {
        const senderRef = getDb().collection('users').doc(senderId);
        const receiverRef = getDb().collection('users').doc(receiverId);
        // Verify receiver exists
        const receiverDoc = await transaction.get(receiverRef);
        if (!receiverDoc.exists) {
            throw new https_1.HttpsError('not-found', 'Recipient not found');
        }
        // Check receiver daily limit
        const receiver = receiverDoc.data();
        const receiverTier = (receiver.tier || 'basic');
        const receiverLimits = config_1.TIER_LIMITS[receiverTier];
        const todayReceived = receiver.dailyReceived || 0;
        if (receiverLimits.dailyReceiveLimit !== -1 &&
            todayReceived + netAmount > receiverLimits.dailyReceiveLimit) {
            throw new https_1.HttpsError('resource-exhausted', 'Recipient has reached their daily receive limit');
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
        const previousEntry = await (0, utils_1.getLastLedgerEntry)();
        const auditHash = (0, utils_1.generateAuditHash)({
            type: 'transfer',
            from: senderId,
            to: receiverId,
            amount: netAmount,
            fee: transferFee,
            previousHash: previousEntry?.auditHash || 'GENESIS',
            timestamp: Date.now(),
        });
        const ledgerRef = getDb().collection('diamond_ledger').doc();
        transaction.set(ledgerRef, {
            type: 'transfer',
            fromUserId: senderId,
            toUserId: receiverId,
            amount: netAmount,
            fee: transferFee,
            origin: 'p2pTransfer',
            reason: message || 'Diamond transfer',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            previousHash: previousEntry?.auditHash || 'GENESIS',
            auditHash: auditHash,
            sequenceNumber: (previousEntry?.sequenceNumber || 0) + 1,
        });
        // Record fee burn separately
        const burnRef = getDb().collection('diamond_ledger').doc();
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
        const senderData = await (0, utils_1.getUser)(senderId);
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
    }
    catch (e) {
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
//# sourceMappingURL=validateTransfer.js.map