/**
 * Cloud Functions Configuration
 * Auto-scaling and resource allocation settings
 */

// Define config type inline (Firebase v2 uses GlobalOptions)
interface FunctionConfig {
    timeoutSeconds: number;
    memory: '128MiB' | '256MiB' | '512MiB' | '1GiB' | '2GiB' | '4GiB';
    minInstances: number;
    maxInstances: number;
}

// ============================================
// Function Tiers
// ============================================

/**
 * Critical functions - Always warm, high resources
 * Used for: Game state, settlements, real-time features
 */
export const CRITICAL_CONFIG: FunctionConfig = {
    timeoutSeconds: 60,
    memory: '512MiB',
    minInstances: 1,  // Always keep 1 warm
    maxInstances: 100,
};

/**
 * Standard functions - Normal priority
 * Used for: AI agents, analytics, scheduled tasks
 */
export const STANDARD_CONFIG: FunctionConfig = {
    timeoutSeconds: 60,
    memory: '256MiB',
    minInstances: 0,
    maxInstances: 50,
};

/**
 * AI Agent functions - More resources for Genkit
 * Used for: All AI/ML inference operations
 */
export const AI_AGENT_CONFIG: FunctionConfig = {
    timeoutSeconds: 120,  // AI can take longer
    memory: '1GiB',
    minInstances: 0,
    maxInstances: 30,
};

/**
 * Background functions - Low priority, cost-optimized
 * Used for: Logging, cleanup, migrations
 */
export const BACKGROUND_CONFIG: FunctionConfig = {
    timeoutSeconds: 540,  // 9 minutes for batch jobs
    memory: '256MiB',
    minInstances: 0,
    maxInstances: 10,
};

/**
 * Scheduled functions - Runs on schedule
 * Used for: Daily/weekly aggregations
 */
export const SCHEDULED_CONFIG: FunctionConfig = {
    timeoutSeconds: 300,
    memory: '512MiB',
    minInstances: 0,
    maxInstances: 5,
};

// ============================================
// Function Categories
// ============================================

export const FunctionConfigs = {
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

export default {
    CRITICAL_CONFIG,
    STANDARD_CONFIG,
    AI_AGENT_CONFIG,
    BACKGROUND_CONFIG,
    SCHEDULED_CONFIG,
    FunctionConfigs,
};
