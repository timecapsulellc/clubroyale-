/**
 * Analytics Agent
 * Churn prediction y engagement scoring
 */
import { z } from 'genkit';
/**
 * Predict churn risk for a user
 */
export declare const predictChurnFlow: import("genkit").CallableFlow<z.ZodObject<{
    userData: z.ZodObject<{
        userId: z.ZodString;
        lastLogin: z.ZodString;
        loginStreak: z.ZodNumber;
        totalGamesPlayed: z.ZodNumber;
        gamesLast7Days: z.ZodNumber;
        gamesLast30Days: z.ZodNumber;
        diamondBalance: z.ZodNumber;
        diamondSpentTotal: z.ZodNumber;
        friendCount: z.ZodNumber;
        clubMemberships: z.ZodNumber;
        accountAgedays: z.ZodNumber;
        lastPurchase: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        lastPurchase?: string | undefined;
    }, {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        lastPurchase?: string | undefined;
    }>;
}, "strip", z.ZodTypeAny, {
    userData: {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        lastPurchase?: string | undefined;
    };
}, {
    userData: {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        lastPurchase?: string | undefined;
    };
}>, z.ZodObject<{
    riskLevel: z.ZodEnum<["low", "medium", "high", "critical"]>;
    riskScore: z.ZodNumber;
    factors: z.ZodArray<z.ZodString, "many">;
    recommendedActions: z.ZodArray<z.ZodString, "many">;
    predictedChurnDays: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    riskLevel: "high" | "medium" | "low" | "critical";
    riskScore: number;
    factors: string[];
    recommendedActions: string[];
    predictedChurnDays?: number | undefined;
}, {
    riskLevel: "high" | "medium" | "low" | "critical";
    riskScore: number;
    factors: string[];
    recommendedActions: string[];
    predictedChurnDays?: number | undefined;
}>, z.ZodTypeAny>;
/**
 * Calculate engagement score for a user
 */
export declare const calculateEngagementFlow: import("genkit").CallableFlow<z.ZodObject<{
    userData: z.ZodObject<{
        userId: z.ZodString;
        lastLogin: z.ZodString;
        loginStreak: z.ZodNumber;
        totalGamesPlayed: z.ZodNumber;
        gamesLast7Days: z.ZodNumber;
        gamesLast30Days: z.ZodNumber;
        diamondBalance: z.ZodNumber;
        diamondSpentTotal: z.ZodNumber;
        friendCount: z.ZodNumber;
        clubMemberships: z.ZodNumber;
        accountAgedays: z.ZodNumber;
        messagesLast30Days: z.ZodOptional<z.ZodNumber>;
        storiesPosted: z.ZodOptional<z.ZodNumber>;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        storiesPosted?: number | undefined;
        messagesLast30Days?: number | undefined;
    }, {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        storiesPosted?: number | undefined;
        messagesLast30Days?: number | undefined;
    }>;
}, "strip", z.ZodTypeAny, {
    userData: {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        storiesPosted?: number | undefined;
        messagesLast30Days?: number | undefined;
    };
}, {
    userData: {
        userId: string;
        diamondBalance: number;
        loginStreak: number;
        friendCount: number;
        lastLogin: string;
        totalGamesPlayed: number;
        gamesLast7Days: number;
        gamesLast30Days: number;
        diamondSpentTotal: number;
        clubMemberships: number;
        accountAgedays: number;
        storiesPosted?: number | undefined;
        messagesLast30Days?: number | undefined;
    };
}>, z.ZodObject<{
    overallScore: z.ZodNumber;
    dimensions: z.ZodObject<{
        activity: z.ZodNumber;
        social: z.ZodNumber;
        spending: z.ZodNumber;
        loyalty: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        social: number;
        activity: number;
        spending: number;
        loyalty: number;
    }, {
        social: number;
        activity: number;
        spending: number;
        loyalty: number;
    }>;
    tier: z.ZodEnum<["casual", "regular", "engaged", "power_user", "whale"]>;
    insights: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    tier: "casual" | "regular" | "engaged" | "power_user" | "whale";
    insights: string[];
    overallScore: number;
    dimensions: {
        social: number;
        activity: number;
        spending: number;
        loyalty: number;
    };
}, {
    tier: "casual" | "regular" | "engaged" | "power_user" | "whale";
    insights: string[];
    overallScore: number;
    dimensions: {
        social: number;
        activity: number;
        spending: number;
        loyalty: number;
    };
}>, z.ZodTypeAny>;
declare const _default: {
    predictChurnFlow: import("genkit").CallableFlow<z.ZodObject<{
        userData: z.ZodObject<{
            userId: z.ZodString;
            lastLogin: z.ZodString;
            loginStreak: z.ZodNumber;
            totalGamesPlayed: z.ZodNumber;
            gamesLast7Days: z.ZodNumber;
            gamesLast30Days: z.ZodNumber;
            diamondBalance: z.ZodNumber;
            diamondSpentTotal: z.ZodNumber;
            friendCount: z.ZodNumber;
            clubMemberships: z.ZodNumber;
            accountAgedays: z.ZodNumber;
            lastPurchase: z.ZodOptional<z.ZodString>;
        }, "strip", z.ZodTypeAny, {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            lastPurchase?: string | undefined;
        }, {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            lastPurchase?: string | undefined;
        }>;
    }, "strip", z.ZodTypeAny, {
        userData: {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            lastPurchase?: string | undefined;
        };
    }, {
        userData: {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            lastPurchase?: string | undefined;
        };
    }>, z.ZodObject<{
        riskLevel: z.ZodEnum<["low", "medium", "high", "critical"]>;
        riskScore: z.ZodNumber;
        factors: z.ZodArray<z.ZodString, "many">;
        recommendedActions: z.ZodArray<z.ZodString, "many">;
        predictedChurnDays: z.ZodOptional<z.ZodNumber>;
    }, "strip", z.ZodTypeAny, {
        riskLevel: "high" | "medium" | "low" | "critical";
        riskScore: number;
        factors: string[];
        recommendedActions: string[];
        predictedChurnDays?: number | undefined;
    }, {
        riskLevel: "high" | "medium" | "low" | "critical";
        riskScore: number;
        factors: string[];
        recommendedActions: string[];
        predictedChurnDays?: number | undefined;
    }>, z.ZodTypeAny>;
    calculateEngagementFlow: import("genkit").CallableFlow<z.ZodObject<{
        userData: z.ZodObject<{
            userId: z.ZodString;
            lastLogin: z.ZodString;
            loginStreak: z.ZodNumber;
            totalGamesPlayed: z.ZodNumber;
            gamesLast7Days: z.ZodNumber;
            gamesLast30Days: z.ZodNumber;
            diamondBalance: z.ZodNumber;
            diamondSpentTotal: z.ZodNumber;
            friendCount: z.ZodNumber;
            clubMemberships: z.ZodNumber;
            accountAgedays: z.ZodNumber;
            messagesLast30Days: z.ZodOptional<z.ZodNumber>;
            storiesPosted: z.ZodOptional<z.ZodNumber>;
        }, "strip", z.ZodTypeAny, {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            storiesPosted?: number | undefined;
            messagesLast30Days?: number | undefined;
        }, {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            storiesPosted?: number | undefined;
            messagesLast30Days?: number | undefined;
        }>;
    }, "strip", z.ZodTypeAny, {
        userData: {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            storiesPosted?: number | undefined;
            messagesLast30Days?: number | undefined;
        };
    }, {
        userData: {
            userId: string;
            diamondBalance: number;
            loginStreak: number;
            friendCount: number;
            lastLogin: string;
            totalGamesPlayed: number;
            gamesLast7Days: number;
            gamesLast30Days: number;
            diamondSpentTotal: number;
            clubMemberships: number;
            accountAgedays: number;
            storiesPosted?: number | undefined;
            messagesLast30Days?: number | undefined;
        };
    }>, z.ZodObject<{
        overallScore: z.ZodNumber;
        dimensions: z.ZodObject<{
            activity: z.ZodNumber;
            social: z.ZodNumber;
            spending: z.ZodNumber;
            loyalty: z.ZodNumber;
        }, "strip", z.ZodTypeAny, {
            social: number;
            activity: number;
            spending: number;
            loyalty: number;
        }, {
            social: number;
            activity: number;
            spending: number;
            loyalty: number;
        }>;
        tier: z.ZodEnum<["casual", "regular", "engaged", "power_user", "whale"]>;
        insights: z.ZodArray<z.ZodString, "many">;
    }, "strip", z.ZodTypeAny, {
        tier: "casual" | "regular" | "engaged" | "power_user" | "whale";
        insights: string[];
        overallScore: number;
        dimensions: {
            social: number;
            activity: number;
            spending: number;
            loyalty: number;
        };
    }, {
        tier: "casual" | "regular" | "engaged" | "power_user" | "whale";
        insights: string[];
        overallScore: number;
        dimensions: {
            social: number;
            activity: number;
            spending: number;
            loyalty: number;
        };
    }>, z.ZodTypeAny>;
};
export default _default;
//# sourceMappingURL=analyticsAgent.d.ts.map