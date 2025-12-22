import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";

const db = getFirestore();

interface UserDataExport {
    exportedAt: string;
    userId: string;
    profile: Record<string, unknown> | null;
    wallet: Record<string, unknown> | null;
    transactions: Record<string, unknown>[];
    games: Record<string, unknown>[];
    friends: Record<string, unknown>[];
    achievements: Record<string, unknown>[];
    stories: Record<string, unknown>[];
    chats: Record<string, unknown>[];
    activities: Record<string, unknown>[];
}

/**
 * GDPR Data Export Function
 * 
 * Exports all user data in a portable JSON format as required by GDPR Article 20.
 * This allows users to download all their personal data from the platform.
 */
export const gdprExportUserData = onCall<void, Promise<UserDataExport>>(
    {
        region: "us-central1",
        memory: "512MiB",
        timeoutSeconds: 120,
    },
    async (request) => {
        // Verify authentication
        if (!request.auth) {
            throw new HttpsError("unauthenticated", "User must be authenticated");
        }

        const userId = request.auth.uid;
        console.log(`[GDPR Export] Starting export for user: ${userId}`);

        const exportData: UserDataExport = {
            exportedAt: new Date().toISOString(),
            userId: userId,
            profile: null,
            wallet: null,
            transactions: [],
            games: [],
            friends: [],
            achievements: [],
            stories: [],
            chats: [],
            activities: [],
        };

        try {
            // 1. Export User Profile
            const profileDoc = await db.collection("profiles").doc(userId).get();
            if (profileDoc.exists) {
                exportData.profile = profileDoc.data() || null;
            }

            // 2. Export Wallet Data
            const walletDoc = await db.collection("wallets").doc(userId).get();
            if (walletDoc.exists) {
                exportData.wallet = walletDoc.data() || null;
            }

            // 3. Export Transactions
            const transactionsSnap = await db
                .collection("transactions")
                .where("userId", "==", userId)
                .orderBy("createdAt", "desc")
                .limit(1000)
                .get();
            exportData.transactions = transactionsSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            // 4. Export Games (where user participated)
            const gamesSnap = await db
                .collection("games")
                .where("playerIds", "array-contains", userId)
                .orderBy("createdAt", "desc")
                .limit(500)
                .get();
            exportData.games = gamesSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            // 5. Export Friends
            const friendsSnap = await db
                .collection("users")
                .doc(userId)
                .collection("friends")
                .get();
            exportData.friends = friendsSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            // 6. Export Achievements
            const achievementsSnap = await db
                .collection("users")
                .doc(userId)
                .collection("achievements")
                .get();
            exportData.achievements = achievementsSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            // 7. Export Stories
            const storiesSnap = await db
                .collection("stories")
                .where("userId", "==", userId)
                .orderBy("createdAt", "desc")
                .limit(500)
                .get();
            exportData.stories = storiesSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            // 8. Export Chat Messages (user's messages only)
            // Note: We only export messages the user sent, not the full conversations
            const chatsSnap = await db
                .collectionGroup("messages")
                .where("senderId", "==", userId)
                .orderBy("timestamp", "desc")
                .limit(1000)
                .get();
            exportData.chats = chatsSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            // 9. Export Activities
            const activitiesSnap = await db
                .collection("activities")
                .where("userId", "==", userId)
                .orderBy("createdAt", "desc")
                .limit(500)
                .get();
            exportData.activities = activitiesSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data(),
            }));

            console.log(`[GDPR Export] Export complete for user: ${userId}`);
            console.log(`  - Transactions: ${exportData.transactions.length}`);
            console.log(`  - Games: ${exportData.games.length}`);
            console.log(`  - Friends: ${exportData.friends.length}`);
            console.log(`  - Stories: ${exportData.stories.length}`);

            return exportData;
        } catch (error) {
            console.error(`[GDPR Export] Error exporting data for ${userId}:`, error);
            throw new HttpsError(
                "internal",
                "Failed to export user data. Please try again later."
            );
        }
    }
);
