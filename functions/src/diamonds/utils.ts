/**
 * Diamond Utility Functions
 * 
 * Shared utilities for diamond operations.
 */

import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import { DiamondOrigin } from './config';

// Lazy initialization
const getDb = (): admin.firestore.Firestore => admin.firestore();

/**
 * Get user data from Firestore
 */
export async function getUser(userId: string): Promise<admin.firestore.DocumentData> {
    const doc = await getDb().collection('users').doc(userId).get();
    if (!doc.exists) {
        throw new Error(`User ${userId} not found`);
    }
    return doc.data()!;
}

/**
 * Grant diamonds to a user with origin tracking
 */
export async function grantDiamondsToUser(
    userId: string,
    amount: number,
    origin: DiamondOrigin,
    reason: string
): Promise<void> {
    const userRef = getDb().collection('users').doc(userId);

    await getDb().runTransaction(async (transaction) => {
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

        const ledgerRef = getDb().collection('diamond_ledger').doc();
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
export async function getLastLedgerEntry(): Promise<{
    auditHash: string;
    sequenceNumber: number;
} | null> {
    const snapshot = await getDb()
        .collection('diamond_ledger')
        .orderBy('sequenceNumber', 'desc')
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0].data();
    return {
        auditHash: doc.auditHash,
        sequenceNumber: doc.sequenceNumber,
    };
}

/**
 * Calculate days since a date
 */
export function daysSince(date: Date | undefined): number {
    if (!date) return 0;
    // Handle Firestore Timestamp
    const d = (date as any).toDate ? (date as any).toDate() : new Date(date);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - d.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}

/**
 * Generate audit hash for ledger entries (blockchain-style)
 */
export function generateAuditHash(data: Record<string, unknown>): string {
    const content = JSON.stringify(data, Object.keys(data).sort());
    return crypto.createHash('sha256').update(content).digest('hex');
}

/**
 * Reset daily limits (called by scheduled function at midnight)
 */
export async function resetDailyLimits(): Promise<number> {
    const usersRef = getDb().collection('users');
    const snapshot = await usersRef.get();

    let resetCount = 0;
    const batch = getDb().batch();

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
export async function sendAdminAlert(alert: {
    type: string;
    message: string;
    data?: Record<string, unknown>;
}): Promise<void> {
    await getDb().collection('admin_alerts').add({
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
export async function verifyGameResult(
    gameId: string,
    userId: string,
    result: string
): Promise<{ verified: boolean }> {
    try {
        const gameDoc = await getDb().collection('games').doc(gameId).get();
        if (!gameDoc.exists) {
            return { verified: false };
        }

        const gameData = gameDoc.data()!;

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
        await getDb().collection('games').doc(gameId).update({
            claimedRewards: admin.firestore.FieldValue.arrayUnion(userId),
        });

        return { verified: true };
    } catch (e) {
        console.error('Game verification error:', e);
        return { verified: false };
    }
}
