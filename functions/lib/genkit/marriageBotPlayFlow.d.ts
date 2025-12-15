/**
 * Royal Meld / Marriage Bot Play Flow
 *
 * Dedicated GenKit AI flow for Royal Meld (Marriage) card game with
 * game-specific strategy prompts for different difficulty levels.
 *
 * Supports dual terminology:
 * - Global: Royal Meld, Wild Card, High Wild, Low Wild, Royal Sequence, Go Royale
 * - South Asia: Marriage, Tiplu, Poplu, Jhiplu, Marriage, Declare
 */
import { z } from 'zod';
declare const MarriageBotInputSchema: z.ZodObject<{
    difficulty: z.ZodEnum<["easy", "medium", "hard", "expert"]>;
    hand: z.ZodArray<z.ZodString, "many">;
    region: z.ZodDefault<z.ZodEnum<["global", "southAsia"]>>;
    gameState: z.ZodObject<{
        phase: z.ZodEnum<["drawing", "discarding", "declaring"]>;
        tiplu: z.ZodOptional<z.ZodString>;
        topDiscard: z.ZodOptional<z.ZodString>;
        cardsInDeck: z.ZodNumber;
        roundNumber: z.ZodNumber;
        myMelds: z.ZodOptional<z.ZodArray<z.ZodArray<z.ZodString, "many">, "many">>;
        opponentCardCounts: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
    }, "strip", z.ZodTypeAny, {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    }, {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    }>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    region: "global" | "southAsia";
    gameState: {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    };
}, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    gameState: {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    };
    region?: "global" | "southAsia" | undefined;
}>;
export type MarriageBotInput = z.infer<typeof MarriageBotInputSchema>;
declare const MarriageBotOutputSchema: z.ZodObject<{
    action: z.ZodEnum<["drawDeck", "drawDiscard", "discard", "declare"]>;
    card: z.ZodOptional<z.ZodString>;
    reasoning: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    action: "drawDeck" | "drawDiscard" | "discard" | "declare";
    reasoning?: string | undefined;
    card?: string | undefined;
}, {
    action: "drawDeck" | "drawDiscard" | "discard" | "declare";
    reasoning?: string | undefined;
    card?: string | undefined;
}>;
export type MarriageBotOutput = z.infer<typeof MarriageBotOutputSchema>;
export declare const marriageBotPlayFlow: import("genkit").CallableFlow<z.ZodObject<{
    difficulty: z.ZodEnum<["easy", "medium", "hard", "expert"]>;
    hand: z.ZodArray<z.ZodString, "many">;
    region: z.ZodDefault<z.ZodEnum<["global", "southAsia"]>>;
    gameState: z.ZodObject<{
        phase: z.ZodEnum<["drawing", "discarding", "declaring"]>;
        tiplu: z.ZodOptional<z.ZodString>;
        topDiscard: z.ZodOptional<z.ZodString>;
        cardsInDeck: z.ZodNumber;
        roundNumber: z.ZodNumber;
        myMelds: z.ZodOptional<z.ZodArray<z.ZodArray<z.ZodString, "many">, "many">>;
        opponentCardCounts: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
    }, "strip", z.ZodTypeAny, {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    }, {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    }>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    region: "global" | "southAsia";
    gameState: {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    };
}, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    gameState: {
        phase: "drawing" | "discarding" | "declaring";
        cardsInDeck: number;
        roundNumber: number;
        tiplu?: string | undefined;
        topDiscard?: string | undefined;
        myMelds?: string[][] | undefined;
        opponentCardCounts?: Record<string, number> | undefined;
    };
    region?: "global" | "southAsia" | undefined;
}>, z.ZodObject<{
    action: z.ZodEnum<["drawDeck", "drawDiscard", "discard", "declare"]>;
    card: z.ZodOptional<z.ZodString>;
    reasoning: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    action: "drawDeck" | "drawDiscard" | "discard" | "declare";
    reasoning?: string | undefined;
    card?: string | undefined;
}, {
    action: "drawDeck" | "drawDiscard" | "discard" | "declare";
    reasoning?: string | undefined;
    card?: string | undefined;
}>, z.ZodTypeAny>;
export {};
//# sourceMappingURL=marriageBotPlayFlow.d.ts.map