/**
 * Recommendation Agent - Personalized Content & Friend Discovery
 *
 * Features:
 * - Personalized feed ranking
 * - Friend suggestions
 * - Game recommendations with Tree of Thoughts reasoning
 * - Content discovery
 *
 * Enhanced with Tree of Thoughts (ToT) for deliberate problem-solving
 * Powered by Google GenKit + Gemini 2.0 Flash
 */
import { z } from 'genkit';
/**
 * Personalized Feed Ranking
 */
export declare const rankFeedFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    userProfile: z.ZodObject<{
        interests: z.ZodArray<z.ZodString, "many">;
        playedGames: z.ZodArray<z.ZodString, "many">;
        followedUsers: z.ZodArray<z.ZodString, "many">;
        skillLevel: z.ZodOptional<z.ZodEnum<["beginner", "intermediate", "advanced", "expert"]>>;
    }, "strip", z.ZodTypeAny, {
        interests: string[];
        playedGames: string[];
        followedUsers: string[];
        skillLevel?: "expert" | "beginner" | "intermediate" | "advanced" | undefined;
    }, {
        interests: string[];
        playedGames: string[];
        followedUsers: string[];
        skillLevel?: "expert" | "beginner" | "intermediate" | "advanced" | undefined;
    }>;
    contentItems: z.ZodArray<z.ZodObject<{
        id: z.ZodString;
        type: z.ZodEnum<["story", "game_result", "achievement", "social", "reel"]>;
        creatorId: z.ZodString;
        tags: z.ZodArray<z.ZodString, "many">;
        engagementScore: z.ZodNumber;
        createdAt: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        type: "social" | "achievement" | "game_result" | "story" | "reel";
        id: string;
        createdAt: string;
        creatorId: string;
        tags: string[];
        engagementScore: number;
    }, {
        type: "social" | "achievement" | "game_result" | "story" | "reel";
        id: string;
        createdAt: string;
        creatorId: string;
        tags: string[];
        engagementScore: number;
    }>, "many">;
    feedType: z.ZodEnum<["home", "discover", "gaming", "social"]>;
    limit: z.ZodDefault<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    userProfile: {
        interests: string[];
        playedGames: string[];
        followedUsers: string[];
        skillLevel?: "expert" | "beginner" | "intermediate" | "advanced" | undefined;
    };
    contentItems: {
        type: "social" | "achievement" | "game_result" | "story" | "reel";
        id: string;
        createdAt: string;
        creatorId: string;
        tags: string[];
        engagementScore: number;
    }[];
    feedType: "social" | "home" | "discover" | "gaming";
    limit: number;
}, {
    userId: string;
    userProfile: {
        interests: string[];
        playedGames: string[];
        followedUsers: string[];
        skillLevel?: "expert" | "beginner" | "intermediate" | "advanced" | undefined;
    };
    contentItems: {
        type: "social" | "achievement" | "game_result" | "story" | "reel";
        id: string;
        createdAt: string;
        creatorId: string;
        tags: string[];
        engagementScore: number;
    }[];
    feedType: "social" | "home" | "discover" | "gaming";
    limit?: number | undefined;
}>, z.ZodObject<{
    rankedContent: z.ZodArray<z.ZodObject<{
        contentId: z.ZodString;
        score: z.ZodNumber;
        reason: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        reason: string;
        score: number;
        contentId: string;
    }, {
        reason: string;
        score: number;
        contentId: string;
    }>, "many">;
    trendingTopics: z.ZodArray<z.ZodString, "many">;
    suggestedCreators: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    rankedContent: {
        reason: string;
        score: number;
        contentId: string;
    }[];
    trendingTopics: string[];
    suggestedCreators: string[];
}, {
    rankedContent: {
        reason: string;
        score: number;
        contentId: string;
    }[];
    trendingTopics: string[];
    suggestedCreators: string[];
}>, z.ZodTypeAny>;
/**
 * Friend Suggestions
 */
export declare const suggestFriendsFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    userProfile: z.ZodObject<{
        games: z.ZodArray<z.ZodString, "many">;
        skillLevel: z.ZodString;
        location: z.ZodOptional<z.ZodString>;
        activeHours: z.ZodOptional<z.ZodArray<z.ZodNumber, "many">>;
    }, "strip", z.ZodTypeAny, {
        games: string[];
        skillLevel: string;
        location?: string | undefined;
        activeHours?: number[] | undefined;
    }, {
        games: string[];
        skillLevel: string;
        location?: string | undefined;
        activeHours?: number[] | undefined;
    }>;
    potentialFriends: z.ZodArray<z.ZodObject<{
        id: z.ZodString;
        games: z.ZodArray<z.ZodString, "many">;
        skillLevel: z.ZodString;
        mutualFriends: z.ZodNumber;
        lastActive: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        id: string;
        games: string[];
        lastActive: string;
        skillLevel: string;
        mutualFriends: number;
    }, {
        id: string;
        games: string[];
        lastActive: string;
        skillLevel: string;
        mutualFriends: number;
    }>, "many">;
    limit: z.ZodDefault<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    userProfile: {
        games: string[];
        skillLevel: string;
        location?: string | undefined;
        activeHours?: number[] | undefined;
    };
    limit: number;
    potentialFriends: {
        id: string;
        games: string[];
        lastActive: string;
        skillLevel: string;
        mutualFriends: number;
    }[];
}, {
    userId: string;
    userProfile: {
        games: string[];
        skillLevel: string;
        location?: string | undefined;
        activeHours?: number[] | undefined;
    };
    potentialFriends: {
        id: string;
        games: string[];
        lastActive: string;
        skillLevel: string;
        mutualFriends: number;
    }[];
    limit?: number | undefined;
}>, z.ZodObject<{
    suggestions: z.ZodArray<z.ZodObject<{
        userId: z.ZodString;
        compatibilityScore: z.ZodNumber;
        reason: z.ZodString;
        commonInterests: z.ZodArray<z.ZodString, "many">;
    }, "strip", z.ZodTypeAny, {
        reason: string;
        userId: string;
        compatibilityScore: number;
        commonInterests: string[];
    }, {
        reason: string;
        userId: string;
        compatibilityScore: number;
        commonInterests: string[];
    }>, "many">;
}, "strip", z.ZodTypeAny, {
    suggestions: {
        reason: string;
        userId: string;
        compatibilityScore: number;
        commonInterests: string[];
    }[];
}, {
    suggestions: {
        reason: string;
        userId: string;
        compatibilityScore: number;
        commonInterests: string[];
    }[];
}>, z.ZodTypeAny>;
/**
 * Game Recommendations - Enhanced with Tree of Thoughts
 *
 * Uses multi-dimensional reasoning:
 * 1. Competition preference analysis
 * 2. Discovery opportunity (games not tried)
 * 3. Time constraint matching
 * 4. Mood alignment
 */
export declare const recommendGamesFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    playHistory: z.ZodArray<z.ZodObject<{
        game: z.ZodString;
        timesPlayed: z.ZodNumber;
        winRate: z.ZodNumber;
        enjoymentScore: z.ZodOptional<z.ZodNumber>;
    }, "strip", z.ZodTypeAny, {
        game: string;
        timesPlayed: number;
        winRate: number;
        enjoymentScore?: number | undefined;
    }, {
        game: string;
        timesPlayed: number;
        winRate: number;
        enjoymentScore?: number | undefined;
    }>, "many">;
    currentMood: z.ZodOptional<z.ZodEnum<["competitive", "casual", "social", "learning"]>>;
    availableTime: z.ZodOptional<z.ZodEnum<["quick", "medium", "long"]>>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    playHistory: {
        game: string;
        timesPlayed: number;
        winRate: number;
        enjoymentScore?: number | undefined;
    }[];
    currentMood?: "social" | "casual" | "competitive" | "learning" | undefined;
    availableTime?: "medium" | "quick" | "long" | undefined;
}, {
    userId: string;
    playHistory: {
        game: string;
        timesPlayed: number;
        winRate: number;
        enjoymentScore?: number | undefined;
    }[];
    currentMood?: "social" | "casual" | "competitive" | "learning" | undefined;
    availableTime?: "medium" | "quick" | "long" | undefined;
}>, z.ZodObject<{
    recommendations: z.ZodArray<z.ZodObject<{
        game: z.ZodString;
        reason: z.ZodString;
        matchScore: z.ZodNumber;
        suggestedMode: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        reason: string;
        game: string;
        matchScore: number;
        suggestedMode?: string | undefined;
    }, {
        reason: string;
        game: string;
        matchScore: number;
        suggestedMode?: string | undefined;
    }>, "many">;
    tip: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    recommendations: {
        reason: string;
        game: string;
        matchScore: number;
        suggestedMode?: string | undefined;
    }[];
    tip?: string | undefined;
}, {
    recommendations: {
        reason: string;
        game: string;
        matchScore: number;
        suggestedMode?: string | undefined;
    }[];
    tip?: string | undefined;
}>, z.ZodTypeAny>;
export declare const rankFeed: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    rankedContent: {
        reason: string;
        score: number;
        contentId: string;
    }[];
    trendingTopics: string[];
    suggestedCreators: string[];
}>, unknown>;
export declare const suggestFriends: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    suggestions: {
        reason: string;
        userId: string;
        compatibilityScore: number;
        commonInterests: string[];
    }[];
}>, unknown>;
export declare const recommendGames: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    recommendations: {
        reason: string;
        game: string;
        matchScore: number;
        suggestedMode?: string | undefined;
    }[];
    tip?: string | undefined;
}>, unknown>;
//# sourceMappingURL=recommendation_agent.d.ts.map