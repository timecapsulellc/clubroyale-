/**
 * Daily Login Bonus
 * 
 * Grants daily rewards with streak bonuses.
 * - Tracks consecutive login days
 * - Resets streak on missed days
 * - Awards milestone bonuses
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { DAILY_LOGIN_REWARD, LOGIN_STREAK_BONUSES, getNextMilestone, isSameDay, isYesterday } from './config';
import { grantDiamondsToUser, getUser } from './utils';

// Lazy initialization
const getDb = () => admin.firestore();

interface DailyLoginResponse {
    success: boolean;
    earned: number;
    baseReward: number;
    milestoneBonus: number;
    currentStreak: number;
    nextMilestone: number | null;
}

export const claimDailyLogin = onCall(async (request): Promise<DailyLoginResponse> => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'Must be logged in');
    }

    const user = await getUser(userId);
    const now = new Date();
    // Helper to safely convert Firestore Timestamp or string/number to Date
    const toDate = (ts: any) => ts && typeof ts.toDate === 'function' ? ts.toDate() : (ts ? new Date(ts) : null);

    const lastClaim = toDate(user.lastDailyLoginClaim);

    // Check if already claimed today
    if (lastClaim && isSameDay(lastClaim, now)) {
        throw new HttpsError(
            'already-exists',
            'Daily login already claimed today'
        );
    }

    // Calculate streak
    let streakDays = user.loginStreak || 0;

    if (lastClaim && isYesterday(lastClaim, now)) {
        // Consecutive day
        streakDays += 1;
    } else if (!lastClaim || !isSameDay(lastClaim, now)) {
        streakDays = 1; // Streak reset
    }

    // Base reward
    let reward = DAILY_LOGIN_REWARD;

    // Streak milestone bonus
    const milestoneBonus = LOGIN_STREAK_BONUSES[streakDays] || 0;
    reward += milestoneBonus;

    // Grant diamonds
    const reason = milestoneBonus > 0
        ? `Day ${streakDays} login + Streak Bonus!`
        : `Day ${streakDays} login`;

    await grantDiamondsToUser(userId, reward, 'dailyLogin', reason);

    // Update user streak data
    await getDb().collection('users').doc(userId).update({
        loginStreak: streakDays,
        lastDailyLoginClaim: admin.firestore.FieldValue.serverTimestamp(),
        lastActive: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
        success: true,
        earned: reward,
        baseReward: DAILY_LOGIN_REWARD,
        milestoneBonus: milestoneBonus,
        currentStreak: streakDays,
        nextMilestone: getNextMilestone(streakDays),
    };
});
