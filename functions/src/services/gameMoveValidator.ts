/**
 * Game Move Validator
 * 
 * Server-side validation for all game moves with:
 * - Turn timing enforcement
 * - Move validity checking
 * - Rate limiting per player
 * - Integration with audit service
 */

import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
import { EnhancedAuditService } from './enhancedAuditService';

// Lazy initialization
let _db: FirebaseFirestore.Firestore | null = null;
const db = () => {
    if (!_db) {
        _db = getFirestore();
    }
    return _db;
};

// ============ Types ============

export type GameType = 'call_break' | 'marriage' | 'teen_patti' | 'in_between';
export type MoveAction = 'bid' | 'playCard' | 'draw' | 'discard' | 'declare' |
    'bet' | 'fold' | 'see' | 'show' | 'pass' | 'visit';

interface GameMoveRequest {
    gameId: string;
    playerId: string;
    action: MoveAction;
    data: Record<string, unknown>;
    clientTimestamp?: number;
}

interface ValidationResult {
    isValid: boolean;
    error?: string;
    latencyMs: number;
}

interface TurnTimingConfig {
    minResponseMs: number;   // Minimum time (faster = suspicious)
    maxTurnMs: number;       // Maximum time before auto-action
    warningMs: number;       // Warning before timeout
}

// ============ Configuration ============

const TIMING_CONFIG: Record<GameType, TurnTimingConfig> = {
    call_break: {
        minResponseMs: 150,    // Minimum 150ms reaction
        maxTurnMs: 30000,      // 30 second turn limit
        warningMs: 25000,      // Warning at 25 seconds
    },
    marriage: {
        minResponseMs: 200,    // Minimum 200ms for draw/discard
        maxTurnMs: 45000,      // 45 seconds (more complex)
        warningMs: 40000,
    },
    teen_patti: {
        minResponseMs: 300,    // Minimum 300ms for betting decisions
        maxTurnMs: 30000,
        warningMs: 25000,
    },
    in_between: {
        minResponseMs: 200,
        maxTurnMs: 20000,      // 20 seconds (simpler game)
        warningMs: 15000,
    },
};

// Rate limiting per player
const RATE_LIMITS = {
    movesPerMinute: 30,
    movesPerSecond: 3,
};

// ============ Move Validation Service ============

export const GameMoveValidator = {

    /**
     * Validate a game move server-side
     */
    async validateMove(request: GameMoveRequest, gameType: GameType): Promise<ValidationResult> {
        const startTime = Date.now();
        const clientTimestamp = request.clientTimestamp || startTime;
        const latencyMs = startTime - clientTimestamp;

        try {
            // 1. Rate limiting check
            const rateLimitResult = await this.checkRateLimit(request.playerId);
            if (!rateLimitResult.allowed) {
                await this.logMove(request, gameType, false, 'Rate limit exceeded', latencyMs);
                return { isValid: false, error: 'Too many moves. Please slow down.', latencyMs };
            }

            // 2. Timing check (too fast = suspicious)
            const timingConfig = TIMING_CONFIG[gameType];
            if (latencyMs >= 0 && latencyMs < timingConfig.minResponseMs) {
                // Log but don't reject - let audit service handle flagging
                await EnhancedAuditService.flagSuspicious({
                    roomId: request.gameId,
                    playerId: request.playerId,
                    type: 'superhuman_reaction',
                    severity: latencyMs < 50 ? 'high' : 'medium',
                    details: {
                        latencyMs,
                        action: request.action,
                        threshold: timingConfig.minResponseMs,
                    },
                });
            }

            // 3. Turn validation (is it this player's turn?)
            const turnValid = await this.validateTurn(request.gameId, request.playerId);
            if (!turnValid) {
                await this.logMove(request, gameType, false, 'Not your turn', latencyMs);
                return { isValid: false, error: 'Not your turn', latencyMs };
            }

            // 4. Game-specific validation
            const gameValid = await this.validateGameMove(request, gameType);
            if (!gameValid.isValid) {
                await this.logMove(request, gameType, false, gameValid.error!, latencyMs);
                return { isValid: false, error: gameValid.error, latencyMs };
            }

            // 5. All checks passed
            await this.logMove(request, gameType, true, undefined, latencyMs);
            await this.recordMove(request.playerId);

            return { isValid: true, latencyMs };

        } catch (error) {
            console.error('Move validation error:', error);
            return {
                isValid: false,
                error: 'Validation error',
                latencyMs: Date.now() - startTime
            };
        }
    },

    /**
     * Check if player is within rate limits
     */
    async checkRateLimit(playerId: string): Promise<{ allowed: boolean }> {
        const now = Date.now();
        const oneMinuteAgo = now - 60000;
        const oneSecondAgo = now - 1000;

        const ref = db().collection('player_move_timestamps').doc(playerId);
        const doc = await ref.get();

        if (!doc.exists) {
            return { allowed: true };
        }

        const data = doc.data()!;
        const recentMoves: number[] = data.moves || [];

        // Filter to last minute and last second
        const movesLastMinute = recentMoves.filter(t => t > oneMinuteAgo);
        const movesLastSecond = recentMoves.filter(t => t > oneSecondAgo);

        if (movesLastMinute.length >= RATE_LIMITS.movesPerMinute) {
            return { allowed: false };
        }
        if (movesLastSecond.length >= RATE_LIMITS.movesPerSecond) {
            return { allowed: false };
        }

        return { allowed: true };
    },

    /**
     * Record a move timestamp for rate limiting
     */
    async recordMove(playerId: string): Promise<void> {
        const ref = db().collection('player_move_timestamps').doc(playerId);
        const now = Date.now();
        const oneMinuteAgo = now - 60000;

        await db().runTransaction(async (txn) => {
            const doc = await txn.get(ref);
            const data = doc.exists ? doc.data()! : { moves: [] };

            // Keep only last minute of moves
            const recentMoves: number[] = (data.moves || []).filter((t: number) => t > oneMinuteAgo);
            recentMoves.push(now);

            txn.set(ref, { moves: recentMoves, lastMove: now });
        });
    },

    /**
     * Validate it's the player's turn
     */
    async validateTurn(gameId: string, playerId: string): Promise<boolean> {
        const gameDoc = await db().collection('games').doc(gameId).get();

        if (!gameDoc.exists) {
            return false;
        }

        const state = gameDoc.data()!;
        return state.currentPlayerId === playerId;
    },

    /**
     * Game-specific move validation
     */
    async validateGameMove(
        request: GameMoveRequest,
        gameType: GameType
    ): Promise<{ isValid: boolean; error?: string }> {

        switch (gameType) {
            case 'call_break':
                return this.validateCallBreakMove(request);
            case 'marriage':
                return this.validateMarriageMove(request);
            case 'teen_patti':
                return this.validateTeenPattiMove(request);
            case 'in_between':
                return this.validateInBetweenMove(request);
            default:
                return { isValid: false, error: 'Unknown game type' };
        }
    },

    /**
     * Call Break specific validation
     */
    async validateCallBreakMove(request: GameMoveRequest): Promise<{ isValid: boolean; error?: string }> {
        const { action, data } = request;

        if (action === 'bid') {
            const bid = data.bid as number;
            if (typeof bid !== 'number' || bid < 1 || bid > 13) {
                return { isValid: false, error: 'Invalid bid value (must be 1-13)' };
            }
        }

        if (action === 'playCard') {
            const card = data.card as string;
            if (typeof card !== 'string' || !card) {
                return { isValid: false, error: 'Invalid card' };
            }

            // Additional validation: verify card is in player's hand
            const gameDoc = await db().collection('games').doc(request.gameId).get();
            if (gameDoc.exists) {
                const state = gameDoc.data()!;
                const hand = state.hands?.[request.playerId] || [];
                if (!hand.includes(card)) {
                    return { isValid: false, error: 'Card not in hand' };
                }
            }
        }

        return { isValid: true };
    },

    /**
     * Marriage specific validation
     */
    async validateMarriageMove(request: GameMoveRequest): Promise<{ isValid: boolean; error?: string }> {
        const { action, data } = request;

        if (action === 'discard') {
            const card = data.card as string;
            if (typeof card !== 'string' || !card) {
                return { isValid: false, error: 'Invalid discard card' };
            }
        }

        if (action === 'visit') {
            // Visit requires 3 pure sequences - would need game state to verify
        }

        return { isValid: true };
    },

    /**
     * Teen Patti specific validation
     */
    async validateTeenPattiMove(request: GameMoveRequest): Promise<{ isValid: boolean; error?: string }> {
        const { action, data } = request;

        if (action === 'bet') {
            const amount = data.amount as number;
            if (typeof amount !== 'number' || amount < 0) {
                return { isValid: false, error: 'Invalid bet amount' };
            }
        }

        return { isValid: true };
    },

    /**
     * In-Between specific validation
     */
    async validateInBetweenMove(request: GameMoveRequest): Promise<{ isValid: boolean; error?: string }> {
        const { action, data } = request;

        if (action === 'bet') {
            const amount = data.amount as number;
            if (typeof amount !== 'number' || amount < 0) {
                return { isValid: false, error: 'Invalid bet amount' };
            }
        }

        return { isValid: true };
    },

    /**
     * Log move to audit service
     */
    async logMove(
        request: GameMoveRequest,
        gameType: GameType,
        isValid: boolean,
        error: string | undefined,
        latencyMs: number
    ): Promise<void> {
        await EnhancedAuditService.logMove({
            roomId: request.gameId,
            roundNumber: 0, // Would get from game state
            playerId: request.playerId,
            action: request.action,
            isValid,
            validationError: error,
            latencyMs,
        });
    },

    /**
     * Get turn time remaining for a game
     */
    getTurnTimeRemaining(
        gameType: GameType,
        turnStartTime: number
    ): { remaining: number; isWarning: boolean; isExpired: boolean } {
        const config = TIMING_CONFIG[gameType];
        const elapsed = Date.now() - turnStartTime;
        const remaining = config.maxTurnMs - elapsed;

        return {
            remaining: Math.max(0, remaining),
            isWarning: remaining <= (config.maxTurnMs - config.warningMs) && remaining > 0,
            isExpired: remaining <= 0,
        };
    },
};

export default GameMoveValidator;
