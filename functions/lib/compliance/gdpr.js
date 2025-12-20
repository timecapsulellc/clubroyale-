"use strict";
/**
 * GDPR Compliance Utilities
 * Data export and deletion for user privacy
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
exports.exportUserData = exportUserData;
exports.deleteUserData = deleteUserData;
exports.updateConsent = updateConsent;
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../utils/logger");
const logger = (0, logger_1.createLogger)('gdpr');
/**
 * Export all user data (GDPR Article 15 & 20)
 */
async function exportUserData(userId) {
    const db = admin.firestore();
    logger.info(`Starting data export for user ${userId}`);
    const [profileDoc, walletDoc, gamesSnapshot, messagesSnapshot, friendsSnapshot, settingsDoc,] = await Promise.all([
        db.collection('users').doc(userId).get(),
        db.collection('wallets').doc(userId).get(),
        db.collection('games').where('playerIds', 'array-contains', userId).limit(100).get(),
        db.collection('messages').where('senderId', '==', userId).limit(500).get(),
        db.collection('friendships').where('userId', '==', userId).get(),
        db.collection('settings').doc(userId).get(),
    ]);
    const exportData = {
        exportedAt: new Date().toISOString(),
        userId,
        profile: profileDoc.exists ? profileDoc.data() || null : null,
        wallet: walletDoc.exists ? walletDoc.data() || null : null,
        games: gamesSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
        messages: messagesSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
        friends: friendsSnapshot.docs.map((doc) => doc.data().friendId),
        settings: settingsDoc.exists ? settingsDoc.data() || null : null,
    };
    // Remove sensitive fields
    if (exportData.profile) {
        delete exportData.profile.fcmToken;
        delete exportData.profile.deviceId;
    }
    logger.info(`Data export complete for user ${userId}`, {
        gamesCount: exportData.games.length,
        messagesCount: exportData.messages.length,
        friendsCount: exportData.friends.length,
    });
    return exportData;
}
/**
 * Delete all user data (GDPR Article 17 - Right to be Forgotten)
 */
async function deleteUserData(userId, options = {}) {
    const db = admin.firestore();
    const batch = db.batch();
    const deletedCollections = [];
    const errors = [];
    logger.info(`Starting data deletion for user ${userId}`);
    try {
        // Delete user profile
        batch.delete(db.collection('users').doc(userId));
        deletedCollections.push('users');
        // Delete wallet
        batch.delete(db.collection('wallets').doc(userId));
        deletedCollections.push('wallets');
        // Delete settings
        batch.delete(db.collection('settings').doc(userId));
        deletedCollections.push('settings');
        // Delete presence
        batch.delete(db.collection('presence').doc(userId));
        deletedCollections.push('presence');
        await batch.commit();
        // Delete messages (separate batches due to potential size)
        const messagesSnapshot = await db
            .collection('messages')
            .where('senderId', '==', userId)
            .get();
        if (!messagesSnapshot.empty) {
            const messageBatch = db.batch();
            messagesSnapshot.docs.forEach((doc) => {
                messageBatch.delete(doc.ref);
            });
            await messageBatch.commit();
            deletedCollections.push('messages');
        }
        // Delete friendships
        const friendsSnapshot = await db
            .collection('friendships')
            .where('userId', '==', userId)
            .get();
        if (!friendsSnapshot.empty) {
            const friendsBatch = db.batch();
            friendsSnapshot.docs.forEach((doc) => {
                friendsBatch.delete(doc.ref);
            });
            await friendsBatch.commit();
            deletedCollections.push('friendships');
        }
        // Anonymize game data instead of deleting (for game integrity)
        if (!options.keepAnonymizedGameData) {
            const gamesSnapshot = await db
                .collection('games')
                .where('playerIds', 'array-contains', userId)
                .get();
            for (const doc of gamesSnapshot.docs) {
                const gameData = doc.data();
                const updatedPlayerIds = gameData.playerIds.map((id) => id === userId ? 'deleted_user' : id);
                await doc.ref.update({
                    playerIds: updatedPlayerIds,
                    [`players.${userId}`]: admin.firestore.FieldValue.delete(),
                });
            }
            deletedCollections.push('games (anonymized)');
        }
        // Delete from Firebase Auth
        try {
            await admin.auth().deleteUser(userId);
            deletedCollections.push('auth');
        }
        catch (authError) {
            errors.push(`Auth deletion failed: ${authError.message}`);
        }
        logger.info(`Data deletion complete for user ${userId}`, {
            deletedCollections,
            errors,
        });
    }
    catch (error) {
        errors.push(`Batch deletion failed: ${error.message}`);
        logger.error(`Data deletion failed for user ${userId}`, error);
    }
    return { deletedCollections, errors };
}
/**
 * Update user consent preferences
 */
async function updateConsent(userId, consent) {
    const db = admin.firestore();
    await db.collection('users').doc(userId).update({
        consent,
        consentUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.info(`Consent updated for user ${userId}`, { consent });
}
exports.default = {
    exportUserData,
    deleteUserData,
    updateConsent,
};
//# sourceMappingURL=gdpr.js.map