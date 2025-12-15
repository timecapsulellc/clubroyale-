"use strict";
/**
 * Diamond Economy V5 - Configuration & Types
 *
 * Central configuration for the diamond-only economy.
 * All diamond amounts, tier limits, and governance weights.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.VOTING_TIERS = exports.VERIFICATION_FEE = exports.TRANSFER_FEE_PERCENT = exports.GAMEPLAY_REWARDS = exports.LOGIN_STREAK_BONUSES = exports.DAILY_LOGIN_REWARD = exports.ORIGIN_GOVERNANCE_WEIGHTS = exports.TIER_LIMITS = void 0;
exports.getNextMilestone = getNextMilestone;
exports.isSameDay = isSameDay;
exports.isYesterday = isYesterday;
exports.daysSince = daysSince;
exports.TIER_LIMITS = {
    basic: {
        dailyEarningCap: 200,
        dailyTransferLimit: 0, // Cannot transfer
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
        dailyEarningCap: -1, // Unlimited
        dailyTransferLimit: 25000,
        dailyReceiveLimit: 50000,
        canTransfer: true,
        canCreateRooms: true,
        marketplaceAccess: true,
    },
    ambassador: {
        dailyEarningCap: -1,
        dailyTransferLimit: -1, // Unlimited
        dailyReceiveLimit: -1,
        canTransfer: true,
        canCreateRooms: true,
        marketplaceAccess: true,
    },
};
// Governance weight multipliers (earned = more weight)
exports.ORIGIN_GOVERNANCE_WEIGHTS = {
    purchase: 1.0, // Base weight
    gameplayWin: 1.5, // Earned through skill
    dailyLogin: 1.2, // Active player
    achievement: 1.5, // Dedicated player
    referral: 1.3, // Growing community
    p2pTransfer: 0.5, // Received diamonds worth less
    community: 1.4, // Community contributor
    adminGrant: 0.8, // Special grants
    signupBonus: 0.8, // Starter diamonds
};
// ============ REWARD AMOUNTS ============
exports.DAILY_LOGIN_REWARD = 10;
exports.LOGIN_STREAK_BONUSES = {
    7: 25, // Week streak
    14: 50, // 2 week streak
    30: 100, // Month streak
    60: 200, // 2 month streak
    90: 500, // Quarter streak
    365: 1000, // Year streak
};
exports.GAMEPLAY_REWARDS = {
    'callbreak_win': 15,
    'callbreak_draw': 5,
    'teenPatti_win': 20,
    'teenPatti_showdown': 10,
    'inBetween_win': 15,
    'marriage_win': 25,
    'marriage_marriage': 50, // Getting a marriage
};
// ============ ECONOMIC CONSTANTS ============
exports.TRANSFER_FEE_PERCENT = 0.05; // 5% burn
exports.VERIFICATION_FEE = 100; // One-time fee to verify
exports.VOTING_TIERS = [
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
function getNextMilestone(currentStreak) {
    const milestones = Object.keys(exports.LOGIN_STREAK_BONUSES)
        .map(Number)
        .sort((a, b) => a - b);
    for (const milestone of milestones) {
        if (milestone > currentStreak)
            return milestone;
    }
    return null;
}
/**
 * Check if two dates are the same day
 */
function isSameDay(date1, date2) {
    return date1.getFullYear() === date2.getFullYear() &&
        date1.getMonth() === date2.getMonth() &&
        date1.getDate() === date2.getDate();
}
/**
 * Check if date1 is yesterday relative to date2
 */
function isYesterday(date1, date2) {
    const yesterday = new Date(date2);
    yesterday.setDate(yesterday.getDate() - 1);
    return isSameDay(date1, yesterday);
}
/**
 * Calculate days since a date
 */
function daysSince(date) {
    if (!date)
        return 0;
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
}
//# sourceMappingURL=config.js.map