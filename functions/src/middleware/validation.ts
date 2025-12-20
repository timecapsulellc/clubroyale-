/**
 * Input Validation & Sanitization
 * Security utilities to prevent injection attacks
 */

import { z, ZodSchema } from 'zod';

// ============================================
// Common Validation Schemas
// ============================================

export const UserIdSchema = z.string().min(1).max(128).regex(/^[a-zA-Z0-9_-]+$/);
export const GameIdSchema = z.string().min(1).max(64).regex(/^[a-zA-Z0-9_-]+$/);
export const RoomCodeSchema = z.string().length(6).regex(/^[A-Z0-9]+$/);
export const DisplayNameSchema = z.string().min(1).max(50).trim();
export const MessageSchema = z.string().min(1).max(2000).trim();
export const GameTypeSchema = z.enum(['royal_meld', 'marriage', 'call_break', 'teen_patti', 'in_between']);

// ============================================
// Sanitization Functions
// ============================================

/**
 * Sanitize string for safe storage and display
 */
export function sanitizeString(input: string): string {
    if (typeof input !== 'string') return '';

    return input
        .trim()
        // Remove null bytes
        .replace(/\0/g, '')
        // Remove control characters except newlines and tabs
        .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '')
        // Limit consecutive whitespace
        .replace(/\s{3,}/g, '  ');
}

/**
 * Sanitize HTML to prevent XSS
 */
export function sanitizeHtml(input: string): string {
    if (typeof input !== 'string') return '';

    return input
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .replace(/\//g, '&#x2F;');
}

/**
 * Sanitize for Firestore field path
 */
export function sanitizeFieldPath(input: string): string {
    if (typeof input !== 'string') return '';

    // Remove characters that could be used for path traversal
    return input.replace(/[.[\]\/\\]/g, '');
}

// ============================================
// Validation Utilities
// ============================================

interface ValidationResult<T> {
    success: boolean;
    data?: T;
    errors?: string[];
}

/**
 * Validate input against a Zod schema
 */
export function validate<T>(
    schema: ZodSchema<T>,
    data: unknown
): ValidationResult<T> {
    const result = schema.safeParse(data);

    if (result.success) {
        return { success: true, data: result.data };
    }

    return {
        success: false,
        errors: result.error.issues.map((issue) => `${issue.path.join('.')}: ${issue.message}`),
    };
}

/**
 * Validate and throw if invalid
 */
export function validateOrThrow<T>(
    schema: ZodSchema<T>,
    data: unknown,
    context: string = 'input'
): T {
    const result = validate(schema, data);

    if (!result.success) {
        const error = new Error(`Invalid ${context}: ${result.errors?.join(', ')}`);
        (error as any).code = 'invalid-argument';
        throw error;
    }

    return result.data!;
}

// ============================================
// Request Validation Schemas
// ============================================

export const CreateRoomRequestSchema = z.object({
    gameType: GameTypeSchema,
    isPrivate: z.boolean().default(true),
    maxPlayers: z.number().int().min(2).max(8).default(4),
    settings: z.record(z.unknown()).optional(),
});

export const JoinRoomRequestSchema = z.object({
    roomCode: RoomCodeSchema,
});

export const PlayCardRequestSchema = z.object({
    gameId: GameIdSchema,
    card: z.object({
        suit: z.enum(['hearts', 'diamonds', 'clubs', 'spades']),
        rank: z.enum(['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']),
    }),
});

export const SendMessageRequestSchema = z.object({
    chatId: z.string().min(1).max(128),
    content: MessageSchema,
    replyTo: z.string().optional(),
});

export const GetGameTipRequestSchema = z.object({
    gameType: GameTypeSchema,
    gameState: z.record(z.unknown()),
    hand: z.array(z.string()),
});

// ============================================
// Security Checks
// ============================================

/**
 * Check for NoSQL injection patterns
 */
export function checkNoSQLInjection(input: unknown): boolean {
    if (typeof input !== 'string') return false;

    const suspiciousPatterns = [
        /\$where/i,
        /\$gt/i,
        /\$lt/i,
        /\$ne/i,
        /\$or/i,
        /\$and/i,
        /\$regex/i,
        /\.\$\./,
        /__proto__/,
        /constructor/,
        /prototype/,
    ];

    return suspiciousPatterns.some((pattern) => pattern.test(input));
}

/**
 * Validate that user has access to a resource
 */
export function validateOwnership(
    resourceOwnerId: string,
    requesterId: string,
    allowAdmin: boolean = false
): boolean {
    if (resourceOwnerId === requesterId) {
        return true;
    }

    // TODO: Add admin check when admin system is implemented
    if (allowAdmin) {
        // Check admin status
    }

    return false;
}

export default {
    sanitizeString,
    sanitizeHtml,
    sanitizeFieldPath,
    validate,
    validateOrThrow,
    checkNoSQLInjection,
    validateOwnership,
};
