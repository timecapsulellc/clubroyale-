"use strict";
/**
 * Anti-Cheat Audit Service
 *
 * Logs suspicious activity, tracks move patterns, and flags potential cheaters.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkReactionTime = exports.logSuspiciousActivity = exports.logMove = exports.AuditService = void 0;
const firestore_1 = require("firebase-admin/firestore");
const db = (0, firestore_1.getFirestore)();
// Audit service class
class AuditService {
    /**
     * Log a move to the audit trail
     */
    static async logMove(matchId, entry) {
        const auditEntry = {
            ...entry,
            serverTimestamp: firestore_1.FieldValue.serverTimestamp(),
        };
        await db.collection('matches').doc(matchId).update({
            auditLog: firestore_1.FieldValue.arrayUnion(auditEntry),
        });
    }
    /**
     * Log suspicious activity
     */
    static async logSuspiciousActivity(matchId, activity) {
        const entry = {
            ...activity,
            matchId,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        };
        // Add to match document
        await db.collection('matches').doc(matchId).update({
            suspiciousActivity: firestore_1.FieldValue.arrayUnion(entry),
        });
        // If high severity, also add to flagged users collection
        if (activity.severity === 'high') {
            await db.collection('flaggedUsers').doc(activity.userId).set({
                matchId,
                reason: activity.reason,
                severity: activity.severity,
                details: activity.details,
                timestamp: firestore_1.FieldValue.serverTimestamp(),
                reviewed: false,
            }, { merge: true });
        }
        // Track violation count for user
        await db
            .collection('userStats')
            .doc(activity.userId)
            .set({
            suspiciousActivityCount: firestore_1.FieldValue.increment(1),
            [`violations.${activity.reason}`]: firestore_1.FieldValue.increment(1),
            lastViolation: firestore_1.FieldValue.serverTimestamp(),
        }, { merge: true });
    }
    /**
     * Check for superhuman reaction time
     */
    static checkReactionTime(lastMoveTime, currentTime, threshold = 500) {
        const timeDiff = currentTime - lastMoveTime;
        if (timeDiff < 100) {
            return { suspicious: true, severity: 'high' };
        }
        else if (timeDiff < threshold) {
            return { suspicious: true, severity: 'low' };
        }
        return { suspicious: false, severity: 'low' };
    }
    /**
     * Check for repeated violations
     */
    static async checkRepeatedViolations(userId, threshold = 5) {
        const userStats = await db.collection('userStats').doc(userId).get();
        if (!userStats.exists)
            return false;
        const data = userStats.data();
        const count = data?.suspiciousActivityCount || 0;
        return count >= threshold;
    }
    /**
     * Get all suspicious activity for a match
     */
    static async getMatchSuspiciousActivity(matchId) {
        const match = await db.collection('matches').doc(matchId).get();
        return match.data()?.suspiciousActivity || [];
    }
    /**
     * Get flagged users for review
     */
    static async getFlaggedUsers(limit = 50) {
        const snapshot = await db
            .collection('flaggedUsers')
            .where('reviewed', '==', false)
            .orderBy('timestamp', 'desc')
            .limit(limit)
            .get();
        return snapshot.docs.map((doc) => ({
            id: doc.id,
            data: doc.data(),
        }));
    }
    /**
     * Mark a flagged user as reviewed
     */
    static async markReviewed(userId, action) {
        await db.collection('flaggedUsers').doc(userId).update({
            reviewed: true,
            reviewAction: action,
            reviewedAt: firestore_1.FieldValue.serverTimestamp(),
        });
        if (action === 'banned') {
            await db.collection('users').doc(userId).update({
                isBanned: true,
                bannedAt: firestore_1.FieldValue.serverTimestamp(),
            });
        }
    }
}
exports.AuditService = AuditService;
// Export helper functions for direct use
exports.logMove = AuditService.logMove;
exports.logSuspiciousActivity = AuditService.logSuspiciousActivity;
exports.checkReactionTime = AuditService.checkReactionTime;
//# sourceMappingURL=auditService.js.map