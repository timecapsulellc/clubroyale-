/**
 * Recommendation Agent
 * 4D Personalization: Time, Mood, Social, Skill
 */
import { z } from 'genkit';
/**
 * Recommend games based on 4D analysis
 */
export declare const recommendGamesFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    context: z.ZodRecord<z.ZodString, z.ZodUnknown>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    context: Record<string, unknown>;
}, {
    userId: string;
    context: Record<string, unknown>;
}>, z.ZodObject<{
    recommendations: z.ZodArray<z.ZodObject<{
        gameType: z.ZodString;
        score: z.ZodNumber;
        reasoning: z.ZodString;
        suggestedMode: z.ZodString;
        estimatedDuration: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        reasoning: string;
        gameType: string;
        score: number;
        suggestedMode: string;
        estimatedDuration: number;
    }, {
        reasoning: string;
        gameType: string;
        score: number;
        suggestedMode: string;
        estimatedDuration: number;
    }>, "many">;
    analysis: z.ZodObject<{
        time: z.ZodRecord<z.ZodString, z.ZodUnknown>;
        social: z.ZodRecord<z.ZodString, z.ZodUnknown>;
        skill: z.ZodRecord<z.ZodString, z.ZodUnknown>;
    }, "strip", z.ZodTypeAny, {
        social: Record<string, unknown>;
        time: Record<string, unknown>;
        skill: Record<string, unknown>;
    }, {
        social: Record<string, unknown>;
        time: Record<string, unknown>;
        skill: Record<string, unknown>;
    }>;
}, "strip", z.ZodTypeAny, {
    recommendations: {
        reasoning: string;
        gameType: string;
        score: number;
        suggestedMode: string;
        estimatedDuration: number;
    }[];
    analysis: {
        social: Record<string, unknown>;
        time: Record<string, unknown>;
        skill: Record<string, unknown>;
    };
}, {
    recommendations: {
        reasoning: string;
        gameType: string;
        score: number;
        suggestedMode: string;
        estimatedDuration: number;
    }[];
    analysis: {
        social: Record<string, unknown>;
        time: Record<string, unknown>;
        skill: Record<string, unknown>;
    };
}>, z.ZodTypeAny>;
/**
 * Recommend friends to play with
 */
export declare const recommendFriendsFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    friendsData: z.ZodArray<z.ZodObject<{
        id: z.ZodString;
        displayName: z.ZodString;
        isOnline: z.ZodBoolean;
        lastPlayed: z.ZodOptional<z.ZodString>;
        sharedGames: z.ZodArray<z.ZodString, "many">;
        skillMatch: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        id: string;
        isOnline: boolean;
        displayName: string;
        sharedGames: string[];
        skillMatch: number;
        lastPlayed?: string | undefined;
    }, {
        id: string;
        isOnline: boolean;
        displayName: string;
        sharedGames: string[];
        skillMatch: number;
        lastPlayed?: string | undefined;
    }>, "many">;
    currentGame: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    friendsData: {
        id: string;
        isOnline: boolean;
        displayName: string;
        sharedGames: string[];
        skillMatch: number;
        lastPlayed?: string | undefined;
    }[];
    currentGame?: string | undefined;
}, {
    userId: string;
    friendsData: {
        id: string;
        isOnline: boolean;
        displayName: string;
        sharedGames: string[];
        skillMatch: number;
        lastPlayed?: string | undefined;
    }[];
    currentGame?: string | undefined;
}>, z.ZodObject<{
    recommendations: z.ZodArray<z.ZodObject<{
        userId: z.ZodString;
        displayName: z.ZodString;
        score: z.ZodNumber;
        reasoning: z.ZodString;
        sharedInterests: z.ZodArray<z.ZodString, "many">;
        suggestedActivity: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        reasoning: string;
        userId: string;
        score: number;
        displayName: string;
        sharedInterests: string[];
        suggestedActivity: string;
    }, {
        reasoning: string;
        userId: string;
        score: number;
        displayName: string;
        sharedInterests: string[];
        suggestedActivity: string;
    }>, "many">;
}, "strip", z.ZodTypeAny, {
    recommendations: {
        reasoning: string;
        userId: string;
        score: number;
        displayName: string;
        sharedInterests: string[];
        suggestedActivity: string;
    }[];
}, {
    recommendations: {
        reasoning: string;
        userId: string;
        score: number;
        displayName: string;
        sharedInterests: string[];
        suggestedActivity: string;
    }[];
}>, z.ZodTypeAny>;
declare const _default: {
    recommendGamesFlow: import("genkit").CallableFlow<z.ZodObject<{
        userId: z.ZodString;
        context: z.ZodRecord<z.ZodString, z.ZodUnknown>;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        context: Record<string, unknown>;
    }, {
        userId: string;
        context: Record<string, unknown>;
    }>, z.ZodObject<{
        recommendations: z.ZodArray<z.ZodObject<{
            gameType: z.ZodString;
            score: z.ZodNumber;
            reasoning: z.ZodString;
            suggestedMode: z.ZodString;
            estimatedDuration: z.ZodNumber;
        }, "strip", z.ZodTypeAny, {
            reasoning: string;
            gameType: string;
            score: number;
            suggestedMode: string;
            estimatedDuration: number;
        }, {
            reasoning: string;
            gameType: string;
            score: number;
            suggestedMode: string;
            estimatedDuration: number;
        }>, "many">;
        analysis: z.ZodObject<{
            time: z.ZodRecord<z.ZodString, z.ZodUnknown>;
            social: z.ZodRecord<z.ZodString, z.ZodUnknown>;
            skill: z.ZodRecord<z.ZodString, z.ZodUnknown>;
        }, "strip", z.ZodTypeAny, {
            social: Record<string, unknown>;
            time: Record<string, unknown>;
            skill: Record<string, unknown>;
        }, {
            social: Record<string, unknown>;
            time: Record<string, unknown>;
            skill: Record<string, unknown>;
        }>;
    }, "strip", z.ZodTypeAny, {
        recommendations: {
            reasoning: string;
            gameType: string;
            score: number;
            suggestedMode: string;
            estimatedDuration: number;
        }[];
        analysis: {
            social: Record<string, unknown>;
            time: Record<string, unknown>;
            skill: Record<string, unknown>;
        };
    }, {
        recommendations: {
            reasoning: string;
            gameType: string;
            score: number;
            suggestedMode: string;
            estimatedDuration: number;
        }[];
        analysis: {
            social: Record<string, unknown>;
            time: Record<string, unknown>;
            skill: Record<string, unknown>;
        };
    }>, z.ZodTypeAny>;
    recommendFriendsFlow: import("genkit").CallableFlow<z.ZodObject<{
        userId: z.ZodString;
        friendsData: z.ZodArray<z.ZodObject<{
            id: z.ZodString;
            displayName: z.ZodString;
            isOnline: z.ZodBoolean;
            lastPlayed: z.ZodOptional<z.ZodString>;
            sharedGames: z.ZodArray<z.ZodString, "many">;
            skillMatch: z.ZodNumber;
        }, "strip", z.ZodTypeAny, {
            id: string;
            isOnline: boolean;
            displayName: string;
            sharedGames: string[];
            skillMatch: number;
            lastPlayed?: string | undefined;
        }, {
            id: string;
            isOnline: boolean;
            displayName: string;
            sharedGames: string[];
            skillMatch: number;
            lastPlayed?: string | undefined;
        }>, "many">;
        currentGame: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        friendsData: {
            id: string;
            isOnline: boolean;
            displayName: string;
            sharedGames: string[];
            skillMatch: number;
            lastPlayed?: string | undefined;
        }[];
        currentGame?: string | undefined;
    }, {
        userId: string;
        friendsData: {
            id: string;
            isOnline: boolean;
            displayName: string;
            sharedGames: string[];
            skillMatch: number;
            lastPlayed?: string | undefined;
        }[];
        currentGame?: string | undefined;
    }>, z.ZodObject<{
        recommendations: z.ZodArray<z.ZodObject<{
            userId: z.ZodString;
            displayName: z.ZodString;
            score: z.ZodNumber;
            reasoning: z.ZodString;
            sharedInterests: z.ZodArray<z.ZodString, "many">;
            suggestedActivity: z.ZodString;
        }, "strip", z.ZodTypeAny, {
            reasoning: string;
            userId: string;
            score: number;
            displayName: string;
            sharedInterests: string[];
            suggestedActivity: string;
        }, {
            reasoning: string;
            userId: string;
            score: number;
            displayName: string;
            sharedInterests: string[];
            suggestedActivity: string;
        }>, "many">;
    }, "strip", z.ZodTypeAny, {
        recommendations: {
            reasoning: string;
            userId: string;
            score: number;
            displayName: string;
            sharedInterests: string[];
            suggestedActivity: string;
        }[];
    }, {
        recommendations: {
            reasoning: string;
            userId: string;
            score: number;
            displayName: string;
            sharedInterests: string[];
            suggestedActivity: string;
        }[];
    }>, z.ZodTypeAny>;
};
export default _default;
//# sourceMappingURL=recommendationAgent.d.ts.map