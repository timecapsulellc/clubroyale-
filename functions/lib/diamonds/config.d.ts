/**
 * Diamond Economy V5 - Configuration & Types
 *
 * Central configuration for the diamond-only economy.
 * All diamond amounts, tier limits, and governance weights.
 */
export type UserTier = 'basic' | 'verified' | 'trusted' | 'leader' | 'ambassador';
export interface TierLimits {
    dailyEarningCap: number;
    dailyTransferLimit: number;
    dailyReceiveLimit: number;
    canTransfer: boolean;
    canCreateRooms: boolean;
    marketplaceAccess: boolean;
}
export declare const TIER_LIMITS: Record<UserTier, TierLimits>;
export type DiamondOrigin = 'purchase' | 'gameplayWin' | 'dailyLogin' | 'achievement' | 'referral' | 'p2pTransfer' | 'community' | 'adminGrant' | 'signupBonus';
export declare const ORIGIN_GOVERNANCE_WEIGHTS: Record<DiamondOrigin, number>;
export declare const DAILY_LOGIN_REWARD = 10;
export declare const LOGIN_STREAK_BONUSES: Record<number, number>;
export declare const GAMEPLAY_REWARDS: Record<string, number>;
export declare const TRANSFER_FEE_PERCENT = 0.05;
export declare const VERIFICATION_FEE = 100;
export interface VotingTier {
    minWeightedDiamonds: number;
    votes: number;
    name: string;
}
export declare const VOTING_TIERS: VotingTier[];
/**
 * Get the next login streak milestone
 */
export declare function getNextMilestone(currentStreak: number): number | null;
/**
 * Check if two dates are the same day
 */
export declare function isSameDay(date1: Date, date2: Date): boolean;
/**
 * Check if date1 is yesterday relative to date2
 */
export declare function isYesterday(date1: Date, date2: Date): boolean;
/**
 * Calculate days since a date
 */
export declare function daysSince(date: Date | undefined): number;
//# sourceMappingURL=config.d.ts.map