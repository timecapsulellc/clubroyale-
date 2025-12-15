/**
 * Anti-Cheat Audit Service
 *
 * Logs suspicious activity, tracks move patterns, and flags potential cheaters.
 */
export type SuspiciousSeverity = 'low' | 'medium' | 'high';
export type SuspiciousReason = 'out_of_turn' | 'invalid_card' | 'not_following_suit' | 'invalid_bid' | 'superhuman_speed' | 'impossible_move' | 'repeated_violations' | 'same_ip_players' | 'close_proximity';
export interface SuspiciousActivity {
    userId: string;
    reason: SuspiciousReason;
    severity: SuspiciousSeverity;
    details?: string;
    timestamp: FirebaseFirestore.FieldValue;
    matchId: string;
}
export interface AuditLogEntry {
    userId: string;
    action: 'bid' | 'playCard' | 'declareMarriage' | 'selectTrump' | 'draw' | 'discard' | 'declare';
    data: Record<string, unknown>;
    clientTimestamp: number;
    serverTimestamp: FirebaseFirestore.FieldValue;
    ipHash?: string;
}
export declare class AuditService {
    /**
     * Log a move to the audit trail
     */
    static logMove(matchId: string, entry: Omit<AuditLogEntry, 'serverTimestamp'>): Promise<void>;
    /**
     * Log suspicious activity
     */
    static logSuspiciousActivity(matchId: string, activity: Omit<SuspiciousActivity, 'timestamp' | 'matchId'>): Promise<void>;
    /**
     * Check for superhuman reaction time
     */
    static checkReactionTime(lastMoveTime: number, currentTime: number, threshold?: number): {
        suspicious: boolean;
        severity: SuspiciousSeverity;
    };
    /**
     * Check for repeated violations
     */
    static checkRepeatedViolations(userId: string, threshold?: number): Promise<boolean>;
    /**
     * Get all suspicious activity for a match
     */
    static getMatchSuspiciousActivity(matchId: string): Promise<SuspiciousActivity[]>;
    /**
     * Get flagged users for review
     */
    static getFlaggedUsers(limit?: number): Promise<Array<{
        id: string;
        data: Record<string, unknown>;
    }>>;
    /**
     * Mark a flagged user as reviewed
     */
    static markReviewed(userId: string, action: 'cleared' | 'warned' | 'banned'): Promise<void>;
}
export declare const logMove: typeof AuditService.logMove;
export declare const logSuspiciousActivity: typeof AuditService.logSuspiciousActivity;
export declare const checkReactionTime: typeof AuditService.checkReactionTime;
//# sourceMappingURL=auditService.d.ts.map