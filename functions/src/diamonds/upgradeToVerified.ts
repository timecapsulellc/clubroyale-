/**
 * User Verification Upgrade
 * 
 * Upgrades a user from 'Basic' to 'Verified'.
 * - Costs 100 diamonds (one-time fee)
 * - Requires prerequisite checks (phone verification)
 * - Burns the fee
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { VERIFICATION_FEE, TIER_LIMITS } from './config';
import { getUser } from './utils';

const firestore = admin.firestore();

export const upgradeToVerified = onCall(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new HttpsError('unauthenticated', 'Must be logged in');
    }

    const user = await getUser(userId);

    // Check if already verified or higher
    const currentTier = user.tier || 'basic';
    if (currentTier !== 'basic') {
        throw new HttpsError(
            'already-exists',
            `Already ${currentTier}. Verification is only for Basic users.`
        );
    }

    // Check balance
    if ((user.diamondBalance || 0) < VERIFICATION_FEE) {
        throw new HttpsError(
            'failed-precondition',
            `Insufficient diamonds. Need ${VERIFICATION_FEE}💎 for verification.`
        );
    }

    // Prerequisites check
    // Assumption: phoneVerified is set on the user profile upon auth
    // If not present, we assume false. Admin can override or auth flow sets it.
    if (!user.phoneNumber && !user.phoneVerified) {
        throw new HttpsError(
            'failed-precondition',
            'Phone verification required before upgrading.'
        );
    }

    // Deduct fee and upgrade
    await firestore.runTransaction(async (transaction) => {
        const userRef = firestore.collection('users').doc(userId);

        // 1. Burn fee
        // We update balance and origin tracking.
        // Spec says fee is burned. We treat it as spending, but we also record a specific burn ledger entry.
        transaction.update(userRef, {
            diamondBalance: admin.firestore.FieldValue.increment(-VERIFICATION_FEE),
            'diamondsByOrigin.spent': admin.firestore.FieldValue.increment(VERIFICATION_FEE),
            tier: 'verified',
            verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // 2. Record burn in ledger
        const burnRef = firestore.collection('diamond_ledger').doc();
        transaction.set(burnRef, {
            type: 'burn',
            fromUserId: userId,
            toUserId: null,
            amount: VERIFICATION_FEE,
            origin: 'verificationFee',
            reason: 'Account verification fee (one-time)',
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
    });

    // Try notify user (fire and forget)
    try {
        await admin.messaging().send({
            topic: `user_${userId}`,
            notification: {
                title: '✅ Account Verified!',
                body: 'You can now transfer diamonds and access the marketplace!',
            },
        });
    } catch (e) {
        console.error("Failed to send verification notification", e);
    }

    return {
        success: true,
        newTier: 'verified',
        feePaid: VERIFICATION_FEE,
        newLimits: TIER_LIMITS['verified'],
    };
});
