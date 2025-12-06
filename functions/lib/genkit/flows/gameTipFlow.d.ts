/**
 * Game Tip Flow - AI-powered card suggestions for Call Break
 *
 * Analyzes the current game state and suggests the best card to play.
 */
import { z } from 'zod';
declare const GameTipInputSchema: z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    trickCards: z.ZodArray<z.ZodString, "many">;
    tricksNeeded: z.ZodNumber;
    tricksWon: z.ZodNumber;
    bid: z.ZodNumber;
    trumpSuit: z.ZodDefault<z.ZodString>;
    ledSuit: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    trickCards: string[];
    tricksNeeded: number;
    tricksWon: number;
    bid: number;
    trumpSuit: string;
    ledSuit?: string | undefined;
}, {
    hand: string[];
    trickCards: string[];
    tricksNeeded: number;
    tricksWon: number;
    bid: number;
    trumpSuit?: string | undefined;
    ledSuit?: string | undefined;
}>;
declare const GameTipOutputSchema: z.ZodObject<{
    suggestedCard: z.ZodString;
    reasoning: z.ZodString;
    confidence: z.ZodEnum<["high", "medium", "low"]>;
    alternativeCard: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    suggestedCard: string;
    reasoning: string;
    confidence: "high" | "medium" | "low";
    alternativeCard?: string | undefined;
}, {
    suggestedCard: string;
    reasoning: string;
    confidence: "high" | "medium" | "low";
    alternativeCard?: string | undefined;
}>;
export declare const gameTipFlow: import("genkit").CallableFlow<z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    trickCards: z.ZodArray<z.ZodString, "many">;
    tricksNeeded: z.ZodNumber;
    tricksWon: z.ZodNumber;
    bid: z.ZodNumber;
    trumpSuit: z.ZodDefault<z.ZodString>;
    ledSuit: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    trickCards: string[];
    tricksNeeded: number;
    tricksWon: number;
    bid: number;
    trumpSuit: string;
    ledSuit?: string | undefined;
}, {
    hand: string[];
    trickCards: string[];
    tricksNeeded: number;
    tricksWon: number;
    bid: number;
    trumpSuit?: string | undefined;
    ledSuit?: string | undefined;
}>, z.ZodObject<{
    suggestedCard: z.ZodString;
    reasoning: z.ZodString;
    confidence: z.ZodEnum<["high", "medium", "low"]>;
    alternativeCard: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    suggestedCard: string;
    reasoning: string;
    confidence: "high" | "medium" | "low";
    alternativeCard?: string | undefined;
}, {
    suggestedCard: string;
    reasoning: string;
    confidence: "high" | "medium" | "low";
    alternativeCard?: string | undefined;
}>, z.ZodTypeAny>;
export type GameTipInput = z.infer<typeof GameTipInputSchema>;
export type GameTipOutput = z.infer<typeof GameTipOutputSchema>;
export {};
//# sourceMappingURL=gameTipFlow.d.ts.map