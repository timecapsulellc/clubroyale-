/**
 * Anti-Cheat Audit Service
 * 
 * Logs suspicious activity, tracks move patterns, and flags potential cheaters.
 */

import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const db = getFirestore();

// Severity levels for suspicious activity
export type SuspiciousSeverity = 'low' | 'medium' | 'high';

// Types of suspicious activity
export type SuspiciousReason =
    | 'out_of_turn'
    | 'invalid_card'
    | 'not_following_suit'
    | 'invalid_bid'
    | 'superhuman_speed'
    | 'impossible_move'
    | 'repeated_violations'
    | 'same_ip_players'
    | 'close_proximity';

// Suspicious activity log entry
export interface SuspiciousActivity {
    userId: string;
    reason: SuspiciousReason;
    severity: SuspiciousSeverity;
    details?: string;
    timestamp: FirebaseFirestore.FieldValue;
    matchId: string;
}

// Audit log entry for all moves
export interface AuditLogEntry {
    userId: string;
    action: 'bid' | 'playCard' | 'declareMarriage' | 'selectTrump' | 'draw' | 'discard' | 'declare';
    data: Record<string, unknown>;
    clientTimestamp: number;
    serverTimestamp: FirebaseFirestore.FieldValue;
    ipHash?: string;
}

// Audit service class
export class AuditService {
    /**
     * Log a move to the audit trail
     */
    static async logMove(
        matchId: string,
        entry: Omit<AuditLogEntry, 'serverTimestamp'>
    ): Promise<void> {
        const auditEntry: AuditLogEntry = {
            ...entry,
            serverTimestamp: FieldValue.serverTimestamp(),
        };

        await db.collection('matches').doc(matchId).update({
            auditLog: FieldValue.arrayUnion(auditEntry),
        });
    }

    /**
     * Log suspicious activity
     */
    static async logSuspiciousActivity(
        matchId: string,
        activity: Omit<SuspiciousActivity, 'timestamp' | 'matchId'>
    ): Promise<void> {
        const entry: SuspiciousActivity = {
            ...activity,
            matchId,
            timestamp: FieldValue.serverTimestamp(),
        };

        // Add to match document
        await db.collection('matches').doc(matchId).update({
            suspiciousActivity: FieldValue.arrayUnion(entry),
        });

        // If high severity, also add to flagged users collection
        if (activity.severity === 'high') {
            await db.collection('flaggedUsers').doc(activity.userId).set(
                {
                    matchId,
                    reason: activity.reason,
                    severity: activity.severity,
                    details: activity.details,
                    timestamp: FieldValue.serverTimestamp(),
                    reviewed: false,
                },
                { merge: true }
            );
        }

        // Track violation count for user
        await db
            .collection('userStats')
            .doc(activity.userId)
            .set(
                {
                    suspiciousActivityCount: FieldValue.increment(1),
                    [`violations.${activity.reason}`]: FieldValue.increment(1),
                    lastViolation: FieldValue.serverTimestamp(),
                },
                { merge: true }
            );
    }

    /**
     * Check for superhuman reaction time
     */
    static checkReactionTime(
        lastMoveTime: number,
        currentTime: number,
        threshold: number = 500
    ): { suspicious: boolean; severity: SuspiciousSeverity } {
        const timeDiff = currentTime - lastMoveTime;

        if (timeDiff < 100) {
            return { suspicious: true, severity: 'high' };
        } else if (timeDiff < threshold) {
            return { suspicious: true, severity: 'low' };
        }

        return { suspicious: false, severity: 'low' };
    }

    /**
     * Check for repeated violations
     */
    static async checkRepeatedViolations(
        userId: string,
        threshold: number = 5
    ): Promise<boolean> {
        const userStats = await db.collection('userStats').doc(userId).get();

        if (!userStats.exists) return false;

        const data = userStats.data();
        const count = data?.suspiciousActivityCount || 0;

        return count >= threshold;
    }

    /**
     * Get all suspicious activity for a match
     */
    static async getMatchSuspiciousActivity(
        matchId: string
    ): Promise<SuspiciousActivity[]> {
        const match = await db.collection('matches').doc(matchId).get();
        return match.data()?.suspiciousActivity || [];
    }

    /**
     * Get flagged users for review
     */
    static async getFlaggedUsers(
        limit: number = 50
    ): Promise<Array<{ id: string; data: Record<string, unknown> }>> {
        const snapshot = await db
            .collection('flaggedUsers')
            .where('reviewed', '==', false)
            .orderBy('timestamp', 'desc')
            .limit(limit)
            .get();

        return snapshot.docs.map((doc: FirebaseFirestore.QueryDocumentSnapshot) => ({
            id: doc.id,
            data: doc.data(),
        }));
    }

    /**
     * Mark a flagged user as reviewed
     */
    static async markReviewed(
        userId: string,
        action: 'cleared' | 'warned' | 'banned'
    ): Promise<void> {
        await db.collection('flaggedUsers').doc(userId).update({
            reviewed: true,
            reviewAction: action,
            reviewedAt: FieldValue.serverTimestamp(),
        });

        if (action === 'banned') {
            await db.collection('users').doc(userId).update({
                isBanned: true,
                bannedAt: FieldValue.serverTimestamp(),
            });
        }
    }
}

// Export helper functions for direct use
export const logMove = AuditService.logMove;
export const logSuspiciousActivity = AuditService.logSuspiciousActivity;
export const checkReactionTime = AuditService.checkReactionTime;
