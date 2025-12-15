"use strict";
/**
 * User Verification Upgrade
 *
 * Upgrades a user from 'Basic' to 'Verified'.
 * - Costs 100 diamonds (one-time fee)
 * - Requires prerequisite checks (phone verification)
 * - Burns the fee
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
exports.upgradeToVerified = void 0;
const https_1 = require("firebase-functions/v2/https");
const admin = __importStar(require("firebase-admin"));
const config_1 = require("./config");
const utils_1 = require("./utils");
const firestore = admin.firestore();
exports.upgradeToVerified = (0, https_1.onCall)(async (request) => {
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'Must be logged in');
    }
    const user = await (0, utils_1.getUser)(userId);
    // Check if already verified or higher
    const currentTier = user.tier || 'basic';
    if (currentTier !== 'basic') {
        throw new https_1.HttpsError('already-exists', `Already ${currentTier}. Verification is only for Basic users.`);
    }
    // Check balance
    if ((user.diamondBalance || 0) < config_1.VERIFICATION_FEE) {
        throw new https_1.HttpsError('failed-precondition', `Insufficient diamonds. Need ${config_1.VERIFICATION_FEE}💎 for verification.`);
    }
    // Prerequisites check
    // Assumption: phoneVerified is set on the user profile upon auth
    // If not present, we assume false. Admin can override or auth flow sets it.
    if (!user.phoneNumber && !user.phoneVerified) {
        throw new https_1.HttpsError('failed-precondition', 'Phone verification required before upgrading.');
    }
    // Deduct fee and upgrade
    await firestore.runTransaction(async (transaction) => {
        const userRef = firestore.collection('users').doc(userId);
        // 1. Burn fee
        // We update balance and origin tracking.
        // Spec says fee is burned. We treat it as spending, but we also record a specific burn ledger entry.
        transaction.update(userRef, {
            diamondBalance: admin.firestore.FieldValue.increment(-config_1.VERIFICATION_FEE),
            'diamondsByOrigin.spent': admin.firestore.FieldValue.increment(config_1.VERIFICATION_FEE),
            tier: 'verified',
            verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // 2. Record burn in ledger
        const burnRef = firestore.collection('diamond_ledger').doc();
        transaction.set(burnRef, {
            type: 'burn',
            fromUserId: userId,
            toUserId: null,
            amount: config_1.VERIFICATION_FEE,
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
    }
    catch (e) {
        console.error("Failed to send verification notification", e);
    }
    return {
        success: true,
        newTier: 'verified',
        feePaid: config_1.VERIFICATION_FEE,
        newLimits: config_1.TIER_LIMITS['verified'],
    };
});
//# sourceMappingURL=upgradeToVerified.js.map