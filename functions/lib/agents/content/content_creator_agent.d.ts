/**
 * Content Creator Agent - AI-Generated Content for ClubRoyale
 *
 * Generated using IDE Guide Agent patterns.
 *
 * Features:
 * - Story content generation (captions, hashtags, backgrounds)
 * - Reel/Short video script generation
 * - AI image generation for posts
 * - Achievement celebration content
 *
 * Powered by Google GenKit + Gemini 2.0 Flash + Imagen 3
 */
import { z } from 'genkit';
/**
 * Generate Story Content
 * Creates captions, hashtags, and styling for stories
 */
export declare const generateStoryFlow: import("genkit").CallableFlow<z.ZodObject<{
    storyType: z.ZodEnum<["game_result", "achievement", "highlight", "social", "custom"]>;
    context: z.ZodObject<{
        gameType: z.ZodOptional<z.ZodString>;
        result: z.ZodOptional<z.ZodEnum<["win", "loss", "draw"]>>;
        score: z.ZodOptional<z.ZodNumber>;
        achievement: z.ZodOptional<z.ZodString>;
        customPrompt: z.ZodOptional<z.ZodString>;
        userName: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        gameType?: string | undefined;
        score?: number | undefined;
        achievement?: string | undefined;
        result?: "draw" | "win" | "loss" | undefined;
        customPrompt?: string | undefined;
        userName?: string | undefined;
    }, {
        gameType?: string | undefined;
        score?: number | undefined;
        achievement?: string | undefined;
        result?: "draw" | "win" | "loss" | undefined;
        customPrompt?: string | undefined;
        userName?: string | undefined;
    }>;
    style: z.ZodEnum<["celebratory", "funny", "dramatic", "minimal", "professional"]>;
    language: z.ZodDefault<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    storyType: "custom" | "social" | "achievement" | "game_result" | "highlight";
    language: string;
    context: {
        gameType?: string | undefined;
        score?: number | undefined;
        achievement?: string | undefined;
        result?: "draw" | "win" | "loss" | undefined;
        customPrompt?: string | undefined;
        userName?: string | undefined;
    };
    style: "celebratory" | "funny" | "dramatic" | "minimal" | "professional";
}, {
    storyType: "custom" | "social" | "achievement" | "game_result" | "highlight";
    context: {
        gameType?: string | undefined;
        score?: number | undefined;
        achievement?: string | undefined;
        result?: "draw" | "win" | "loss" | undefined;
        customPrompt?: string | undefined;
        userName?: string | undefined;
    };
    style: "celebratory" | "funny" | "dramatic" | "minimal" | "professional";
    language?: string | undefined;
}>, z.ZodObject<{
    caption: z.ZodString;
    hashtags: z.ZodArray<z.ZodString, "many">;
    suggestedFilters: z.ZodArray<z.ZodString, "many">;
    suggestedMusic: z.ZodOptional<z.ZodString>;
    backgroundStyle: z.ZodString;
    mood: z.ZodString;
    emojis: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    caption: string;
    hashtags: string[];
    suggestedFilters: string[];
    backgroundStyle: string;
    mood: string;
    emojis: string[];
    suggestedMusic?: string | undefined;
}, {
    caption: string;
    hashtags: string[];
    suggestedFilters: string[];
    backgroundStyle: string;
    mood: string;
    emojis: string[];
    suggestedMusic?: string | undefined;
}>, z.ZodTypeAny>;
/**
 * Generate Reel Script
 * Creates scene-by-scene scripts for short videos
 */
export declare const generateReelScriptFlow: import("genkit").CallableFlow<z.ZodObject<{
    topic: z.ZodString;
    duration: z.ZodEnum<["15s", "30s", "60s"]>;
    style: z.ZodEnum<["tutorial", "entertainment", "highlight", "meme", "storytelling"]>;
    targetAudience: z.ZodOptional<z.ZodString>;
    gameType: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    topic: string;
    style: "highlight" | "tutorial" | "entertainment" | "meme" | "storytelling";
    duration: "15s" | "30s" | "60s";
    gameType?: string | undefined;
    targetAudience?: string | undefined;
}, {
    topic: string;
    style: "highlight" | "tutorial" | "entertainment" | "meme" | "storytelling";
    duration: "15s" | "30s" | "60s";
    gameType?: string | undefined;
    targetAudience?: string | undefined;
}>, z.ZodObject<{
    script: z.ZodArray<z.ZodObject<{
        timestamp: z.ZodString;
        action: z.ZodString;
        text: z.ZodOptional<z.ZodString>;
        visualCue: z.ZodString;
        audioNote: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        action: string;
        timestamp: string;
        visualCue: string;
        text?: string | undefined;
        audioNote?: string | undefined;
    }, {
        action: string;
        timestamp: string;
        visualCue: string;
        text?: string | undefined;
        audioNote?: string | undefined;
    }>, "many">;
    suggestedMusic: z.ZodString;
    hashtags: z.ZodArray<z.ZodString, "many">;
    hook: z.ZodString;
    callToAction: z.ZodString;
}, "strip", z.ZodTypeAny, {
    hashtags: string[];
    suggestedMusic: string;
    script: {
        action: string;
        timestamp: string;
        visualCue: string;
        text?: string | undefined;
        audioNote?: string | undefined;
    }[];
    hook: string;
    callToAction: string;
}, {
    hashtags: string[];
    suggestedMusic: string;
    script: {
        action: string;
        timestamp: string;
        visualCue: string;
        text?: string | undefined;
        audioNote?: string | undefined;
    }[];
    hook: string;
    callToAction: string;
}>, z.ZodTypeAny>;
/**
 * Generate Caption
 * Creates engaging captions for various content types
 */
export declare const generateCaptionFlow: import("genkit").CallableFlow<z.ZodObject<{
    contentType: z.ZodEnum<["post", "story", "bio", "comment"]>;
    context: z.ZodString;
    tone: z.ZodEnum<["casual", "professional", "funny", "inspirational", "competitive"]>;
    includeEmojis: z.ZodDefault<z.ZodBoolean>;
    maxLength: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    context: string;
    contentType: "post" | "story" | "bio" | "comment";
    tone: "funny" | "professional" | "casual" | "inspirational" | "competitive";
    includeEmojis: boolean;
    maxLength?: number | undefined;
}, {
    context: string;
    contentType: "post" | "story" | "bio" | "comment";
    tone: "funny" | "professional" | "casual" | "inspirational" | "competitive";
    includeEmojis?: boolean | undefined;
    maxLength?: number | undefined;
}>, z.ZodObject<{
    primary: z.ZodString;
    alternatives: z.ZodArray<z.ZodString, "many">;
    hashtags: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    alternatives: string[];
    hashtags: string[];
    primary: string;
}, {
    alternatives: string[];
    hashtags: string[];
    primary: string;
}>, z.ZodTypeAny>;
/**
 * Generate Achievement Celebration
 * Creates custom celebration content for achievements
 */
export declare const generateAchievementCelebrationFlow: import("genkit").CallableFlow<z.ZodObject<{
    achievement: z.ZodString;
    achievementType: z.ZodEnum<["rank", "streak", "wins", "diamonds", "social", "special"]>;
    userName: z.ZodOptional<z.ZodString>;
    value: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    achievement: string;
    achievementType: "social" | "rank" | "streak" | "wins" | "diamonds" | "special";
    value?: number | undefined;
    userName?: string | undefined;
}, {
    achievement: string;
    achievementType: "social" | "rank" | "streak" | "wins" | "diamonds" | "special";
    value?: number | undefined;
    userName?: string | undefined;
}>, z.ZodObject<{
    title: z.ZodString;
    subtitle: z.ZodString;
    animation: z.ZodString;
    sound: z.ZodString;
    shareCaption: z.ZodString;
    badgeStyle: z.ZodObject<{
        color: z.ZodString;
        icon: z.ZodString;
        effect: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        color: string;
        icon: string;
        effect: string;
    }, {
        color: string;
        icon: string;
        effect: string;
    }>;
}, "strip", z.ZodTypeAny, {
    title: string;
    subtitle: string;
    animation: string;
    sound: string;
    shareCaption: string;
    badgeStyle: {
        color: string;
        icon: string;
        effect: string;
    };
}, {
    title: string;
    subtitle: string;
    animation: string;
    sound: string;
    shareCaption: string;
    badgeStyle: {
        color: string;
        icon: string;
        effect: string;
    };
}>, z.ZodTypeAny>;
export declare const generateStory: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    caption: string;
    hashtags: string[];
    suggestedFilters: string[];
    backgroundStyle: string;
    mood: string;
    emojis: string[];
    suggestedMusic?: string | undefined;
}>, unknown>;
export declare const generateReelScript: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    hashtags: string[];
    suggestedMusic: string;
    script: {
        action: string;
        timestamp: string;
        visualCue: string;
        text?: string | undefined;
        audioNote?: string | undefined;
    }[];
    hook: string;
    callToAction: string;
}>, unknown>;
export declare const generateCaption: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    alternatives: string[];
    hashtags: string[];
    primary: string;
}>, unknown>;
export declare const generateAchievementCelebration: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    title: string;
    subtitle: string;
    animation: string;
    sound: string;
    shareCaption: string;
    badgeStyle: {
        color: string;
        icon: string;
        effect: string;
    };
}>, unknown>;
//# sourceMappingURL=content_creator_agent.d.ts.map