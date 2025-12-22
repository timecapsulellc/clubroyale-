import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, DocumentData } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

interface DeletionResult {
    success: boolean;
    deletedAt: string;
    userId: string;
    deletedCollections: string[];
    errors: string[];
}

/**
 * GDPR Data Deletion Function (Right to be Forgotten)
 * 
 * Deletes all user data across all collections as required by GDPR Article 17.
 */
export const gdprDeleteUserData = onCall<
    { confirmDelete: boolean },
    Promise<DeletionResult>
>(
    {
        region: "us-central1",
        memory: "512MiB",
        timeoutSeconds: 300,
    },
    async (request) => {
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        const userId = request.auth.uid;
        const { confirmDelete } = request.data;

        if (!confirmDelete) {
            throw new HttpsError(
                "failed-precondition",
                "Deletion must be explicitly confirmed by setting confirmDelete: true"
            );
        }

        const db = getFirestore();
        const auth = getAuth();
        console.log(`[GDPR Delete] Starting deletion for user: ${userId}`);

        const result: DeletionResult = {
            success: false,
            deletedAt: new Date().toISOString(),
            userId: userId,
            deletedCollections: [],
            errors: [],
        };

        const batch = db.batch();
        let operationCount = 0;
        const MAX_BATCH_SIZE = 400;

        const commitBatchIfNeeded = async () => {
            if (operationCount > 0) {
                await batch.commit();
                operationCount = 0;
            }
        };

        try {
            // 1. Delete User Profile
            try {
                const profileRef = db.collection("profiles").doc(userId);
                batch.delete(profileRef);
                operationCount++;
                result.deletedCollections.push("profiles");
            } catch (e) {
                result.errors.push(`profiles: ${e}`);
            }

            // 2. Delete User document
            try {
                const userRef = db.collection("users").doc(userId);

                const friendsSnap = await userRef.collection("friends").get();
                for (const doc of friendsSnap.docs) {
                    batch.delete(doc.ref);
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }

                const achievementsSnap = await userRef.collection("achievements").get();
                for (const doc of achievementsSnap.docs) {
                    batch.delete(doc.ref);
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }

                const transactionsSnap = await userRef.collection("transactions").get();
                for (const doc of transactionsSnap.docs) {
                    batch.delete(doc.ref);
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }

                batch.delete(userRef);
                operationCount++;
                result.deletedCollections.push("users");
            } catch (e) {
                result.errors.push(`users: ${e}`);
            }

            // 3. Delete Wallet
            try {
                const walletRef = db.collection("wallets").doc(userId);
                batch.delete(walletRef);
                operationCount++;
                result.deletedCollections.push("wallets");
            } catch (e) {
                result.errors.push(`wallets: ${e}`);
            }

            // 4. Delete Stories
            try {
                const storiesSnap = await db
                    .collection("stories")
                    .where("userId", "==", userId)
                    .get();
                for (const doc of storiesSnap.docs) {
                    batch.delete(doc.ref);
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }
                result.deletedCollections.push("stories");
            } catch (e) {
                result.errors.push(`stories: ${e}`);
            }

            // 5. Delete Activities
            try {
                const activitiesSnap = await db
                    .collection("activities")
                    .where("userId", "==", userId)
                    .get();
                for (const doc of activitiesSnap.docs) {
                    batch.delete(doc.ref);
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }
                result.deletedCollections.push("activities");
            } catch (e) {
                result.errors.push(`activities: ${e}`);
            }

            // 6. Delete Presence
            try {
                const presenceRef = db.collection("presence").doc(userId);
                batch.delete(presenceRef);
                operationCount++;
                result.deletedCollections.push("presence");
            } catch (e) {
                result.errors.push(`presence: ${e}`);
            }

            // 7. Anonymize games
            try {
                const gamesSnap = await db
                    .collection("games")
                    .where("playerIds", "array-contains", userId)
                    .get();
                for (const doc of gamesSnap.docs) {
                    batch.update(doc.ref, {
                        playerIds: FieldValue.arrayRemove(userId),
                        [`playerData.${userId}`]: FieldValue.delete(),
                    });
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }
                result.deletedCollections.push("games (anonymized)");
            } catch (e) {
                result.errors.push(`games: ${e}`);
            }

            // 8. Delete Feed items
            try {
                const feedSnap = await db
                    .collection("feeds")
                    .doc(userId)
                    .collection("items")
                    .get();
                for (const doc of feedSnap.docs) {
                    batch.delete(doc.ref);
                    operationCount++;
                    if (operationCount >= MAX_BATCH_SIZE) await commitBatchIfNeeded();
                }
                const feedRef = db.collection("feeds").doc(userId);
                batch.delete(feedRef);
                operationCount++;
                result.deletedCollections.push("feeds");
            } catch (e) {
                result.errors.push(`feeds: ${e}`);
            }

            await commitBatchIfNeeded();

            // 9. Delete Firebase Auth user
            try {
                await auth.deleteUser(userId);
                result.deletedCollections.push("auth");
            } catch (e) {
                result.errors.push(`auth: ${e}`);
            }

            // 10. Create audit log
            await db.collection("audit_logs").add({
                action: "GDPR_DELETION",
                userId: userId,
                timestamp: FieldValue.serverTimestamp(),
                deletedCollections: result.deletedCollections,
                errors: result.errors,
            });

            result.success = result.errors.length === 0;
            console.log(`[GDPR Delete] Deletion complete for user: ${userId}`);
            return result;
        } catch (error) {
            console.error(`[GDPR Delete] Critical error for ${userId}:`, error);
            result.errors.push(`Critical: ${error}`);
            return result;
        }
    }
);
