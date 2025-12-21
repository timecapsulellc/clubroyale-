/**
 * Cloud Functions Configuration
 * Auto-scaling and resource allocation settings
 */
interface FunctionConfig {
    timeoutSeconds: number;
    memory: '128MB' | '256MB' | '512MB' | '1GB' | '2GB' | '4GB';
    minInstances: number;
    maxInstances: number;
}
/**
 * Critical functions - Always warm, high resources
 * Used for: Game state, settlements, real-time features
 */
export declare const CRITICAL_CONFIG: FunctionConfig;
/**
 * Standard functions - Normal priority
 * Used for: AI agents, analytics, scheduled tasks
 */
export declare const STANDARD_CONFIG: FunctionConfig;
/**
 * AI Agent functions - More resources for Genkit
 * Used for: All AI/ML inference operations
 */
export declare const AI_AGENT_CONFIG: FunctionConfig;
/**
 * Background functions - Low priority, cost-optimized
 * Used for: Logging, cleanup, migrations
 */
export declare const BACKGROUND_CONFIG: FunctionConfig;
/**
 * Scheduled functions - Runs on schedule
 * Used for: Daily/weekly aggregations
 */
export declare const SCHEDULED_CONFIG: FunctionConfig;
export declare const FunctionConfigs: {
    critical: string[];
    aiAgents: string[];
    standard: string[];
    background: string[];
    scheduled: string[];
};
declare const _default: {
    CRITICAL_CONFIG: FunctionConfig;
    STANDARD_CONFIG: FunctionConfig;
    AI_AGENT_CONFIG: FunctionConfig;
    BACKGROUND_CONFIG: FunctionConfig;
    SCHEDULED_CONFIG: FunctionConfig;
    FunctionConfigs: {
        critical: string[];
        aiAgents: string[];
        standard: string[];
        background: string[];
        scheduled: string[];
    };
};
export default _default;
//# sourceMappingURL=functions-config.d.ts.map