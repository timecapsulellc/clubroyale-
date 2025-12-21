import * as admin from 'firebase-admin';

// Initialize with default credentials
// In a local environment with firebase-tools logged in, this often works.
// If valid credentials aren't found, we might need to rely on 'firebase emulators:exec' or similar,
// but let's try direct connection first as it's often fastest for dev envs.
if (!admin.apps.length) {
    admin.initializeApp({
        projectId: 'clubroyale-app' // Explicitly set if needed, but auto-discovery is best
    });
}

const db = admin.firestore();

const USER_ID = 'JXOnz8O8JvTzR9zQCGu0Y68b7It1';
const AMOUNT = 1000;

async function seedWallet() {
    console.log(`Seeding wallet for user ${USER_ID} with ${AMOUNT} diamonds...`);

    const walletRef = db.collection('wallets').doc(USER_ID);

    try {
        // Check if wallet exists
        const doc = await walletRef.get();

        if (!doc.exists) {
            console.log('Wallet does not exist. Creating...');
            await walletRef.set({
                balance: AMOUNT,
                totalPurchased: 0,
                lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
        } else {
            const currentBalance = doc.data()?.balance || 0;
            console.log(`Wallet exists. Current balance: ${currentBalance}. Adding ${AMOUNT}...`);
            await walletRef.update({
                balance: admin.firestore.FieldValue.increment(AMOUNT),
                lastUpdated: admin.firestore.FieldValue.serverTimestamp()
            });
        }

        console.log('Wallet seeded successfully!');
    } catch (error) {
        console.error('Error seeding wallet:', error);
        process.exit(1);
    }
    process.exit(0);
}

seedWallet().catch(console.error);
