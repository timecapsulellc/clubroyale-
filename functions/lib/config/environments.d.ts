/**
 * Environment Configuration
 * Manages development, staging, and production environments
 */
export type Environment = 'development' | 'staging' | 'production';
interface EnvironmentConfig {
    name: Environment;
    projectId: string;
    region: string;
    isProduction: boolean;
    features: {
        enableRateLimiting: boolean;
        enableDetailedLogging: boolean;
        enableMetrics: boolean;
        enableAIAgents: boolean;
    };
    limits: {
        maxConcurrentGames: number;
        maxPlayersPerRoom: number;
        rateLimitWindowMs: number;
        rateLimitMaxRequests: number;
    };
}
/**
 * Get current environment based on Firebase project ID
 */
export declare function getCurrentEnvironment(): Environment;
/**
 * Get configuration for current environment
 */
export declare function getConfig(): EnvironmentConfig;
/**
 * Check if current environment is production
 */
export declare function isProduction(): boolean;
/**
 * Check if a feature is enabled
 */
export declare function isFeatureEnabled(feature: keyof EnvironmentConfig['features']): boolean;
export default getConfig;
//# sourceMappingURL=environments.d.ts.map