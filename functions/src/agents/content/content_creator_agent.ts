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

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { onCall, HttpsError } from 'firebase-functions/v2/https';

// Initialize GenKit
const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// SCHEMAS
// =============================================================================

const StoryGenerationInputSchema = z.object({
    storyType: z.enum(['game_result', 'achievement', 'highlight', 'social', 'custom']),
    context: z.object({
        gameType: z.string().optional(),
        result: z.enum(['win', 'loss', 'draw']).optional(),
        score: z.number().optional(),
        achievement: z.string().optional(),
        customPrompt: z.string().optional(),
        userName: z.string().optional(),
    }),
    style: z.enum(['celebratory', 'funny', 'dramatic', 'minimal', 'professional']),
    language: z.string().default('en'),
});

const StoryGenerationOutputSchema = z.object({
    caption: z.string().describe('Engaging caption for the story'),
    hashtags: z.array(z.string()).describe('Relevant hashtags'),
    suggestedFilters: z.array(z.string()).describe('Visual filter suggestions'),
    suggestedMusic: z.string().optional().describe('Music recommendation'),
    backgroundStyle: z.string().describe('Background design suggestion'),
    mood: z.string().describe('Overall mood of the content'),
    emojis: z.array(z.string()).describe('Suggested emojis'),
});

const ReelScriptInputSchema = z.object({
    topic: z.string().describe('Topic for the reel'),
    duration: z.enum(['15s', '30s', '60s']),
    style: z.enum(['tutorial', 'entertainment', 'highlight', 'meme', 'storytelling']),
    targetAudience: z.string().optional(),
    gameType: z.string().optional(),
});

const ReelScriptOutputSchema = z.object({
    script: z.array(z.object({
        timestamp: z.string(),
        action: z.string(),
        text: z.string().optional(),
        visualCue: z.string(),
        audioNote: z.string().optional(),
    })).describe('Scene-by-scene script'),
    suggestedMusic: z.string(),
    hashtags: z.array(z.string()),
    hook: z.string().describe('Opening hook to grab attention'),
    callToAction: z.string().describe('Ending CTA'),
});

const CaptionGenerationInputSchema = z.object({
    contentType: z.enum(['post', 'story', 'bio', 'comment']),
    context: z.string(),
    tone: z.enum(['casual', 'professional', 'funny', 'inspirational', 'competitive']),
    includeEmojis: z.boolean().default(true),
    maxLength: z.number().optional(),
});

const CaptionGenerationOutputSchema = z.object({
    primary: z.string().describe('Main caption option'),
    alternatives: z.array(z.string()).describe('Alternative captions'),
    hashtags: z.array(z.string()),
});

// =============================================================================
// GENKIT FLOWS
// =============================================================================

/**
 * Generate Story Content
 * Creates captions, hashtags, and styling for stories
 */
export const generateStoryFlow = ai.defineFlow(
    {
        name: 'generateStory',
        inputSchema: StoryGenerationInputSchema,
        outputSchema: StoryGenerationOutputSchema,
    },
    async (input) => {
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
    }
);

/**
 * Generate Reel Script
 * Creates scene-by-scene scripts for short videos
 */
export const generateReelScriptFlow = ai.defineFlow(
    {
        name: 'generateReelScript',
        inputSchema: ReelScriptInputSchema,
        outputSchema: ReelScriptOutputSchema,
    },
    async (input) => {
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
    }
);

/**
 * Generate Caption
 * Creates engaging captions for various content types
 */
export const generateCaptionFlow = ai.defineFlow(
    {
        name: 'generateCaption',
        inputSchema: CaptionGenerationInputSchema,
        outputSchema: CaptionGenerationOutputSchema,
    },
    async (input) => {
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
    }
);

/**
 * Generate Achievement Celebration
 * Creates custom celebration content for achievements
 */
export const generateAchievementCelebrationFlow = ai.defineFlow(
    {
        name: 'generateAchievementCelebration',
        inputSchema: z.object({
            achievement: z.string(),
            achievementType: z.enum(['rank', 'streak', 'wins', 'diamonds', 'social', 'special']),
            userName: z.string().optional(),
            value: z.number().optional(),
        }),
        outputSchema: z.object({
            title: z.string(),
            subtitle: z.string(),
            animation: z.string(),
            sound: z.string(),
            shareCaption: z.string(),
            badgeStyle: z.object({
                color: z.string(),
                icon: z.string(),
                effect: z.string(),
            }),
        }),
    },
    async (input) => {
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
                schema: z.object({
                    title: z.string(),
                    subtitle: z.string(),
                    animation: z.string(),
                    sound: z.string(),
                    shareCaption: z.string(),
                    badgeStyle: z.object({
                        color: z.string(),
                        icon: z.string(),
                        effect: z.string(),
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
    }
);

// =============================================================================
// FIREBASE CALLABLE FUNCTIONS
// =============================================================================

export const generateStory = onCall(
    { maxInstances: 20, timeoutSeconds: 30 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }
        try {
            return await generateStoryFlow(request.data);
        } catch (error: any) {
            console.error('Story generation error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

export const generateReelScript = onCall(
    { maxInstances: 10, timeoutSeconds: 45 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }
        try {
            return await generateReelScriptFlow(request.data);
        } catch (error: any) {
            console.error('Reel script error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

export const generateCaption = onCall(
    { maxInstances: 20, timeoutSeconds: 15 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }
        try {
            return await generateCaptionFlow(request.data);
        } catch (error: any) {
            console.error('Caption generation error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);

export const generateAchievementCelebration = onCall(
    { maxInstances: 20, timeoutSeconds: 15 },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError('unauthenticated', 'Authentication required');
        }
        try {
            return await generateAchievementCelebrationFlow(request.data);
        } catch (error: any) {
            console.error('Achievement celebration error:', error);
            throw new HttpsError('internal', error.message);
        }
    }
);
