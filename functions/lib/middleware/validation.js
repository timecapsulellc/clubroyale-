"use strict";
/**
 * Input Validation & Sanitization
 * Security utilities to prevent injection attacks
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.GetGameTipRequestSchema = exports.SendMessageRequestSchema = exports.PlayCardRequestSchema = exports.JoinRoomRequestSchema = exports.CreateRoomRequestSchema = exports.GameTypeSchema = exports.MessageSchema = exports.DisplayNameSchema = exports.RoomCodeSchema = exports.GameIdSchema = exports.UserIdSchema = void 0;
exports.sanitizeString = sanitizeString;
exports.sanitizeHtml = sanitizeHtml;
exports.sanitizeFieldPath = sanitizeFieldPath;
exports.validate = validate;
exports.validateOrThrow = validateOrThrow;
exports.checkNoSQLInjection = checkNoSQLInjection;
exports.validateOwnership = validateOwnership;
const zod_1 = require("zod");
// ============================================
// Common Validation Schemas
// ============================================
exports.UserIdSchema = zod_1.z.string().min(1).max(128).regex(/^[a-zA-Z0-9_-]+$/);
exports.GameIdSchema = zod_1.z.string().min(1).max(64).regex(/^[a-zA-Z0-9_-]+$/);
exports.RoomCodeSchema = zod_1.z.string().length(6).regex(/^[A-Z0-9]+$/);
exports.DisplayNameSchema = zod_1.z.string().min(1).max(50).trim();
exports.MessageSchema = zod_1.z.string().min(1).max(2000).trim();
exports.GameTypeSchema = zod_1.z.enum(['royal_meld', 'marriage', 'call_break', 'teen_patti', 'in_between']);
// ============================================
// Sanitization Functions
// ============================================
/**
 * Sanitize string for safe storage and display
 */
function sanitizeString(input) {
    if (typeof input !== 'string')
        return '';
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
function sanitizeHtml(input) {
    if (typeof input !== 'string')
        return '';
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
function sanitizeFieldPath(input) {
    if (typeof input !== 'string')
        return '';
    // Remove characters that could be used for path traversal
    return input.replace(/[.[\]\/\\]/g, '');
}
/**
 * Validate input against a Zod schema
 */
function validate(schema, data) {
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
function validateOrThrow(schema, data, context = 'input') {
    const result = validate(schema, data);
    if (!result.success) {
        const error = new Error(`Invalid ${context}: ${result.errors?.join(', ')}`);
        error.code = 'invalid-argument';
        throw error;
    }
    return result.data;
}
// ============================================
// Request Validation Schemas
// ============================================
exports.CreateRoomRequestSchema = zod_1.z.object({
    gameType: exports.GameTypeSchema,
    isPrivate: zod_1.z.boolean().default(true),
    maxPlayers: zod_1.z.number().int().min(2).max(8).default(4),
    settings: zod_1.z.record(zod_1.z.unknown()).optional(),
});
exports.JoinRoomRequestSchema = zod_1.z.object({
    roomCode: exports.RoomCodeSchema,
});
exports.PlayCardRequestSchema = zod_1.z.object({
    gameId: exports.GameIdSchema,
    card: zod_1.z.object({
        suit: zod_1.z.enum(['hearts', 'diamonds', 'clubs', 'spades']),
        rank: zod_1.z.enum(['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']),
    }),
});
exports.SendMessageRequestSchema = zod_1.z.object({
    chatId: zod_1.z.string().min(1).max(128),
    content: exports.MessageSchema,
    replyTo: zod_1.z.string().optional(),
});
exports.GetGameTipRequestSchema = zod_1.z.object({
    gameType: exports.GameTypeSchema,
    gameState: zod_1.z.record(zod_1.z.unknown()),
    hand: zod_1.z.array(zod_1.z.string()),
});
// ============================================
// Security Checks
// ============================================
/**
 * Check for NoSQL injection patterns
 */
function checkNoSQLInjection(input) {
    if (typeof input !== 'string')
        return false;
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
function validateOwnership(resourceOwnerId, requesterId, allowAdmin = false) {
    if (resourceOwnerId === requesterId) {
        return true;
    }
    // TODO: Add admin check when admin system is implemented
    if (allowAdmin) {
        // Check admin status
    }
    return false;
}
exports.default = {
    sanitizeString,
    sanitizeHtml,
    sanitizeFieldPath,
    validate,
    validateOrThrow,
    checkNoSQLInjection,
    validateOwnership,
};
//# sourceMappingURL=validation.js.map