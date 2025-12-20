/**
 * Input Validation & Sanitization
 * Security utilities to prevent injection attacks
 */
import { z, ZodSchema } from 'zod';
export declare const UserIdSchema: z.ZodString;
export declare const GameIdSchema: z.ZodString;
export declare const RoomCodeSchema: z.ZodString;
export declare const DisplayNameSchema: z.ZodString;
export declare const MessageSchema: z.ZodString;
export declare const GameTypeSchema: z.ZodEnum<["royal_meld", "marriage", "call_break", "teen_patti", "in_between"]>;
/**
 * Sanitize string for safe storage and display
 */
export declare function sanitizeString(input: string): string;
/**
 * Sanitize HTML to prevent XSS
 */
export declare function sanitizeHtml(input: string): string;
/**
 * Sanitize for Firestore field path
 */
export declare function sanitizeFieldPath(input: string): string;
interface ValidationResult<T> {
    success: boolean;
    data?: T;
    errors?: string[];
}
/**
 * Validate input against a Zod schema
 */
export declare function validate<T>(schema: ZodSchema<T>, data: unknown): ValidationResult<T>;
/**
 * Validate and throw if invalid
 */
export declare function validateOrThrow<T>(schema: ZodSchema<T>, data: unknown, context?: string): T;
export declare const CreateRoomRequestSchema: z.ZodObject<{
    gameType: z.ZodEnum<["royal_meld", "marriage", "call_break", "teen_patti", "in_between"]>;
    isPrivate: z.ZodDefault<z.ZodBoolean>;
    maxPlayers: z.ZodDefault<z.ZodNumber>;
    settings: z.ZodOptional<z.ZodRecord<z.ZodString, z.ZodUnknown>>;
}, "strip", z.ZodTypeAny, {
    gameType: "royal_meld" | "marriage" | "call_break" | "teen_patti" | "in_between";
    maxPlayers: number;
    isPrivate: boolean;
    settings?: Record<string, unknown> | undefined;
}, {
    gameType: "royal_meld" | "marriage" | "call_break" | "teen_patti" | "in_between";
    maxPlayers?: number | undefined;
    settings?: Record<string, unknown> | undefined;
    isPrivate?: boolean | undefined;
}>;
export declare const JoinRoomRequestSchema: z.ZodObject<{
    roomCode: z.ZodString;
}, "strip", z.ZodTypeAny, {
    roomCode: string;
}, {
    roomCode: string;
}>;
export declare const PlayCardRequestSchema: z.ZodObject<{
    gameId: z.ZodString;
    card: z.ZodObject<{
        suit: z.ZodEnum<["hearts", "diamonds", "clubs", "spades"]>;
        rank: z.ZodEnum<["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]>;
    }, "strip", z.ZodTypeAny, {
        rank: "2" | "3" | "4" | "5" | "A" | "K" | "Q" | "7" | "6" | "8" | "9" | "10" | "J";
        suit: "spades" | "diamonds" | "hearts" | "clubs";
    }, {
        rank: "2" | "3" | "4" | "5" | "A" | "K" | "Q" | "7" | "6" | "8" | "9" | "10" | "J";
        suit: "spades" | "diamonds" | "hearts" | "clubs";
    }>;
}, "strip", z.ZodTypeAny, {
    card: {
        rank: "2" | "3" | "4" | "5" | "A" | "K" | "Q" | "7" | "6" | "8" | "9" | "10" | "J";
        suit: "spades" | "diamonds" | "hearts" | "clubs";
    };
    gameId: string;
}, {
    card: {
        rank: "2" | "3" | "4" | "5" | "A" | "K" | "Q" | "7" | "6" | "8" | "9" | "10" | "J";
        suit: "spades" | "diamonds" | "hearts" | "clubs";
    };
    gameId: string;
}>;
export declare const SendMessageRequestSchema: z.ZodObject<{
    chatId: z.ZodString;
    content: z.ZodString;
    replyTo: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    content: string;
    chatId: string;
    replyTo?: string | undefined;
}, {
    content: string;
    chatId: string;
    replyTo?: string | undefined;
}>;
export declare const GetGameTipRequestSchema: z.ZodObject<{
    gameType: z.ZodEnum<["royal_meld", "marriage", "call_break", "teen_patti", "in_between"]>;
    gameState: z.ZodRecord<z.ZodString, z.ZodUnknown>;
    hand: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    hand: string[];
    gameType: "royal_meld" | "marriage" | "call_break" | "teen_patti" | "in_between";
    gameState: Record<string, unknown>;
}, {
    hand: string[];
    gameType: "royal_meld" | "marriage" | "call_break" | "teen_patti" | "in_between";
    gameState: Record<string, unknown>;
}>;
/**
 * Check for NoSQL injection patterns
 */
export declare function checkNoSQLInjection(input: unknown): boolean;
/**
 * Validate that user has access to a resource
 */
export declare function validateOwnership(resourceOwnerId: string, requesterId: string, allowAdmin?: boolean): boolean;
declare const _default: {
    sanitizeString: typeof sanitizeString;
    sanitizeHtml: typeof sanitizeHtml;
    sanitizeFieldPath: typeof sanitizeFieldPath;
    validate: typeof validate;
    validateOrThrow: typeof validateOrThrow;
    checkNoSQLInjection: typeof checkNoSQLInjection;
    validateOwnership: typeof validateOwnership;
};
export default _default;
//# sourceMappingURL=validation.d.ts.map