/**
 * Diamond Utility Functions
 *
 * Shared utilities for diamond operations.
 */
import * as admin from 'firebase-admin';
import { DiamondOrigin } from './config';
/**
 * Get user data from Firestore
 */
export declare function getUser(userId: string): Promise<admin.firestore.DocumentData>;
/**
 * Grant diamonds to a user with origin tracking
 */
export declare function grantDiamondsToUser(userId: string, amount: number, origin: DiamondOrigin, reason: string): Promise<void>;
/**
 * Get the last ledger entry for blockchain-style linking
 */
export declare function getLastLedgerEntry(): Promise<{
    auditHash: string;
    sequenceNumber: number;
} | null>;
/**
 * Calculate days since a date
 */
export declare function daysSince(date: Date | undefined): number;
/**
 * Generate audit hash for ledger entries (blockchain-style)
 */
export declare function generateAuditHash(data: Record<string, unknown>): string;
/**
 * Reset daily limits (called by scheduled function at midnight)
 */
export declare function resetDailyLimits(): Promise<number>;
/**
 * Send admin alert for important events
 */
export declare function sendAdminAlert(alert: {
    type: string;
    message: string;
    data?: Record<string, unknown>;
}): Promise<void>;
/**
 * Verify game result for anti-cheat (basic implementation)
 */
export declare function verifyGameResult(gameId: string, userId: string, result: string): Promise<{
    verified: boolean;
}>;
//# sourceMappingURL=utils.d.ts.map