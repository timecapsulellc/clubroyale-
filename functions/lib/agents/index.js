"use strict";
/**
 * ClubRoyale AI Agents - Master Export
 *
 * Central export for all AI agent Cloud Functions
 * Total: 12 Specialized AI Agents
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRandomPersonality = exports.getPersonalityById = exports.AI_PERSONALITIES = exports.cognitivePlayFlow = exports.analyzeTrends = exports.predictEngagement = exports.analyzeBehavior = exports.moderateContent = exports.detectHighlights = exports.enhanceStream = exports.recommendGames = exports.suggestFriends = exports.rankFeed = exports.generateAchievementCelebration = exports.generateCaption = exports.generateReelScript = exports.generateStory = exports.planFeatureImplementation = exports.analyzeBug = exports.getArchitectureGuidance = exports.generateCode = void 0;
// IDE Guide Agent - Development Assistant
var ide_guide_1 = require("./ide_guide");
Object.defineProperty(exports, "generateCode", { enumerable: true, get: function () { return ide_guide_1.generateCode; } });
Object.defineProperty(exports, "getArchitectureGuidance", { enumerable: true, get: function () { return ide_guide_1.getArchitectureGuidance; } });
Object.defineProperty(exports, "analyzeBug", { enumerable: true, get: function () { return ide_guide_1.analyzeBug; } });
Object.defineProperty(exports, "planFeatureImplementation", { enumerable: true, get: function () { return ide_guide_1.planFeatureImplementation; } });
// Content Creator Agent - AI-Generated Content
var content_1 = require("./content");
Object.defineProperty(exports, "generateStory", { enumerable: true, get: function () { return content_1.generateStory; } });
Object.defineProperty(exports, "generateReelScript", { enumerable: true, get: function () { return content_1.generateReelScript; } });
Object.defineProperty(exports, "generateCaption", { enumerable: true, get: function () { return content_1.generateCaption; } });
Object.defineProperty(exports, "generateAchievementCelebration", { enumerable: true, get: function () { return content_1.generateAchievementCelebration; } });
// Recommendation Agent - Personalized Content
var recommendation_1 = require("./recommendation");
Object.defineProperty(exports, "rankFeed", { enumerable: true, get: function () { return recommendation_1.rankFeed; } });
Object.defineProperty(exports, "suggestFriends", { enumerable: true, get: function () { return recommendation_1.suggestFriends; } });
Object.defineProperty(exports, "recommendGames", { enumerable: true, get: function () { return recommendation_1.recommendGames; } });
// Streaming Agent - Live Content
var streaming_1 = require("./streaming");
Object.defineProperty(exports, "enhanceStream", { enumerable: true, get: function () { return streaming_1.enhanceStream; } });
Object.defineProperty(exports, "detectHighlights", { enumerable: true, get: function () { return streaming_1.detectHighlights; } });
// Safety Agent - Content Moderation
var safety_1 = require("./safety");
Object.defineProperty(exports, "moderateContent", { enumerable: true, get: function () { return safety_1.moderateContent; } });
Object.defineProperty(exports, "analyzeBehavior", { enumerable: true, get: function () { return safety_1.analyzeBehavior; } });
// Analytics Agent - User Insights
var analytics_1 = require("./analytics");
Object.defineProperty(exports, "predictEngagement", { enumerable: true, get: function () { return analytics_1.predictEngagement; } });
Object.defineProperty(exports, "analyzeTrends", { enumerable: true, get: function () { return analytics_1.analyzeTrends; } });
// Cognitive Agent - Advanced Bot AI
var cognitive_1 = require("./cognitive");
Object.defineProperty(exports, "cognitivePlayFlow", { enumerable: true, get: function () { return cognitive_1.cognitivePlayFlow; } });
Object.defineProperty(exports, "AI_PERSONALITIES", { enumerable: true, get: function () { return cognitive_1.AI_PERSONALITIES; } });
Object.defineProperty(exports, "getPersonalityById", { enumerable: true, get: function () { return cognitive_1.getPersonalityById; } });
Object.defineProperty(exports, "getRandomPersonality", { enumerable: true, get: function () { return cognitive_1.getRandomPersonality; } });
//# sourceMappingURL=index.js.map