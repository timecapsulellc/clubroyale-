/**
 * GDPR Compliance Utilities
 * Data export and deletion for user privacy
 */

import * as admin from 'firebase-admin';
import { createLogger } from '../utils/logger';

const logger = createLogger('gdpr');

interface UserDataExport {
    exportedAt: string;
    userId: string;
    profile: Record<string, unknown> | null;
    wallet: Record<string, unknown> | null;
    games: Record<string, unknown>[];
    messages: Record<string, unknown>[];
    friends: string[];
    settings: Record<string, unknown> | null;
}

/**
 * Export all user data (GDPR Article 15 & 20)
 */
export async function exportUserData(userId: string): Promise<UserDataExport> {
    const db = admin.firestore();
    logger.info(`Starting data export for user ${userId}`);

    const [
        profileDoc,
        walletDoc,
        gamesSnapshot,
        messagesSnapshot,
        friendsSnapshot,
        settingsDoc,
    ] = await Promise.all([
        db.collection('users').doc(userId).get(),
        db.collection('wallets').doc(userId).get(),
        db.collection('games').where('playerIds', 'array-contains', userId).limit(100).get(),
        db.collection('messages').where('senderId', '==', userId).limit(500).get(),
        db.collection('friendships').where('userId', '==', userId).get(),
        db.collection('settings').doc(userId).get(),
    ]);

    const exportData: UserDataExport = {
        exportedAt: new Date().toISOString(),
        userId,
        profile: profileDoc.exists ? profileDoc.data() || null : null,
        wallet: walletDoc.exists ? walletDoc.data() || null : null,
        games: gamesSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
        messages: messagesSnapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() })),
        friends: friendsSnapshot.docs.map((doc) => doc.data().friendId as string),
        settings: settingsDoc.exists ? settingsDoc.data() || null : null,
    };

    // Remove sensitive fields
    if (exportData.profile) {
        delete (exportData.profile as any).fcmToken;
        delete (exportData.profile as any).deviceId;
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
export async function deleteUserData(
    userId: string,
    options: { keepAnonymizedGameData?: boolean } = {}
): Promise<{ deletedCollections: string[]; errors: string[] }> {
    const db = admin.firestore();
    const batch = db.batch();
    const deletedCollections: string[] = [];
    const errors: string[] = [];

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
                const updatedPlayerIds = (gameData.playerIds as string[]).map((id) =>
                    id === userId ? 'deleted_user' : id
                );
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
        } catch (authError) {
            errors.push(`Auth deletion failed: ${(authError as Error).message}`);
        }

        logger.info(`Data deletion complete for user ${userId}`, {
            deletedCollections,
            errors,
        });
    } catch (error) {
        errors.push(`Batch deletion failed: ${(error as Error).message}`);
        logger.error(`Data deletion failed for user ${userId}`, error as Error);
    }

    return { deletedCollections, errors };
}

/**
 * Update user consent preferences
 */
export async function updateConsent(
    userId: string,
    consent: {
        analytics: boolean;
        marketing: boolean;
        thirdParty: boolean;
    }
): Promise<void> {
    const db = admin.firestore();

    await db.collection('users').doc(userId).update({
        consent,
        consentUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    logger.info(`Consent updated for user ${userId}`, { consent });
}

export default {
    exportUserData,
    deleteUserData,
    updateConsent,
};
