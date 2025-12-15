/**
 * Diamond Economy V5 - Configuration & Types
 * 
 * Central configuration for the diamond-only economy.
 * All diamond amounts, tier limits, and governance weights.
 */

// ============ USER TIERS ============

export type UserTier = 'basic' | 'verified' | 'trusted' | 'leader' | 'ambassador';

export interface TierLimits {
    dailyEarningCap: number;      // -1 = unlimited
    dailyTransferLimit: number;   // -1 = unlimited
    dailyReceiveLimit: number;    // -1 = unlimited
    canTransfer: boolean;
    canCreateRooms: boolean;
    marketplaceAccess: boolean;
}

export const TIER_LIMITS: Record<UserTier, TierLimits> = {
    basic: {
        dailyEarningCap: 200,
        dailyTransferLimit: 0,      // Cannot transfer
        dailyReceiveLimit: 100,
        canTransfer: false,
        canCreateRooms: true,
        marketplaceAccess: false,
    },
    verified: {
        dailyEarningCap: 500,
        dailyTransferLimit: 1000,
        dailyReceiveLimit: 2000,
        canTransfer: true,
        canCreateRooms: true,
        marketplaceAccess: true,
    },
    trusted: {
        dailyEarningCap: 1000,
        dailyTransferLimit: 5000,
        dailyReceiveLimit: 10000,
        canTransfer: true,
        canCreateRooms: true,
        marketplaceAccess: true,
    },
    leader: {
        dailyEarningCap: -1,        // Unlimited
        dailyTransferLimit: 25000,
        dailyReceiveLimit: 50000,
        canTransfer: true,
        canCreateRooms: true,
        marketplaceAccess: true,
    },
    ambassador: {
        dailyEarningCap: -1,
        dailyTransferLimit: -1,     // Unlimited
        dailyReceiveLimit: -1,
        canTransfer: true,
        canCreateRooms: true,
        marketplaceAccess: true,
    },
};

// ============ DIAMOND ORIGINS ============

export type DiamondOrigin =
    | 'purchase'      // Bought with real money (offline)
    | 'gameplayWin'   // Won in games
    | 'dailyLogin'    // Daily login rewards
    | 'achievement'   // Achievement rewards
    | 'referral'      // Referral bonuses
    | 'p2pTransfer'   // Received from other users
    | 'community'     // Community pool rewards
    | 'adminGrant'    // Admin granted (special cases)
    | 'signupBonus';  // Initial signup bonus

// Governance weight multipliers (earned = more weight)
export const ORIGIN_GOVERNANCE_WEIGHTS: Record<DiamondOrigin, number> = {
    purchase: 1.0,       // Base weight
    gameplayWin: 1.5,    // Earned through skill
    dailyLogin: 1.2,     // Active player
    achievement: 1.5,    // Dedicated player
    referral: 1.3,       // Growing community
    p2pTransfer: 0.5,    // Received diamonds worth less
    community: 1.4,      // Community contributor
    adminGrant: 0.8,     // Special grants
    signupBonus: 0.8,    // Starter diamonds
};

// ============ REWARD AMOUNTS ============

export const DAILY_LOGIN_REWARD = 10;

export const LOGIN_STREAK_BONUSES: Record<number, number> = {
    7: 25,     // Week streak
    14: 50,    // 2 week streak
    30: 100,   // Month streak
    60: 200,   // 2 month streak
    90: 500,   // Quarter streak
    365: 1000, // Year streak
};

export const GAMEPLAY_REWARDS: Record<string, number> = {
    'callbreak_win': 15,
    'callbreak_draw': 5,
    'teenPatti_win': 20,
    'teenPatti_showdown': 10,
    'inBetween_win': 15,
    'marriage_win': 25,
    'marriage_marriage': 50,  // Getting a marriage
};

// ============ ECONOMIC CONSTANTS ============

export const TRANSFER_FEE_PERCENT = 0.05;  // 5% burn
export const VERIFICATION_FEE = 100;       // One-time fee to verify

// ============ VOTING POWER TIERS ============

export interface VotingTier {
    minWeightedDiamonds: number;
    votes: number;
    name: string;
}

export const VOTING_TIERS: VotingTier[] = [
    { minWeightedDiamonds: 100000, votes: 25, name: '💎 Diamond Council' },
    { minWeightedDiamonds: 50000, votes: 15, name: '👑 Platinum Member' },
    { minWeightedDiamonds: 20000, votes: 10, name: '⭐ Gold Member' },
    { minWeightedDiamonds: 5000, votes: 5, name: '🥈 Silver Member' },
    { minWeightedDiamonds: 1000, votes: 2, name: '🥉 Bronze Member' },
    { minWeightedDiamonds: 100, votes: 1, name: '🟢 Active Member' },
];

// ============ HELPER FUNCTIONS ============

/**
 * Get the next login streak milestone
 */
export function getNextMilestone(currentStreak: number): number | null {
    const milestones = Object.keys(LOGIN_STREAK_BONUSES)
        .map(Number)
        .sort((a, b) => a - b);

    for (const milestone of milestones) {
        if (milestone > currentStreak) return milestone;
    }
    return null;
}

/**
 * Check if two dates are the same day
 */
export function isSameDay(date1: Date, date2: Date): boolean {
    return date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate();
}

/**
 * Check if date1 is yesterday relative to date2
 */
export function isYesterday(date1: Date, date2: Date): boolean {
    const yesterday = new Date(date2);
    yesterday.setDate(yesterday.getDate() - 1);
    return isSameDay(date1, yesterday);
}

/**
 * Calculate days since a date
 */
export function daysSince(date: Date | undefined): number {
    if (!date) return 0;
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}
