/**
 * Analytics Agent - User Insights & Engagement Analysis
 *
 * Features:
 * - Engagement prediction with Tree of Thoughts reasoning
 * - Trend analysis
 * - User behavior insights with multi-factor analysis
 * - Churn prediction with backtracking
 *
 * Enhanced with Tree of Thoughts (ToT) for deliberate problem-solving
 */
import { z } from 'genkit';
/**
 * Predict Engagement - Enhanced with Tree of Thoughts
 *
 * Multi-factor analysis with backtracking:
 * 1. Session Patterns (frequency, duration, time of day)
 * 2. Social Connections (friend count, interaction rate)
 * 3. Spending Behavior (diamond balance, transactions)
 * 4. Engagement Trajectory (week-over-week change)
 */
export declare const predictEngagementFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    userMetrics: z.ZodObject<{
        totalGames: z.ZodNumber;
        gamesThisWeek: z.ZodNumber;
        avgSessionLength: z.ZodNumber;
        friendCount: z.ZodNumber;
        diamondBalance: z.ZodNumber;
        lastLoginDaysAgo: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        diamondBalance: number;
        totalGames: number;
        gamesThisWeek: number;
        avgSessionLength: number;
        friendCount: number;
        lastLoginDaysAgo: number;
    }, {
        diamondBalance: number;
        totalGames: number;
        gamesThisWeek: number;
        avgSessionLength: number;
        friendCount: number;
        lastLoginDaysAgo: number;
    }>;
    recentActivity: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    userMetrics: {
        diamondBalance: number;
        totalGames: number;
        gamesThisWeek: number;
        avgSessionLength: number;
        friendCount: number;
        lastLoginDaysAgo: number;
    };
    recentActivity?: string[] | undefined;
}, {
    userId: string;
    userMetrics: {
        diamondBalance: number;
        totalGames: number;
        gamesThisWeek: number;
        avgSessionLength: number;
        friendCount: number;
        lastLoginDaysAgo: number;
    };
    recentActivity?: string[] | undefined;
}>, z.ZodObject<{
    engagementScore: z.ZodNumber;
    churnRisk: z.ZodEnum<["low", "medium", "high"]>;
    predictedNextAction: z.ZodString;
    retentionStrategies: z.ZodArray<z.ZodString, "many">;
    upsellOpportunities: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    engagementScore: number;
    churnRisk: "high" | "medium" | "low";
    predictedNextAction: string;
    retentionStrategies: string[];
    upsellOpportunities?: string[] | undefined;
}, {
    engagementScore: number;
    churnRisk: "high" | "medium" | "low";
    predictedNextAction: string;
    retentionStrategies: string[];
    upsellOpportunities?: string[] | undefined;
}>, z.ZodTypeAny>;
export declare const analyzeTrendsFlow: import("genkit").CallableFlow<z.ZodObject<{
    timeRange: z.ZodEnum<["day", "week", "month"]>;
    metrics: z.ZodObject<{
        totalUsers: z.ZodNumber;
        activeUsers: z.ZodNumber;
        gamesPlayed: z.ZodNumber;
        storiesPosted: z.ZodNumber;
        diamondsTransferred: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    }, {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    }>;
    previousPeriod: z.ZodOptional<z.ZodObject<{
        totalUsers: z.ZodNumber;
        activeUsers: z.ZodNumber;
        gamesPlayed: z.ZodNumber;
        storiesPosted: z.ZodNumber;
        diamondsTransferred: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    }, {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    }>>;
    topContent: z.ZodOptional<z.ZodArray<z.ZodObject<{
        id: z.ZodString;
        type: z.ZodString;
        engagement: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        type: string;
        id: string;
        engagement: number;
    }, {
        type: string;
        id: string;
        engagement: number;
    }>, "many">>;
}, "strip", z.ZodTypeAny, {
    timeRange: "day" | "week" | "month";
    metrics: {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    };
    previousPeriod?: {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    } | undefined;
    topContent?: {
        type: string;
        id: string;
        engagement: number;
    }[] | undefined;
}, {
    timeRange: "day" | "week" | "month";
    metrics: {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    };
    previousPeriod?: {
        gamesPlayed: number;
        totalUsers: number;
        activeUsers: number;
        storiesPosted: number;
        diamondsTransferred: number;
    } | undefined;
    topContent?: {
        type: string;
        id: string;
        engagement: number;
    }[] | undefined;
}>, z.ZodObject<{
    insights: z.ZodArray<z.ZodObject<{
        metric: z.ZodString;
        trend: z.ZodEnum<["up", "down", "stable"]>;
        change: z.ZodNumber;
        insight: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        metric: string;
        trend: "up" | "down" | "stable";
        change: number;
        insight: string;
    }, {
        metric: string;
        trend: "up" | "down" | "stable";
        change: number;
        insight: string;
    }>, "many">;
    recommendations: z.ZodArray<z.ZodString, "many">;
    highlights: z.ZodArray<z.ZodString, "many">;
    concerns: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    recommendations: string[];
    highlights: string[];
    insights: {
        metric: string;
        trend: "up" | "down" | "stable";
        change: number;
        insight: string;
    }[];
    concerns?: string[] | undefined;
}, {
    recommendations: string[];
    highlights: string[];
    insights: {
        metric: string;
        trend: "up" | "down" | "stable";
        change: number;
        insight: string;
    }[];
    concerns?: string[] | undefined;
}>, z.ZodTypeAny>;
export declare const predictEngagement: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    engagementScore: number;
    churnRisk: "high" | "medium" | "low";
    predictedNextAction: string;
    retentionStrategies: string[];
    upsellOpportunities?: string[] | undefined;
}>, unknown>;
export declare const analyzeTrends: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    recommendations: string[];
    highlights: string[];
    insights: {
        metric: string;
        trend: "up" | "down" | "stable";
        change: number;
        insight: string;
    }[];
    concerns?: string[] | undefined;
}>, unknown>;
//# sourceMappingURL=analytics_agent.d.ts.map