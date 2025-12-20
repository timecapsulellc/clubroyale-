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

const configs: Record<Environment, EnvironmentConfig> = {
    development: {
        name: 'development',
        projectId: 'taasclub-app-dev',
        region: 'us-central1',
        isProduction: false,
        features: {
            enableRateLimiting: false,
            enableDetailedLogging: true,
            enableMetrics: false,
            enableAIAgents: true,
        },
        limits: {
            maxConcurrentGames: 100,
            maxPlayersPerRoom: 8,
            rateLimitWindowMs: 60000,
            rateLimitMaxRequests: 1000, // Very high for dev
        },
    },
    staging: {
        name: 'staging',
        projectId: 'clubroyale-staging',
        region: 'us-central1',
        isProduction: false,
        features: {
            enableRateLimiting: true,
            enableDetailedLogging: true,
            enableMetrics: true,
            enableAIAgents: true,
        },
        limits: {
            maxConcurrentGames: 500,
            maxPlayersPerRoom: 8,
            rateLimitWindowMs: 60000,
            rateLimitMaxRequests: 100,
        },
    },
    production: {
        name: 'production',
        projectId: 'taasclub-app',
        region: 'us-central1',
        isProduction: true,
        features: {
            enableRateLimiting: true,
            enableDetailedLogging: false,
            enableMetrics: true,
            enableAIAgents: true,
        },
        limits: {
            maxConcurrentGames: 10000,
            maxPlayersPerRoom: 8,
            rateLimitWindowMs: 60000,
            rateLimitMaxRequests: 100,
        },
    },
};

/**
 * Get current environment based on Firebase project ID
 */
export function getCurrentEnvironment(): Environment {
    const projectId = process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID;

    if (projectId?.includes('staging')) {
        return 'staging';
    }
    if (projectId?.includes('dev')) {
        return 'development';
    }
    return 'production';
}

/**
 * Get configuration for current environment
 */
export function getConfig(): EnvironmentConfig {
    const env = getCurrentEnvironment();
    return configs[env];
}

/**
 * Check if current environment is production
 */
export function isProduction(): boolean {
    return getConfig().isProduction;
}

/**
 * Check if a feature is enabled
 */
export function isFeatureEnabled(feature: keyof EnvironmentConfig['features']): boolean {
    return getConfig().features[feature];
}

export default getConfig;
