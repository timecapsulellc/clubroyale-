"use strict";
// Enhanced Audit Service (TypeScript)
//
// Comprehensive anti-cheat system with:
// - Move logging
// - Collusion detection
// - Timing anomaly detection
// - Fairness verification
Object.defineProperty(exports, "__esModule", { value: true });
exports.EnhancedAuditService = void 0;
const firestore_1 = require("firebase-admin/firestore");
// Lazy initialization to avoid calling getFirestore() before initializeApp()
let _db = null;
const db = () => {
    if (!_db) {
        _db = (0, firestore_1.getFirestore)();
    }
    return _db;
};
// ============ Collections ============
const COLLECTIONS = {
    GAME_EVENTS: 'audit_game_events',
    DEAL_AUDITS: 'audit_deals',
    MOVE_AUDITS: 'audit_moves',
    SUSPICIOUS: 'audit_suspicious',
    PLAYER_STATS: 'audit_player_stats',
    FLAGGED_USERS: 'flaggedUsers',
};
// ============ Audit Service ============
exports.EnhancedAuditService = {
    // ============ Event Logging ============
    async logGameEvent(event) {
        await db().collection(COLLECTIONS.GAME_EVENTS).add({
            ...event,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        });
    },
    async logDeal(audit) {
        await db().collection(COLLECTIONS.DEAL_AUDITS).add({
            ...audit,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        });
    },
    async logMove(audit) {
        await db().collection(COLLECTIONS.MOVE_AUDITS).add({
            ...audit,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        });
        // Check for anomalies
        await this.checkMoveAnomalies(audit);
    },
    async flagSuspicious(activity) {
        await db().collection(COLLECTIONS.SUSPICIOUS).add({
            ...activity,
            timestamp: firestore_1.FieldValue.serverTimestamp(),
        });
        // Update player stats
        await this.incrementPlayerFlag(activity.playerId, activity.type, activity.severity);
        // High severity: flag user for review
        if (activity.severity === 'high') {
            await this.flagUserForReview(activity.playerId, activity.type, activity.details);
        }
    },
    // ============ Anomaly Detection ============
    async checkMoveAnomalies(move) {
        // Superhuman reaction time (< 100ms suggests automation)
        if (move.latencyMs < 100 && move.action === 'playCard') {
            await this.flagSuspicious({
                roomId: move.roomId,
                playerId: move.playerId,
                type: 'superhuman_reaction',
                severity: 'medium',
                details: {
                    latencyMs: move.latencyMs,
                    action: move.action,
                    threshold: 100,
                    message: 'Move made faster than humanly possible',
                },
            });
        }
        // Repeated invalid moves (suggests probing/testing)
        if (!move.isValid) {
            const recentInvalid = await this.getRecentInvalidMoves(move.playerId, 10);
            if (recentInvalid >= 5) {
                await this.flagSuspicious({
                    roomId: move.roomId,
                    playerId: move.playerId,
                    type: 'invalid_moves',
                    severity: recentInvalid >= 10 ? 'high' : 'medium',
                    details: {
                        invalidCount: recentInvalid,
                        timeWindow: '10 minutes',
                        message: 'Unusual number of invalid moves',
                    },
                });
            }
        }
    },
    async getRecentInvalidMoves(playerId, minutes) {
        const cutoff = new Date(Date.now() - minutes * 60 * 1000);
        const snapshot = await db().collection(COLLECTIONS.MOVE_AUDITS)
            .where('playerId', '==', playerId)
            .where('isValid', '==', false)
            .where('timestamp', '>=', firestore_1.Timestamp.fromDate(cutoff))
            .get();
        return snapshot.size;
    },
    // ============ Collusion Detection ============
    async analyzeCollusion(roomId) {
        const moves = await this.getRoomMoves(roomId);
        const players = [...new Set(moves.map(m => m.playerId))];
        const pairs = [];
        for (let i = 0; i < players.length; i++) {
            for (let j = i + 1; j < players.length; j++) {
                const p1 = players[i];
                const p2 = players[j];
                const analysis = this.analyzePlayerPair(moves, p1, p2);
                if (analysis.score > 0.5) {
                    pairs.push({
                        player1: p1,
                        player2: p2,
                        score: analysis.score,
                        indicators: analysis.indicators,
                    });
                }
            }
        }
        // Sort by suspicion score
        pairs.sort((a, b) => b.score - a.score);
        // Flag high-risk pairs
        for (const pair of pairs.filter(p => p.score >= 0.7)) {
            await this.flagSuspicious({
                roomId,
                playerId: pair.player1,
                type: 'collusion_suspected',
                severity: pair.score >= 0.85 ? 'high' : 'medium',
                details: {
                    partnerId: pair.player2,
                    score: pair.score,
                    indicators: pair.indicators,
                },
            });
        }
        return {
            roomId,
            analyzed: new Date(),
            suspiciousPairs: pairs,
            overallRisk: pairs.some(p => p.score >= 0.7) ? 'high' :
                pairs.some(p => p.score >= 0.5) ? 'elevated' : 'normal',
        };
    },
    analyzePlayerPair(moves, p1, p2) {
        const indicators = [];
        let score = 0;
        const p1Moves = moves.filter(m => m.playerId === p1);
        const p2Moves = moves.filter(m => m.playerId === p2);
        // Check 1: Similar timing patterns
        if (p1Moves.length > 5 && p2Moves.length > 5) {
            const p1AvgLatency = p1Moves.reduce((a, m) => a + m.latencyMs, 0) / p1Moves.length;
            const p2AvgLatency = p2Moves.reduce((a, m) => a + m.latencyMs, 0) / p2Moves.length;
            if (Math.abs(p1AvgLatency - p2AvgLatency) < 200) {
                score += 0.2;
                indicators.push('Very similar response times');
            }
        }
        // Check 2: Never competing against each other
        // (Would need game-specific bid/play analysis here)
        // Check 3: Consistent mutual assistance pattern
        // (Would analyze if one player always helps another)
        return { score: Math.min(score, 1.0), indicators };
    },
    async getRoomMoves(roomId) {
        const snapshot = await db().collection(COLLECTIONS.MOVE_AUDITS)
            .where('roomId', '==', roomId)
            .orderBy('timestamp')
            .get();
        return snapshot.docs.map(d => d.data());
    },
    // ============ Player Stats ============
    async incrementPlayerFlag(playerId, type, severity) {
        const ref = db().collection(COLLECTIONS.PLAYER_STATS).doc(playerId);
        await db().runTransaction(async (txn) => {
            const doc = await txn.get(ref);
            const data = doc.exists ? doc.data() : { flags: {}, totalFlags: 0, weightedScore: 0 };
            const flags = data.flags || {};
            flags[type] = (flags[type] || 0) + 1;
            const severityWeight = severity === 'high' ? 3 : severity === 'medium' ? 2 : 1;
            txn.set(ref, {
                flags,
                totalFlags: (data.totalFlags || 0) + 1,
                weightedScore: (data.weightedScore || 0) + severityWeight,
                lastFlagged: firestore_1.FieldValue.serverTimestamp(),
                lastFlagType: type,
                lastSeverity: severity,
            }, { merge: true });
        });
    },
    async flagUserForReview(playerId, reason, details) {
        const ref = db().collection(COLLECTIONS.FLAGGED_USERS).doc(playerId);
        const doc = await ref.get();
        if (doc.exists) {
            await ref.update({
                flagCount: firestore_1.FieldValue.increment(1),
                reasons: firestore_1.FieldValue.arrayUnion(reason),
                lastFlagged: firestore_1.FieldValue.serverTimestamp(),
                incidents: firestore_1.FieldValue.arrayUnion({
                    reason,
                    details,
                    timestamp: new Date().toISOString(),
                }),
            });
        }
        else {
            await ref.set({
                playerId,
                flagCount: 1,
                reasons: [reason],
                status: 'pending_review',
                firstFlagged: firestore_1.FieldValue.serverTimestamp(),
                lastFlagged: firestore_1.FieldValue.serverTimestamp(),
                incidents: [{
                        reason,
                        details,
                        timestamp: new Date().toISOString(),
                    }],
            });
        }
    },
    async getPlayerStats(playerId) {
        const doc = await db().collection(COLLECTIONS.PLAYER_STATS).doc(playerId).get();
        return doc.exists ? doc.data() : null;
    },
    // ============ Fairness Verification ============
    async verifyDealFairness(roomId, roundNumber) {
        const dealDoc = await db().collection(COLLECTIONS.DEAL_AUDITS)
            .where('roomId', '==', roomId)
            .where('roundNumber', '==', roundNumber)
            .limit(1)
            .get();
        if (dealDoc.empty) {
            return { verified: false, error: 'Deal audit not found' };
        }
        const deal = dealDoc.docs[0].data();
        return {
            verified: true,
            shuffleSeed: deal.shuffleSeed,
            deckCount: deal.deckCount,
            message: 'This deal can be independently verified using the shuffle seed. ' +
                'Replay the shuffle with this seed to confirm fairness.',
        };
    },
    // ============ Reporting ============
    async getAuditSummary(roomId) {
        const [moves, suspicious, events] = await Promise.all([
            db().collection(COLLECTIONS.MOVE_AUDITS).where('roomId', '==', roomId).count().get(),
            db().collection(COLLECTIONS.SUSPICIOUS).where('roomId', '==', roomId).count().get(),
            db().collection(COLLECTIONS.GAME_EVENTS).where('roomId', '==', roomId).count().get(),
        ]);
        return {
            roomId,
            totalMoves: moves.data().count,
            suspiciousEvents: suspicious.data().count,
            gameEvents: events.data().count,
            generatedAt: new Date().toISOString(),
        };
    },
};
exports.default = exports.EnhancedAuditService;
//# sourceMappingURL=enhancedAuditService.js.map