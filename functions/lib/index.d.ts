/**
 * TaasClub - Cloud Functions with Genkit AI
 *
 * Main entry point for all Cloud Functions including:
 * - Anti-cheat validation (existing)
 * - AI-powered game features (Genkit)
 * - Push notifications (FCM)
 */
export { auditGameUpdate } from './triggers/auditTriggers';
export { onSocialMessageSent, onStoryCreated, onFriendRequestCreated, onFriendshipUpdated, onVoiceRoomCreated } from './triggers/social';
export { generateLiveKitToken, validateSpectatorAccess } from './livekit/tokenService';
export { validateTransfer } from './diamonds/validateTransfer';
export { grantGameplayReward } from './diamonds/grantGameplayReward';
export { claimDailyLogin } from './diamonds/claimDailyLogin';
export { upgradeToVerified } from './diamonds/upgradeToVerified';
export { checkTierUpgrade, monitorDiamondSupply } from './diamonds/scheduled';
export { onGrantApproved, executeCooledGrants, notifyAdminNewChat } from './admin/diamondAdmin';
export { weeklyTasks, dailyCleanup } from './scheduled/dailyTasks';
export { seedBotRoomsScheduled, seedBotRoomsManual, cleanupAllWaitingRooms } from './scheduled/botRoomSeeder';
export { generateCode, getArchitectureGuidance, analyzeBug, planFeatureImplementation, generateStory, generateReelScript, generateCaption, generateAchievementCelebration, rankFeed, suggestFriends, recommendGames, enhanceStream, detectHighlights, moderateContent, analyzeBehavior, predictEngagement, analyzeTrends, } from './agents';
export { grantSocialRewardFunction, processVoiceRoomTip, calculateWeeklyEngagement, calculateMonthlyMilestones } from './rewards/social';
/**
 * Process settlement after game ends
 * UPDATED for Diamond Economy V5: Uses 'users' collection instead of 'wallets'
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