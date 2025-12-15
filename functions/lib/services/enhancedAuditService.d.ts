import { FieldValue, Timestamp } from 'firebase-admin/firestore';
interface GameEvent {
    type: string;
    roomId: string;
    playerId?: string;
    data: Record<string, unknown>;
    timestamp: Timestamp;
}
interface DealAudit {
    roomId: string;
    gameType: string;
    roundNumber: number;
    shuffleSeed: string;
    deckCount: number;
    playerCount: number;
    stockpileSize: number;
    timestamp: FieldValue;
}
interface MoveAudit {
    roomId: string;
    roundNumber: number;
    playerId: string;
    action: string;
    cardId?: string;
    cardIds?: string[];
    bidValue?: number;
    isValid: boolean;
    validationError?: string;
    latencyMs: number;
    timestamp: FieldValue;
}
type SuspicionType = 'timing_anomaly' | 'win_rate' | 'collusion_suspected' | 'invalid_moves' | 'reconnect_abuse' | 'superhuman_reaction';
type Severity = 'low' | 'medium' | 'high';
interface SuspiciousActivity {
    roomId: string;
    playerId: string;
    type: SuspicionType;
    severity: Severity;
    details: Record<string, unknown>;
    timestamp: FieldValue;
}
interface CollusionPair {
    player1: string;
    player2: string;
    score: number;
    indicators: string[];
}
interface CollusionReport {
    roomId: string;
    analyzed: Date;
    suspiciousPairs: CollusionPair[];
    overallRisk: 'normal' | 'elevated' | 'high';
}
interface FairnessReport {
    verified: boolean;
    shuffleSeed?: string;
    deckCount?: number;
    message?: string;
    error?: string;
}
export declare const EnhancedAuditService: {
    logGameEvent(event: Omit<GameEvent, "timestamp">): Promise<void>;
    logDeal(audit: Omit<DealAudit, "timestamp">): Promise<void>;
    logMove(audit: Omit<MoveAudit, "timestamp">): Promise<void>;
    flagSuspicious(activity: Omit<SuspiciousActivity, "timestamp">): Promise<void>;
    checkMoveAnomalies(move: Omit<MoveAudit, "timestamp">): Promise<void>;
    getRecentInvalidMoves(playerId: string, minutes: number): Promise<number>;
    analyzeCollusion(roomId: string): Promise<CollusionReport>;
    analyzePlayerPair(moves: MoveAudit[], p1: string, p2: string): {
        score: number;
        indicators: string[];
    };
    getRoomMoves(roomId: string): Promise<MoveAudit[]>;
    incrementPlayerFlag(playerId: string, type: string, severity: Severity): Promise<void>;
    flagUserForReview(playerId: string, reason: string, details: Record<string, unknown>): Promise<void>;
    getPlayerStats(playerId: string): Promise<Record<string, unknown> | null>;
    verifyDealFairness(roomId: string, roundNumber: number): Promise<FairnessReport>;
    getAuditSummary(roomId: string): Promise<Record<string, unknown>>;
};
export default EnhancedAuditService;
//# sourceMappingURL=enhancedAuditService.d.ts.map