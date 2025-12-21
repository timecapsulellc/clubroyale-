"use strict";
/**
 * Cloud Functions Configuration
 * Auto-scaling and resource allocation settings
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.FunctionConfigs = exports.SCHEDULED_CONFIG = exports.BACKGROUND_CONFIG = exports.AI_AGENT_CONFIG = exports.STANDARD_CONFIG = exports.CRITICAL_CONFIG = void 0;
// ============================================
// Function Tiers
// ============================================
/**
 * Critical functions - Always warm, high resources
 * Used for: Game state, settlements, real-time features
 */
exports.CRITICAL_CONFIG = {
    timeoutSeconds: 60,
    memory: '512MB',
    minInstances: 1, // Always keep 1 warm
    maxInstances: 100,
};
/**
 * Standard functions - Normal priority
 * Used for: AI agents, analytics, scheduled tasks
 */
exports.STANDARD_CONFIG = {
    timeoutSeconds: 60,
    memory: '256MB',
    minInstances: 0,
    maxInstances: 50,
};
/**
 * AI Agent functions - More resources for Genkit
 * Used for: All AI/ML inference operations
 */
exports.AI_AGENT_CONFIG = {
    timeoutSeconds: 120, // AI can take longer
    memory: '1GB',
    minInstances: 0,
    maxInstances: 30,
};
/**
 * Background functions - Low priority, cost-optimized
 * Used for: Logging, cleanup, migrations
 */
exports.BACKGROUND_CONFIG = {
    timeoutSeconds: 540, // 9 minutes for batch jobs
    memory: '256MB',
    minInstances: 0,
    maxInstances: 10,
};
/**
 * Scheduled functions - Runs on schedule
 * Used for: Daily/weekly aggregations
 */
exports.SCHEDULED_CONFIG = {
    timeoutSeconds: 300,
    memory: '512MB',
    minInstances: 0,
    maxInstances: 5,
};
// ============================================
// Function Categories
// ============================================
exports.FunctionConfigs = {
    // Critical path - always warm
    critical: [
        'processSettlement',
        'getBotPlay',
        'healthCheck',
    ],
    // AI agents
    aiAgents: [
        'recommendGames',
        'predictChurn',
        'moderateChat',
        'generateStory',
        'analyzeEconomy',
    ],
    // Standard operations
    standard: [
        'createRoom',
        'joinRoom',
        'startGame',
        'recordGameResult',
    ],
    // Background tasks
    background: [
        'auditGameUpdate',
        'cleanupExpiredRooms',
        'aggregateStats',
    ],
    // Scheduled
    scheduled: [
        'calculateWeeklyEngagement',
        'calculateMonthlyMilestones',
        'generateLeaderboards',
    ],
};
exports.default = {
    CRITICAL_CONFIG: exports.CRITICAL_CONFIG,
    STANDARD_CONFIG: exports.STANDARD_CONFIG,
    AI_AGENT_CONFIG: exports.AI_AGENT_CONFIG,
    BACKGROUND_CONFIG: exports.BACKGROUND_CONFIG,
    SCHEDULED_CONFIG: exports.SCHEDULED_CONFIG,
    FunctionConfigs: exports.FunctionConfigs,
};
//# sourceMappingURL=functions-config.js.map