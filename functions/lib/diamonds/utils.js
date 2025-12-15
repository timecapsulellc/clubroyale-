"use strict";
/**
 * Diamond Utility Functions
 *
 * Shared utilities for diamond operations.
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
exports.getUser = getUser;
exports.grantDiamondsToUser = grantDiamondsToUser;
exports.getLastLedgerEntry = getLastLedgerEntry;
exports.daysSince = daysSince;
exports.generateAuditHash = generateAuditHash;
exports.resetDailyLimits = resetDailyLimits;
exports.sendAdminAlert = sendAdminAlert;
exports.verifyGameResult = verifyGameResult;
const admin = __importStar(require("firebase-admin"));
const crypto = __importStar(require("crypto"));
const firestore = admin.firestore();
/**
 * Get user data from Firestore
 */
async function getUser(userId) {
    const doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
        throw new Error(`User ${userId} not found`);
    }
    return doc.data();
}
/**
 * Grant diamonds to a user with origin tracking
 */
async function grantDiamondsToUser(userId, amount, origin, reason) {
    const userRef = firestore.collection('users').doc(userId);
    await firestore.runTransaction(async (transaction) => {
        // Update user balance and origin tracking
        transaction.update(userRef, {
            diamondBalance: admin.firestore.FieldValue.increment(amount),
            dailyEarned: admin.firestore.FieldValue.increment(amount),
            [`diamondsByOrigin.${origin}`]: admin.firestore.FieldValue.increment(amount),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Record in ledger
        const previousEntry = await getLastLedgerEntry();
        const auditHash = generateAuditHash({
            type: 'earn',
            to: userId,
            amount: amount,
            origin: origin,
            previousHash: previousEntry?.auditHash || 'GENESIS',
            timestamp: Date.now(),
        });
        const ledgerRef = firestore.collection('diamond_ledger').doc();
        transaction.set(ledgerRef, {
            type: 'earn',
            fromUserId: null,
            toUserId: userId,
            amount: amount,
            origin: origin,
            reason: reason,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            previousHash: previousEntry?.auditHash || 'GENESIS',
            auditHash: auditHash,
            sequenceNumber: (previousEntry?.sequenceNumber || 0) + 1,
        });
    });
}
/**
 * Get the last ledger entry for blockchain-style linking
 */
async function getLastLedgerEntry() {
    const snapshot = await firestore
        .collection('diamond_ledger')
        .orderBy('sequenceNumber', 'desc')
        .limit(1)
        .get();
    if (snapshot.empty)
        return null;
    const doc = snapshot.docs[0].data();
    return {
        auditHash: doc.auditHash,
        sequenceNumber: doc.sequenceNumber,
    };
}
/**
 * Calculate days since a date
 */
function daysSince(date) {
    if (!date)
        return 0;
    // Handle Firestore Timestamp
    const d = date.toDate ? date.toDate() : new Date(date);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - d.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}
/**
 * Generate audit hash for ledger entries (blockchain-style)
 */
function generateAuditHash(data) {
    const content = JSON.stringify(data, Object.keys(data).sort());
    return crypto.createHash('sha256').update(content).digest('hex');
}
/**
 * Reset daily limits (called by scheduled function at midnight)
 */
async function resetDailyLimits() {
    const usersRef = firestore.collection('users');
    const snapshot = await usersRef.get();
    let resetCount = 0;
    const batch = firestore.batch();
    snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
            dailyEarned: 0,
            dailyTransferred: 0,
            dailyReceived: 0,
        });
        resetCount++;
    });
    await batch.commit();
    return resetCount;
}
/**
 * Send admin alert for important events
 */
async function sendAdminAlert(alert) {
    await firestore.collection('admin_alerts').add({
        ...alert,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        acknowledged: false,
    });
    // Also log to console for monitoring
    console.warn(`[ADMIN ALERT] ${alert.type}: ${alert.message}`, alert.data);
}
/**
 * Verify game result for anti-cheat (basic implementation)
 */
async function verifyGameResult(gameId, userId, result) {
    try {
        const gameDoc = await firestore.collection('games').doc(gameId).get();
        if (!gameDoc.exists) {
            return { verified: false };
        }
        const gameData = gameDoc.data();
        // Check if user was a participant
        const participants = gameData.participants || [];
        if (!participants.includes(userId)) {
            return { verified: false };
        }
        // Check if game is completed
        if (gameData.status !== 'completed') {
            return { verified: false };
        }
        // Check if reward already claimed
        const claimedRewards = gameData.claimedRewards || [];
        if (claimedRewards.includes(userId)) {
            return { verified: false };
        }
        // Mark reward as claimed
        await firestore.collection('games').doc(gameId).update({
            claimedRewards: admin.firestore.FieldValue.arrayUnion(userId),
        });
        return { verified: true };
    }
    catch (e) {
        console.error('Game verification error:', e);
        return { verified: false };
    }
}
//# sourceMappingURL=utils.js.map