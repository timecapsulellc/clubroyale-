/**
 * Streaming Agent - Live Content Management
 *
 * Features:
 * - Stream enhancement suggestions
 * - Auto-highlight detection
 * - Live chat moderation
 * - Viewer engagement tracking
 */
import { z } from 'genkit';
export declare const enhanceStreamFlow: import("genkit").CallableFlow<z.ZodObject<{
    streamId: z.ZodString;
    streamType: z.ZodEnum<["game", "chat", "tutorial", "social"]>;
    gameType: z.ZodOptional<z.ZodString>;
    viewerCount: z.ZodNumber;
    streamDuration: z.ZodNumber;
    recentEvents: z.ZodOptional<z.ZodArray<z.ZodObject<{
        type: z.ZodString;
        timestamp: z.ZodNumber;
        data: z.ZodAny;
    }, "strip", z.ZodTypeAny, {
        type: string;
        timestamp: number;
        data?: any;
    }, {
        type: string;
        timestamp: number;
        data?: any;
    }>, "many">>;
}, "strip", z.ZodTypeAny, {
    streamId: string;
    streamType: "social" | "tutorial" | "game" | "chat";
    viewerCount: number;
    streamDuration: number;
    gameType?: string | undefined;
    recentEvents?: {
        type: string;
        timestamp: number;
        data?: any;
    }[] | undefined;
}, {
    streamId: string;
    streamType: "social" | "tutorial" | "game" | "chat";
    viewerCount: number;
    streamDuration: number;
    gameType?: string | undefined;
    recentEvents?: {
        type: string;
        timestamp: number;
        data?: any;
    }[] | undefined;
}>, z.ZodObject<{
    overlays: z.ZodArray<z.ZodObject<{
        type: z.ZodString;
        content: z.ZodString;
        position: z.ZodString;
        duration: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        type: string;
        content: string;
        position: string;
        duration: number;
    }, {
        type: string;
        content: string;
        position: string;
        duration: number;
    }>, "many">;
    interactionPrompts: z.ZodArray<z.ZodString, "many">;
    suggestedPolls: z.ZodArray<z.ZodObject<{
        question: z.ZodString;
        options: z.ZodArray<z.ZodString, "many">;
    }, "strip", z.ZodTypeAny, {
        options: string[];
        question: string;
    }, {
        options: string[];
        question: string;
    }>, "many">;
    engagementTips: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    overlays: {
        type: string;
        content: string;
        position: string;
        duration: number;
    }[];
    interactionPrompts: string[];
    suggestedPolls: {
        options: string[];
        question: string;
    }[];
    engagementTips: string[];
}, {
    overlays: {
        type: string;
        content: string;
        position: string;
        duration: number;
    }[];
    interactionPrompts: string[];
    suggestedPolls: {
        options: string[];
        question: string;
    }[];
    engagementTips: string[];
}>, z.ZodTypeAny>;
export declare const detectHighlightsFlow: import("genkit").CallableFlow<z.ZodObject<{
    streamId: z.ZodString;
    gameEvents: z.ZodArray<z.ZodObject<{
        timestamp: z.ZodNumber;
        event: z.ZodString;
        significance: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        timestamp: number;
        event: string;
        significance: number;
    }, {
        timestamp: number;
        event: string;
        significance: number;
    }>, "many">;
    viewerReactions: z.ZodOptional<z.ZodArray<z.ZodObject<{
        timestamp: z.ZodNumber;
        type: z.ZodString;
        count: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        type: string;
        timestamp: number;
        count: number;
    }, {
        type: string;
        timestamp: number;
        count: number;
    }>, "many">>;
}, "strip", z.ZodTypeAny, {
    gameEvents: {
        timestamp: number;
        event: string;
        significance: number;
    }[];
    streamId: string;
    viewerReactions?: {
        type: string;
        timestamp: number;
        count: number;
    }[] | undefined;
}, {
    gameEvents: {
        timestamp: number;
        event: string;
        significance: number;
    }[];
    streamId: string;
    viewerReactions?: {
        type: string;
        timestamp: number;
        count: number;
    }[] | undefined;
}>, z.ZodObject<{
    highlights: z.ZodArray<z.ZodObject<{
        startTime: z.ZodNumber;
        endTime: z.ZodNumber;
        title: z.ZodString;
        score: z.ZodNumber;
        category: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        category: string;
        score: number;
        title: string;
        startTime: number;
        endTime: number;
    }, {
        category: string;
        score: number;
        title: string;
        startTime: number;
        endTime: number;
    }>, "many">;
    bestMoment: z.ZodOptional<z.ZodObject<{
        timestamp: z.ZodNumber;
        description: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        timestamp: number;
        description: string;
    }, {
        timestamp: number;
        description: string;
    }>>;
}, "strip", z.ZodTypeAny, {
    highlights: {
        category: string;
        score: number;
        title: string;
        startTime: number;
        endTime: number;
    }[];
    bestMoment?: {
        timestamp: number;
        description: string;
    } | undefined;
}, {
    highlights: {
        category: string;
        score: number;
        title: string;
        startTime: number;
        endTime: number;
    }[];
    bestMoment?: {
        timestamp: number;
        description: string;
    } | undefined;
}>, z.ZodTypeAny>;
export declare const enhanceStream: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    overlays: {
        type: string;
        content: string;
        position: string;
        duration: number;
    }[];
    interactionPrompts: string[];
    suggestedPolls: {
        options: string[];
        question: string;
    }[];
    engagementTips: string[];
}>, unknown>;
export declare const detectHighlights: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    highlights: {
        category: string;
        score: number;
        title: string;
        startTime: number;
        endTime: number;
    }[];
    bestMoment?: {
        timestamp: number;
        description: string;
    } | undefined;
}>, unknown>;
//# sourceMappingURL=streaming_agent.d.ts.map