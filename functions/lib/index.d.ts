/**
 * TaasClub - Cloud Functions with Genkit AI
 *
 * Main entry point for all Cloud Functions including:
 * - Anti-cheat validation (existing)
 * - AI-powered game features (Genkit)
 */
export { generateLiveKitToken, validateSpectatorAccess } from './livekit/tokenService';
/**
 * Get AI-powered game tip for current play
 */
export declare const getGameTip: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    suggestedCard: string;
    reasoning: string;
    confidence: "high" | "medium" | "low";
    alternativeCard?: string | undefined;
    success: boolean;
}>, unknown>;
/**
 * Get AI bot's card selection
 */
export declare const getBotPlay: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    selectedCard: string;
    strategy: string;
    success: boolean;
}>, unknown>;
/**
 * Moderate a chat message
 */
export declare const moderateChat: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    isAllowed: boolean;
    category: "clean" | "mild_language" | "profanity" | "harassment" | "spam" | "off_topic";
    action: "allow" | "warn" | "block" | "mute_user";
    reason?: string | undefined;
    editedMessage?: string | undefined;
    success: boolean;
} | {
    success: boolean;
    isAllowed: boolean;
    category: string;
    action: string;
}>, unknown>;
/**
 * Get AI-powered bid suggestion
 */
export declare const getBidSuggestion: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    reasoning: string;
    confidence: "high" | "medium" | "low";
    suggestedBid: number;
    handStrength: "weak" | "average" | "strong" | "very_strong";
    riskLevel: "safe" | "moderate" | "aggressive";
    success: boolean;
}>, unknown>;
/**
 * Validate a bid in Call Break
 */
export declare const validateBid: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    message: string;
}>, unknown>;
/**
 * Validate a card move in Call Break
 */
export declare const validateMove: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    message: string;
}>, unknown>;
/**
 * Process settlement after game ends
 */
export declare const processSettlement: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    settlements: {
        from: string;
        to: string;
        amount: number;
        timestamp: string;
    }[];
    message: string;
}>, unknown>;
//# sourceMappingURL=index.d.ts.map