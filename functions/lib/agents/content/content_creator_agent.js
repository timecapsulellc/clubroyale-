"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateAchievementCelebration = exports.generateCaption = exports.generateReelScript = exports.generateStory = exports.generateAchievementCelebrationFlow = exports.generateCaptionFlow = exports.generateReelScriptFlow = exports.generateStoryFlow = void 0;
const genkit_1 = require("genkit");
const googleai_1 = require("@genkit-ai/googleai");
const https_1 = require("firebase-functions/v2/https");
// Initialize GenKit
const ai = (0, genkit_1.genkit)({
    plugins: [(0, googleai_1.googleAI)()],
    model: googleai_1.gemini20FlashExp,
});
// =============================================================================
// SCHEMAS
// =============================================================================
const StoryGenerationInputSchema = genkit_1.z.object({
    storyType: genkit_1.z.enum(['game_result', 'achievement', 'highlight', 'social', 'custom']),
    context: genkit_1.z.object({
        gameType: genkit_1.z.string().optional(),
        result: genkit_1.z.enum(['win', 'loss', 'draw']).optional(),
        score: genkit_1.z.number().optional(),
        achievement: genkit_1.z.string().optional(),
        customPrompt: genkit_1.z.string().optional(),
        userName: genkit_1.z.string().optional(),
    }),
    style: genkit_1.z.enum(['celebratory', 'funny', 'dramatic', 'minimal', 'professional']),
    language: genkit_1.z.string().default('en'),
});
const StoryGenerationOutputSchema = genkit_1.z.object({
    caption: genkit_1.z.string().describe('Engaging caption for the story'),
    hashtags: genkit_1.z.array(genkit_1.z.string()).describe('Relevant hashtags'),
    suggestedFilters: genkit_1.z.array(genkit_1.z.string()).describe('Visual filter suggestions'),
    suggestedMusic: genkit_1.z.string().optional().describe('Music recommendation'),
    backgroundStyle: genkit_1.z.string().describe('Background design suggestion'),
    mood: genkit_1.z.string().describe('Overall mood of the content'),
    emojis: genkit_1.z.array(genkit_1.z.string()).describe('Suggested emojis'),
});
const ReelScriptInputSchema = genkit_1.z.object({
    topic: genkit_1.z.string().describe('Topic for the reel'),
    duration: genkit_1.z.enum(['15s', '30s', '60s']),
    style: genkit_1.z.enum(['tutorial', 'entertainment', 'highlight', 'meme', 'storytelling']),
    targetAudience: genkit_1.z.string().optional(),
    gameType: genkit_1.z.string().optional(),
});
const ReelScriptOutputSchema = genkit_1.z.object({
    script: genkit_1.z.array(genkit_1.z.object({
        timestamp: genkit_1.z.string(),
        action: genkit_1.z.string(),
        text: genkit_1.z.string().optional(),
        visualCue: genkit_1.z.string(),
        audioNote: genkit_1.z.string().optional(),
    })).describe('Scene-by-scene script'),
    suggestedMusic: genkit_1.z.string(),
    hashtags: genkit_1.z.array(genkit_1.z.string()),
    hook: genkit_1.z.string().describe('Opening hook to grab attention'),
    callToAction: genkit_1.z.string().describe('Ending CTA'),
});
const CaptionGenerationInputSchema = genkit_1.z.object({
    contentType: genkit_1.z.enum(['post', 'story', 'bio', 'comment']),
    context: genkit_1.z.string(),
    tone: genkit_1.z.enum(['casual', 'professional', 'funny', 'inspirational', 'competitive']),
    includeEmojis: genkit_1.z.boolean().default(true),
    maxLength: genkit_1.z.number().optional(),
});
const CaptionGenerationOutputSchema = genkit_1.z.object({
    primary: genkit_1.z.string().describe('Main caption option'),
    alternatives: genkit_1.z.array(genkit_1.z.string()).describe('Alternative captions'),
    hashtags: genkit_1.z.array(genkit_1.z.string()),
});
// =============================================================================
// GENKIT FLOWS
// =============================================================================
/**
 * Generate Story Content
 * Creates captions, hashtags, and styling for stories
 */
exports.generateStoryFlow = ai.defineFlow({
    name: 'generateStory',
    inputSchema: StoryGenerationInputSchema,
    outputSchema: StoryGenerationOutputSchema,
}, async (input) => {
    const prompt = `You are the Content Creator for ClubRoyale, a social gaming platform.

Create engaging story content for a ${input.storyType} story.
Style: ${input.style}
Language: ${input.language}

Context:
${input.context.gameType ? `- Game: ${input.context.gameType}` : ''}
${input.context.result ? `- Result: ${input.context.result}` : ''}
${input.context.score ? `- Score: ${input.context.score}` : ''}
${input.context.achievement ? `- Achievement: ${input.context.achievement}` : ''}
${input.context.customPrompt ? `- Custom: ${input.context.customPrompt}` : ''}
${input.context.userName ? `- User: ${input.context.userName}` : ''}

Generate:
1. An engaging caption (max 150 chars, punchy and shareable)
2. 5-7 relevant hashtags (mix of popular and niche)
3. Visual filter suggestions (Instagram-style)
4. Background style (gradient colors, patterns)
5. Mood and emojis that match the content

ClubRoyale Hashtags to include: #ClubRoyale #CardGames
For wins: #Winner #Victory
For achievements: #LevelUp #Achievement`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: StoryGenerationOutputSchema },
    });
    return output ?? {
        caption: 'Great game! 🎮',
        hashtags: ['#ClubRoyale', '#Gaming'],
        suggestedFilters: ['Gold Glow'],
        backgroundStyle: 'Purple gradient',
        mood: 'Exciting',
        emojis: ['🎮', '🎉'],
    };
});
/**
 * Generate Reel Script
 * Creates scene-by-scene scripts for short videos
 */
exports.generateReelScriptFlow = ai.defineFlow({
    name: 'generateReelScript',
    inputSchema: ReelScriptInputSchema,
    outputSchema: ReelScriptOutputSchema,
}, async (input) => {
    const prompt = `Create a ${input.duration} reel script for ClubRoyale.

Topic: ${input.topic}
Style: ${input.style}
${input.gameType ? `Game: ${input.gameType}` : ''}
${input.targetAudience ? `Audience: ${input.targetAudience}` : ''}

Create a scene-by-scene script with:
1. Attention-grabbing hook in first 3 seconds
2. Clear visual cues for each scene
3. Text overlays where needed
4. Audio/music notes
5. Strong call-to-action at the end

The reel should be:
- Fast-paced and engaging
- Easy to follow
- Shareable and memorable
- On-brand for ClubRoyale (fun, competitive, social)`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: ReelScriptOutputSchema },
    });
    return output ?? {
        script: [{ timestamp: '0:00', action: 'Open', text: input.topic, visualCue: 'Game screen' }],
        suggestedMusic: 'Upbeat electronic',
        hashtags: ['#ClubRoyale', '#Gaming'],
        hook: 'Watch this!',
        callToAction: 'Follow for more!',
    };
});
/**
 * Generate Caption
 * Creates engaging captions for various content types
 */
exports.generateCaptionFlow = ai.defineFlow({
    name: 'generateCaption',
    inputSchema: CaptionGenerationInputSchema,
    outputSchema: CaptionGenerationOutputSchema,
}, async (input) => {
    const prompt = `Generate a ${input.tone} caption for a ${input.contentType} on ClubRoyale.

Context: ${input.context}
Include emojis: ${input.includeEmojis}
${input.maxLength ? `Max length: ${input.maxLength} characters` : ''}

Create:
1. Primary caption (engaging, shareable)
2. 2-3 alternative options
3. Relevant hashtags

Keep it authentic to the ClubRoyale community - card game enthusiasts who love competition and social gaming.`;
    const { output } = await ai.generate({
        prompt,
        output: { schema: CaptionGenerationOutputSchema },
    });
    return output ?? {
        primary: 'Having a great time! 🎮',
        alternatives: ['Great game!', 'Let\'s play!'],
        hashtags: ['#ClubRoyale'],
    };
});
/**
 * Generate Achievement Celebration
 * Creates custom celebration content for achievements
 */
exports.generateAchievementCelebrationFlow = ai.defineFlow({
    name: 'generateAchievementCelebration',
    inputSchema: genkit_1.z.object({
        achievement: genkit_1.z.string(),
        achievementType: genkit_1.z.enum(['rank', 'streak', 'wins', 'diamonds', 'social', 'special']),
        userName: genkit_1.z.string().optional(),
        value: genkit_1.z.number().optional(),
    }),
    outputSchema: genkit_1.z.object({
        title: genkit_1.z.string(),
        subtitle: genkit_1.z.string(),
        animation: genkit_1.z.string(),
        sound: genkit_1.z.string(),
        shareCaption: genkit_1.z.string(),
        badgeStyle: genkit_1.z.object({
            color: genkit_1.z.string(),
            icon: genkit_1.z.string(),
            effect: genkit_1.z.string(),
        }),
    }),
}, async (input) => {
    const prompt = `Create celebration content for a ClubRoyale achievement.

Achievement: ${input.achievement}
Type: ${input.achievementType}
${input.userName ? `User: ${input.userName}` : ''}
${input.value ? `Value: ${input.value}` : ''}

Generate:
1. Celebration title (exciting, bold)
2. Subtitle with context
3. Animation style (confetti, fireworks, etc.)
4. Sound effect description
5. Share caption for social
6. Badge styling (color, icon, visual effect)

Make it feel like a big deal - achievements should be celebrated!`;
    const { output } = await ai.generate({
        prompt,
        output: {
            schema: genkit_1.z.object({
                title: genkit_1.z.string(),
                subtitle: genkit_1.z.string(),
                animation: genkit_1.z.string(),
                sound: genkit_1.z.string(),
                shareCaption: genkit_1.z.string(),
                badgeStyle: genkit_1.z.object({
                    color: genkit_1.z.string(),
                    icon: genkit_1.z.string(),
                    effect: genkit_1.z.string(),
                }),
            }),
        },
    });
    return output ?? {
        title: 'Achievement Unlocked!',
        subtitle: input.achievement,
        animation: 'confetti',
        sound: 'victory_fanfare',
        shareCaption: `Just unlocked: ${input.achievement}! 🏆 #ClubRoyale`,
        badgeStyle: { color: 'gold', icon: '🏆', effect: 'glow' },
    };
});
// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================
exports.generateStory = (0, https_1.onCall)({ maxInstances: 20, timeoutSeconds: 30 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        return await (0, exports.generateStoryFlow)(request.data);
    }
    catch (error) {
        console.error('Story generation error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.generateReelScript = (0, https_1.onCall)({ maxInstances: 10, timeoutSeconds: 45 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        return await (0, exports.generateReelScriptFlow)(request.data);
    }
    catch (error) {
        console.error('Reel script error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.generateCaption = (0, https_1.onCall)({ maxInstances: 20, timeoutSeconds: 15 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        return await (0, exports.generateCaptionFlow)(request.data);
    }
    catch (error) {
        console.error('Caption generation error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
exports.generateAchievementCelebration = (0, https_1.onCall)({ maxInstances: 20, timeoutSeconds: 15 }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required');
    }
    try {
        return await (0, exports.generateAchievementCelebrationFlow)(request.data);
    }
    catch (error) {
        console.error('Achievement celebration error:', error);
        throw new https_1.HttpsError('internal', error.message);
    }
});
//# sourceMappingURL=content_creator_agent.js.map