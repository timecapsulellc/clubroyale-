"use strict";
/**
 * Daily Login Bonus
 *
 * Grants daily rewards with streak bonuses.
 * - Tracks consecutive login days
 * - Resets streak on missed days
 * - Awards milestone bonuses
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.claimDailyLogin = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const config_1 = require("./config");
const utils_1 = require("./utils");
const firestore = admin.firestore();
exports.claimDailyLogin = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'Must be logged in');
    }
    const user = await (0, utils_1.getUser)(userId);
    const now = new Date();
    // Helper to safely convert Firestore Timestamp or string/number to Date
    const toDate = (ts) => ts && typeof ts.toDate === 'function' ? ts.toDate() : (ts ? new Date(ts) : null);
    const lastClaim = toDate(user.lastDailyLoginClaim);
    // Check if already claimed today
    if (lastClaim && (0, config_1.isSameDay)(lastClaim, now)) {
        throw new https_1.HttpsError('already-exists', 'Daily login already claimed today');
    }
    // Calculate streak
    let streakDays = user.loginStreak || 0;
    if (lastClaim && (0, config_1.isYesterday)(lastClaim, now)) {
        // Consecutive day
        streakDays += 1;
    }
    else if (!lastClaim || !(0, config_1.isSameDay)(lastClaim, now)) {
        streakDays = 1; // Streak reset
    }
    // Base reward
    let reward = config_1.DAILY_LOGIN_REWARD;
    // Streak milestone bonus
    const milestoneBonus = config_1.LOGIN_STREAK_BONUSES[streakDays] || 0;
    reward += milestoneBonus;
    // Grant diamonds
    const reason = milestoneBonus > 0
        ? `Day ${streakDays} login + Streak Bonus!`
        : `Day ${streakDays} login`;
    await (0, utils_1.grantDiamondsToUser)(userId, reward, 'dailyLogin', reason);
    // Update user streak data
    await firestore.collection('users').doc(userId).update({
        loginStreak: streakDays,
        lastDailyLoginClaim: admin.firestore.FieldValue.serverTimestamp(),
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
    });
    return {
        success: true,
        earned: reward,
        baseReward: config_1.DAILY_LOGIN_REWARD,
        milestoneBonus: milestoneBonus,
        currentStreak: streakDays,
        nextMilestone: (0, config_1.getNextMilestone)(streakDays),
    };
});
//# sourceMappingURL=claimDailyLogin.js.map