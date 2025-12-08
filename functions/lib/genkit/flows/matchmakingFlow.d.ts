/**
 * GenKit Matchmaking Flow
 *
 * AI-powered matchmaking suggestions based on play patterns.
 */
import { z } from 'zod';
declare const matchmakingInputSchema: z.ZodObject<{
    userId: z.ZodString;
    gameType: z.ZodString;
    elo: z.ZodNumber;
    preferredTime: z.ZodOptional<z.ZodString>;
    recentOpponents: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    gameType: string;
    elo: number;
    preferredTime?: string | undefined;
    recentOpponents?: string[] | undefined;
}, {
    userId: string;
    gameType: string;
    elo: number;
    preferredTime?: string | undefined;
    recentOpponents?: string[] | undefined;
}>;
declare const matchmakingOutputSchema: z.ZodObject<{
    suggestions: z.ZodArray<z.ZodString, "many">;
    reasoning: z.ZodString;
    waitTimeEstimate: z.ZodNumber;
    alternativeGameType: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    reasoning: string;
    suggestions: string[];
    waitTimeEstimate: number;
    alternativeGameType?: string | undefined;
}, {
    reasoning: string;
    suggestions: string[];
    waitTimeEstimate: number;
    alternativeGameType?: string | undefined;
}>;
/**
 * AI-powered matchmaking flow
 */
export declare const matchmakingFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    gameType: z.ZodString;
    elo: z.ZodNumber;
    preferredTime: z.ZodOptional<z.ZodString>;
    recentOpponents: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    gameType: string;
    elo: number;
    preferredTime?: string | undefined;
    recentOpponents?: string[] | undefined;
}, {
    userId: string;
    gameType: string;
    elo: number;
    preferredTime?: string | undefined;
    recentOpponents?: string[] | undefined;
}>, z.ZodObject<{
    suggestions: z.ZodArray<z.ZodString, "many">;
    reasoning: z.ZodString;
    waitTimeEstimate: z.ZodNumber;
    alternativeGameType: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    reasoning: string;
    suggestions: string[];
    waitTimeEstimate: number;
    alternativeGameType?: string | undefined;
}, {
    reasoning: string;
    suggestions: string[];
    waitTimeEstimate: number;
    alternativeGameType?: string | undefined;
}>, z.ZodTypeAny>;
export type MatchmakingInput = z.infer<typeof matchmakingInputSchema>;
export type MatchmakingOutput = z.infer<typeof matchmakingOutputSchema>;
export {};
//# sourceMappingURL=matchmakingFlow.d.ts.map