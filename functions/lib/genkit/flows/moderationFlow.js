"use strict";
/**
 * Chat Moderation Flow - AI-powered content moderation
 *
 * Checks chat messages for toxic content, profanity, and spam.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.moderationFlow = void 0;
const zod_1 = require("zod");
const config_1 = require("../config");
// Input schema for moderation request
const ModerationInputSchema = zod_1.z.object({
    message: zod_1.z.string().describe('The chat message to moderate'),
    senderName: zod_1.z.string().describe('Name of the sender'),
    roomId: zod_1.z.string().describe('Game room ID'),
    recentMessages: zod_1.z.array(zod_1.z.string()).optional().describe('Recent messages for spam detection'),
});
// Output schema for moderation result
const ModerationOutputSchema = zod_1.z.object({
    isAllowed: zod_1.z.boolean().describe('Whether the message should be allowed'),
    reason: zod_1.z.string().optional().describe('Reason if blocked'),
    category: zod_1.z.enum([
        'clean',
        'mild_language',
        'profanity',
        'harassment',
        'spam',
        'off_topic',
    ]).describe('Category of the content'),
    action: zod_1.z.enum([
        'allow',
        'warn',
        'block',
        'mute_user',
    ]).describe('Recommended action'),
    editedMessage: zod_1.z.string().optional().describe('Censored version of message if mild'),
});
// Define the moderation flow
exports.moderationFlow = config_1.ai.defineFlow({
    name: 'moderationFlow',
    inputSchema: ModerationInputSchema,
    outputSchema: ModerationOutputSchema,
}, async (input) => {
    // Quick checks before AI (performance optimization)
    const lowercaseMessage = input.message.toLowerCase();
    // Check for spam (repeated messages)
    if (input.recentMessages?.includes(input.message)) {
        return {
            isAllowed: false,
            reason: 'Duplicate message detected',
            category: 'spam',
            action: 'block',
        };
    }
    // Check message length
    if (input.message.length > 500) {
        return {
            isAllowed: false,
            reason: 'Message too long',
            category: 'spam',
            action: 'block',
        };
    }
    // Use AI for nuanced moderation
    const prompt = `You are a chat moderator for a card game called Call Break. Evaluate this message:

Message: "${input.message}"
Sender: ${input.senderName}

Context: This is an in-game chat during a card game. Players may express frustration, celebrate wins, or trash-talk mildly.

Evaluate the message and categorize it:
- "clean": Normal, friendly message
- "mild_language": Light swearing or frustration (can be allowed with warning)
- "profanity": Heavy swearing (should be blocked or censored)
- "harassment": Targeting or bullying another player (block and warn)
- "spam": Repeated/meaningless content (block)
- "off_topic": Not game-related but harmless (allow)

Consider:
1. Is this typical gaming banter or genuinely harmful?
2. Would this make other players uncomfortable?
3. Is it repetitive/spammy?

Respond with:
- isAllowed: true/false
- reason: Why it was blocked (if blocked)
- category: The category from above
- action: "allow", "warn", "block", or "mute_user"
- editedMessage: If mild_language, provide censored version (e.g., "f***")`;
    const { output } = await config_1.ai.generate({
        model: config_1.geminiFlash, // Use fast model for moderation
        prompt,
        output: { schema: ModerationOutputSchema },
    });
    return output || {
        isAllowed: true,
        category: 'clean',
        action: 'allow',
    };
});
//# sourceMappingURL=moderationFlow.js.map