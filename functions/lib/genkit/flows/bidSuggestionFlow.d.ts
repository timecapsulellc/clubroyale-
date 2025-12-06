/**
 * Bid Suggestion Flow - AI recommends optimal bid based on hand strength
 *
 * Analyzes cards dealt and suggests how many tricks the player can win.
 */
import { z } from 'zod';
declare const BidSuggestionInputSchema: z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    position: z.ZodNumber;
    previousBids: z.ZodOptional<z.ZodArray<z.ZodNumber, "many">>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    position: number;
    previousBids?: number[] | undefined;
}, {
    hand: string[];
    position: number;
    previousBids?: number[] | undefined;
}>;
declare const BidSuggestionOutputSchema: z.ZodObject<{
    suggestedBid: z.ZodNumber;
    confidence: z.ZodEnum<["high", "medium", "low"]>;
    reasoning: z.ZodString;
    handStrength: z.ZodEnum<["weak", "average", "strong", "very_strong"]>;
    riskLevel: z.ZodEnum<["safe", "moderate", "aggressive"]>;
}, "strip", z.ZodTypeAny, {
    reasoning: string;
    confidence: "high" | "medium" | "low";
    suggestedBid: number;
    handStrength: "weak" | "average" | "strong" | "very_strong";
    riskLevel: "safe" | "moderate" | "aggressive";
}, {
    reasoning: string;
    confidence: "high" | "medium" | "low";
    suggestedBid: number;
    handStrength: "weak" | "average" | "strong" | "very_strong";
    riskLevel: "safe" | "moderate" | "aggressive";
}>;
export declare const bidSuggestionFlow: import("genkit").CallableFlow<z.ZodObject<{
    hand: z.ZodArray<z.ZodString, "many">;
    position: z.ZodNumber;
    previousBids: z.ZodOptional<z.ZodArray<z.ZodNumber, "many">>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    position: number;
    previousBids?: number[] | undefined;
}, {
    hand: string[];
    position: number;
    previousBids?: number[] | undefined;
}>, z.ZodObject<{
    suggestedBid: z.ZodNumber;
    confidence: z.ZodEnum<["high", "medium", "low"]>;
    reasoning: z.ZodString;
    handStrength: z.ZodEnum<["weak", "average", "strong", "very_strong"]>;
    riskLevel: z.ZodEnum<["safe", "moderate", "aggressive"]>;
}, "strip", z.ZodTypeAny, {
    reasoning: string;
    confidence: "high" | "medium" | "low";
    suggestedBid: number;
    handStrength: "weak" | "average" | "strong" | "very_strong";
    riskLevel: "safe" | "moderate" | "aggressive";
}, {
    reasoning: string;
    confidence: "high" | "medium" | "low";
    suggestedBid: number;
    handStrength: "weak" | "average" | "strong" | "very_strong";
    riskLevel: "safe" | "moderate" | "aggressive";
}>, z.ZodTypeAny>;
export type BidSuggestionInput = z.infer<typeof BidSuggestionInputSchema>;
export type BidSuggestionOutput = z.infer<typeof BidSuggestionOutputSchema>;
export {};
//# sourceMappingURL=bidSuggestionFlow.d.ts.map