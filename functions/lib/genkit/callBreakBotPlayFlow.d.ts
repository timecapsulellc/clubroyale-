/**
 * Call Break Bot Play Flow
 *
 * Dedicated GenKit AI flow for Call Break card game with
 * trick-taking strategy prompts for different difficulty levels.
 */
import { z } from 'zod';
declare const CallBreakBotInputSchema: z.ZodObject<{
    difficulty: z.ZodEnum<["easy", "medium", "hard", "expert"]>;
    hand: z.ZodArray<z.ZodString, "many">;
    gameState: z.ZodObject<{
        phase: z.ZodEnum<["bidding", "playing"]>;
        trumpSuit: z.ZodDefault<z.ZodString>;
        currentTrick: z.ZodArray<z.ZodObject<{
            playerId: z.ZodString;
            card: z.ZodString;
        }, "strip", z.ZodTypeAny, {
            card: string;
            playerId: string;
        }, {
            card: string;
            playerId: string;
        }>, "many">;
        myBid: z.ZodOptional<z.ZodNumber>;
        tricksWon: z.ZodNumber;
        tricksNeeded: z.ZodNumber;
        roundNumber: z.ZodNumber;
        leadSuit: z.ZodOptional<z.ZodString>;
        bids: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
    }, "strip", z.ZodTypeAny, {
        tricksNeeded: number;
        tricksWon: number;
        trumpSuit: string;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    }, {
        tricksNeeded: number;
        tricksWon: number;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        trumpSuit?: string | undefined;
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    }>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    gameState: {
        tricksNeeded: number;
        tricksWon: number;
        trumpSuit: string;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    };
}, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    gameState: {
        tricksNeeded: number;
        tricksWon: number;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        trumpSuit?: string | undefined;
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    };
}>;
export type CallBreakBotInput = z.infer<typeof CallBreakBotInputSchema>;
declare const CallBreakBotOutputSchema: z.ZodObject<{
    action: z.ZodEnum<["bid", "playCard"]>;
    value: z.ZodUnion<[z.ZodNumber, z.ZodString]>;
    reasoning: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    value: string | number;
    action: "bid" | "playCard";
    reasoning?: string | undefined;
}, {
    value: string | number;
    action: "bid" | "playCard";
    reasoning?: string | undefined;
}>;
export type CallBreakBotOutput = z.infer<typeof CallBreakBotOutputSchema>;
export declare const callBreakBotPlayFlow: import("genkit").CallableFlow<z.ZodObject<{
    difficulty: z.ZodEnum<["easy", "medium", "hard", "expert"]>;
    hand: z.ZodArray<z.ZodString, "many">;
    gameState: z.ZodObject<{
        phase: z.ZodEnum<["bidding", "playing"]>;
        trumpSuit: z.ZodDefault<z.ZodString>;
        currentTrick: z.ZodArray<z.ZodObject<{
            playerId: z.ZodString;
            card: z.ZodString;
        }, "strip", z.ZodTypeAny, {
            card: string;
            playerId: string;
        }, {
            card: string;
            playerId: string;
        }>, "many">;
        myBid: z.ZodOptional<z.ZodNumber>;
        tricksWon: z.ZodNumber;
        tricksNeeded: z.ZodNumber;
        roundNumber: z.ZodNumber;
        leadSuit: z.ZodOptional<z.ZodString>;
        bids: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodNumber>>;
    }, "strip", z.ZodTypeAny, {
        tricksNeeded: number;
        tricksWon: number;
        trumpSuit: string;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    }, {
        tricksNeeded: number;
        tricksWon: number;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        trumpSuit?: string | undefined;
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    }>;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    gameState: {
        tricksNeeded: number;
        tricksWon: number;
        trumpSuit: string;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    };
}, {
    hand: string[];
    difficulty: "medium" | "easy" | "hard" | "expert";
    gameState: {
        tricksNeeded: number;
        tricksWon: number;
        phase: "bidding" | "playing";
        roundNumber: number;
        currentTrick: {
            card: string;
            playerId: string;
        }[];
        trumpSuit?: string | undefined;
        myBid?: number | undefined;
        leadSuit?: string | undefined;
        bids?: Record<string, number> | undefined;
    };
}>, z.ZodObject<{
    action: z.ZodEnum<["bid", "playCard"]>;
    value: z.ZodUnion<[z.ZodNumber, z.ZodString]>;
    reasoning: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    value: string | number;
    action: "bid" | "playCard";
    reasoning?: string | undefined;
}, {
    value: string | number;
    action: "bid" | "playCard";
    reasoning?: string | undefined;
}>, z.ZodTypeAny>;
export {};
//# sourceMappingURL=callBreakBotPlayFlow.d.ts.map