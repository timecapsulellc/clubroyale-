/**
 * Chat Moderation Flow - AI-powered content moderation
 *
 * Checks chat messages for toxic content, profanity, and spam.
 */
import { z } from 'zod';
declare const ModerationInputSchema: z.ZodObject<{
    message: z.ZodString;
    senderName: z.ZodString;
    roomId: z.ZodString;
    recentMessages: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    message: string;
    senderName: string;
    roomId: string;
    recentMessages?: string[] | undefined;
}, {
    message: string;
    senderName: string;
    roomId: string;
    recentMessages?: string[] | undefined;
}>;
declare const ModerationOutputSchema: z.ZodObject<{
    isAllowed: z.ZodBoolean;
    reason: z.ZodOptional<z.ZodString>;
    category: z.ZodEnum<["clean", "mild_language", "profanity", "harassment", "spam", "off_topic"]>;
    action: z.ZodEnum<["allow", "warn", "block", "mute_user"]>;
    editedMessage: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    isAllowed: boolean;
    category: "clean" | "mild_language" | "profanity" | "harassment" | "spam" | "off_topic";
    action: "allow" | "warn" | "block" | "mute_user";
    reason?: string | undefined;
    editedMessage?: string | undefined;
}, {
    isAllowed: boolean;
    category: "clean" | "mild_language" | "profanity" | "harassment" | "spam" | "off_topic";
    action: "allow" | "warn" | "block" | "mute_user";
    reason?: string | undefined;
    editedMessage?: string | undefined;
}>;
export declare const moderationFlow: import("genkit").CallableFlow<z.ZodObject<{
    message: z.ZodString;
    senderName: z.ZodString;
    roomId: z.ZodString;
    recentMessages: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    message: string;
    senderName: string;
    roomId: string;
    recentMessages?: string[] | undefined;
}, {
    message: string;
    senderName: string;
    roomId: string;
    recentMessages?: string[] | undefined;
}>, z.ZodObject<{
    isAllowed: z.ZodBoolean;
    reason: z.ZodOptional<z.ZodString>;
    category: z.ZodEnum<["clean", "mild_language", "profanity", "harassment", "spam", "off_topic"]>;
    action: z.ZodEnum<["allow", "warn", "block", "mute_user"]>;
    editedMessage: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    isAllowed: boolean;
    category: "clean" | "mild_language" | "profanity" | "harassment" | "spam" | "off_topic";
    action: "allow" | "warn" | "block" | "mute_user";
    reason?: string | undefined;
    editedMessage?: string | undefined;
}, {
    isAllowed: boolean;
    category: "clean" | "mild_language" | "profanity" | "harassment" | "spam" | "off_topic";
    action: "allow" | "warn" | "block" | "mute_user";
    reason?: string | undefined;
    editedMessage?: string | undefined;
}>, z.ZodTypeAny>;
export type ModerationInput = z.infer<typeof ModerationInputSchema>;
export type ModerationOutput = z.infer<typeof ModerationOutputSchema>;
export {};
//# sourceMappingURL=moderationFlow.d.ts.map