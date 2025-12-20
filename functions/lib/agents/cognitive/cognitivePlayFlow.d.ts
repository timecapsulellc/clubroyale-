/**
 * Cognitive AI Agent - Enhanced Bot Decision Flow
 *
 * Implements Tree-of-Thoughts reasoning for human-like gameplay.
 * Supports multiple AI personalities with different play styles.
 */
import { z } from 'zod';
export declare const AI_PERSONALITIES: {
    trickmaster: {
        id: string;
        name: string;
        avatar: string;
        difficulty: "hard";
        style: "aggressive";
        traits: string[];
        prompt: string;
    };
    cardshark: {
        id: string;
        name: string;
        avatar: string;
        difficulty: "medium";
        style: "conservative";
        traits: string[];
        prompt: string;
    };
    luckydice: {
        id: string;
        name: string;
        avatar: string;
        difficulty: "easy";
        style: "chaotic";
        traits: string[];
        prompt: string;
    };
    deepthink: {
        id: string;
        name: string;
        avatar: string;
        difficulty: "expert";
        style: "analytical";
        traits: string[];
        prompt: string;
    };
    royalace: {
        id: string;
        name: string;
        avatar: string;
        difficulty: "medium";
        style: "balanced";
        traits: string[];
        prompt: string;
    };
};
declare const CognitivePlayInputSchema: z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    gameState: z.ZodObject<{
        discardPile: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
        opponentCardCounts: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
        currentPhase: z.ZodOptional<z.ZodString>;
        tiplu: z.ZodOptional<z.ZodString>;
        hasVisited: z.ZodOptional<z.ZodBoolean>;
        maalPoints: z.ZodOptional<z.ZodNumber>;
        tricksWon: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
        bids: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
        currentTrick: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    }, "strip", z.ZodTypeAny, {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    }, {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    }>;
    personality: z.ZodEnum<["trickmaster", "cardshark", "luckydice", "deepthink", "royalace"]>;
    gameType: z.ZodEnum<["marriage", "call_break", "teen_patti", "in_between"]>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    gameType: "marriage" | "call_break" | "teen_patti" | "in_between";
    gameState: {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    };
    personality: "trickmaster" | "cardshark" | "luckydice" | "deepthink" | "royalace";
}, {
    hand: string[];
    gameType: "marriage" | "call_break" | "teen_patti" | "in_between";
    gameState: {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    };
    personality: "trickmaster" | "cardshark" | "luckydice" | "deepthink" | "royalace";
}>;
declare const CognitivePlayOutputSchema: z.ZodObject<{
    action: z.ZodEnum<["draw_deck", "draw_discard", "discard", "visit", "declare", "bid", "play"]>;
    card: z.ZodOptional<z.ZodString>;
    bidAmount: z.ZodOptional<z.ZodNumber>;
    internalThought: z.ZodString;
    confidenceScore: z.ZodNumber;
    thinkingTimeMs: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    action: "bid" | "discard" | "declare" | "draw_deck" | "draw_discard" | "visit" | "play";
    internalThought: string;
    confidenceScore: number;
    thinkingTimeMs: number;
    card?: string | undefined;
    bidAmount?: number | undefined;
}, {
    action: "bid" | "discard" | "declare" | "draw_deck" | "draw_discard" | "visit" | "play";
    internalThought: string;
    confidenceScore: number;
    thinkingTimeMs: number;
    card?: string | undefined;
    bidAmount?: number | undefined;
}>;
/**
 * Cognitive Play Flow - Tree of Thoughts Decision Making
 */
export declare const cognitivePlayFlow: import("genkit").CallableFlow<z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    gameState: z.ZodObject<{
        discardPile: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
        opponentCardCounts: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
        currentPhase: z.ZodOptional<z.ZodString>;
        tiplu: z.ZodOptional<z.ZodString>;
        hasVisited: z.ZodOptional<z.ZodBoolean>;
        maalPoints: z.ZodOptional<z.ZodNumber>;
        tricksWon: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
        bids: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
        currentTrick: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
    }, "strip", z.ZodTypeAny, {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    }, {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    }>;
    personality: z.ZodEnum<["trickmaster", "cardshark", "luckydice", "deepthink", "royalace"]>;
    gameType: z.ZodEnum<["marriage", "call_break", "teen_patti", "in_between"]>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    gameType: "marriage" | "call_break" | "teen_patti" | "in_between";
    gameState: {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    };
    personality: "trickmaster" | "cardshark" | "luckydice" | "deepthink" | "royalace";
}, {
    hand: string[];
    gameType: "marriage" | "call_break" | "teen_patti" | "in_between";
    gameState: {
        tricksWon?: Record<string, number> | undefined;
        tiplu?: string | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
        currentTrick?: string[] | undefined;
        bids?: Record<string, number> | undefined;
        discardPile?: string[] | undefined;
        currentPhase?: string | undefined;
        hasVisited?: boolean | undefined;
        maalPoints?: number | undefined;
    };
    personality: "trickmaster" | "cardshark" | "luckydice" | "deepthink" | "royalace";
}>, z.ZodObject<{
    action: z.ZodEnum<["draw_deck", "draw_discard", "discard", "visit", "declare", "bid", "play"]>;
    card: z.ZodOptional<z.ZodString>;
    bidAmount: z.ZodOptional<z.ZodNumber>;
    internalThought: z.ZodString;
    confidenceScore: z.ZodNumber;
    thinkingTimeMs: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    action: "bid" | "discard" | "declare" | "draw_deck" | "draw_discard" | "visit" | "play";
    internalThought: string;
    confidenceScore: number;
    thinkingTimeMs: number;
    card?: string | undefined;
    bidAmount?: number | undefined;
}, {
    action: "bid" | "discard" | "declare" | "draw_deck" | "draw_discard" | "visit" | "play";
    internalThought: string;
    confidenceScore: number;
    thinkingTimeMs: number;
    card?: string | undefined;
    bidAmount?: number | undefined;
}>, z.ZodTypeAny>;
/**
 * Get AI personality by ID
 */
export declare function getPersonalityById(botId: string): {
    id: string;
    name: string;
    avatar: string;
    difficulty: "hard";
    style: "aggressive";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "medium";
    style: "conservative";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "easy";
    style: "chaotic";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "expert";
    style: "analytical";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "medium";
    style: "balanced";
    traits: string[];
    prompt: string;
} | undefined;
/**
 * Get random personality
 */
export declare function getRandomPersonality(): {
    id: string;
    name: string;
    avatar: string;
    difficulty: "hard";
    style: "aggressive";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "medium";
    style: "conservative";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "easy";
    style: "chaotic";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "expert";
    style: "analytical";
    traits: string[];
    prompt: string;
} | {
    id: string;
    name: string;
    avatar: string;
    difficulty: "medium";
    style: "balanced";
    traits: string[];
    prompt: string;
};
export type CognitivePlayInput = z.infer<typeof CognitivePlayInputSchema>;
export type CognitivePlayOutput = z.infer<typeof CognitivePlayOutputSchema>;
export {};
//# sourceMappingURL=cognitivePlayFlow.d.ts.map