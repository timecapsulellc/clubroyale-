/**
 * ClubRoyale AI Agents - Master Export
 * 
 * Central export for all AI agent Cloud Functions
 * Total: 12 Specialized AI Agents
 */

// IDE Guide Agent - Development Assistant
export {
    generateCode,
    getArchitectureGuidance,
    analyzeBug,
    planFeatureImplementation,
} from './ide_guide';

// Content Creator Agent - AI-Generated Content
export {
    generateStory,
    generateReelScript,
    generateCaption,
    generateAchievementCelebration,
} from './content';

// Recommendation Agent - Personalized Content
export {
    rankFeed,
    suggestFriends,
    recommendGames,
} from './recommendation';

// Streaming Agent - Live Content
export {
    enhanceStream,
    detectHighlights,
} from './streaming';

// Safety Agent - Content Moderation
export {
    moderateContent,
    analyzeBehavior,
} from './safety';

// Analytics Agent - User Insights
export {
    predictEngagement,
    analyzeTrends,
} from './analytics';

// Cognitive Agent - Advanced Bot AI
export {
    cognitivePlayFlow,
    AI_PERSONALITIES,
    getPersonalityById,
    getRandomPersonality,
} from './cognitive';
