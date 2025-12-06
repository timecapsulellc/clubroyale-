/**
 * Bot Player Flow - AI that plays as a bot in Call Break
 *
 * Used when a player disconnects or for practice mode.
 */
import { z } from 'zod';
declare const BotPlayInputSchema: z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    trickCards: z.ZodArray<z.ZodObject<{
        card: z.ZodString;
        playerId: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        card: string;
        playerId: string;
    }, {
        card: string;
        playerId: string;
    }>, "many">;
    currentRound: z.ZodNumber;
    bid: z.ZodNumber;
    tricksWon: z.ZodNumber;
    allBids: z.ZodRecord<z.ZodString, z.ZodNumber>;
    allTricksWon: z.ZodRecord<z.ZodString, z.ZodNumber>;
    difficulty: z.ZodDefault<z.ZodEnum<["easy", "medium", "hard"]>>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    trickCards: {
        card: string;
        playerId: string;
    }[];
    tricksWon: number;
    bid: number;
    currentRound: number;
    allBids: Record<string, number>;
    allTricksWon: Record<string, number>;
    difficulty: "medium" | "easy" | "hard";
}, {
    hand: string[];
    trickCards: {
        card: string;
        playerId: string;
    }[];
    tricksWon: number;
    bid: number;
    currentRound: number;
    allBids: Record<string, number>;
    allTricksWon: Record<string, number>;
    difficulty?: "medium" | "easy" | "hard" | undefined;
}>;
declare const BotPlayOutputSchema: z.ZodObject<{
    selectedCard: z.ZodString;
    strategy: z.ZodString;
}, "strip", z.ZodTypeAny, {
    selectedCard: string;
    strategy: string;
}, {
    selectedCard: string;
    strategy: string;
}>;
export declare const botPlayFlow: import("genkit").CallableFlow<z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    trickCards: z.ZodArray<z.ZodObject<{
        card: z.ZodString;
        playerId: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        card: string;
        playerId: string;
    }, {
        card: string;
        playerId: string;
    }>, "many">;
    currentRound: z.ZodNumber;
    bid: z.ZodNumber;
    tricksWon: z.ZodNumber;
    allBids: z.ZodRecord<z.ZodString, z.ZodNumber>;
    allTricksWon: z.ZodRecord<z.ZodString, z.ZodNumber>;
    difficulty: z.ZodDefault<z.ZodEnum<["easy", "medium", "hard"]>>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    trickCards: {
        card: string;
        playerId: string;
    }[];
    tricksWon: number;
    bid: number;
    currentRound: number;
    allBids: Record<string, number>;
    allTricksWon: Record<string, number>;
    difficulty: "medium" | "easy" | "hard";
}, {
    hand: string[];
    trickCards: {
        card: string;
        playerId: string;
    }[];
    tricksWon: number;
    bid: number;
    currentRound: number;
    allBids: Record<string, number>;
    allTricksWon: Record<string, number>;
    difficulty?: "medium" | "easy" | "hard" | undefined;
}>, z.ZodObject<{
    selectedCard: z.ZodString;
    strategy: z.ZodString;
}, "strip", z.ZodTypeAny, {
    selectedCard: string;
    strategy: string;
}, {
    selectedCard: string;
    strategy: string;
}>, z.ZodTypeAny>;
export type BotPlayInput = z.infer<typeof BotPlayInputSchema>;
export type BotPlayOutput = z.infer<typeof BotPlayOutputSchema>;
export {};
//# sourceMappingURL=botPlayFlow.d.ts.map