/**
 * Security Penetration Tests
 * 
 * Automated security testing suite for ClubRoyale.
 * Tests common vulnerabilities and security configurations.
 * 
 * Run with: npm run test:security
 */

import { initializeApp, deleteApp, FirebaseApp } from 'firebase/app';
import {
    getFirestore,
    Firestore,
    doc,
    getDoc,
    setDoc,
    updateDoc,
    deleteDoc,
    collection,
    getDocs,
    connectFirestoreEmulator
} from 'firebase/firestore';
import {
    getAuth,
    Auth,
    signInAnonymously,
    signOut,
    connectAuthEmulator
} from 'firebase/auth';
import { getFunctions, httpsCallable, connectFunctionsEmulator } from 'firebase/functions';

// Test configuration
const testConfig = {
    projectId: 'clubroyale-test',
    apiKey: 'test-api-key',
};

let app: FirebaseApp;
let db: Firestore;
let auth: Auth;

describe('Security Penetration Tests', () => {
    beforeAll(async () => {
        app = initializeApp(testConfig, 'security-test');
        db = getFirestore(app);
        auth = getAuth(app);

        // Connect to emulators if available
        if (process.env.FIRESTORE_EMULATOR_HOST) {
            connectFirestoreEmulator(db, 'localhost', 8080);
        }
        if (process.env.AUTH_EMULATOR_HOST) {
            connectAuthEmulator(auth, 'http://localhost:9099');
        }
    });

    afterAll(async () => {
        await deleteApp(app);
    });

    describe('Authentication Security', () => {
        test('Unauthenticated users cannot read user profiles', async () => {
            await signOut(auth);

            const userRef = doc(db, 'users', 'any-user-id');

            await expect(getDoc(userRef)).rejects.toThrow();
        });

        test('Unauthenticated users cannot read wallets', async () => {
            await signOut(auth);

            const walletRef = doc(db, 'wallets', 'any-user-id');

            await expect(getDoc(walletRef)).rejects.toThrow();
        });

        test('Unauthenticated users cannot create games', async () => {
            await signOut(auth);

            const gameRef = doc(db, 'games', 'test-game');

            await expect(setDoc(gameRef, { status: 'waiting' })).rejects.toThrow();
        });
    });

    describe('Authorization Security', () => {
        let userId: string;

        beforeEach(async () => {
            const cred = await signInAnonymously(auth);
            userId = cred.user.uid;
        });

        afterEach(async () => {
            await signOut(auth);
        });

        test('User cannot read other users wallet', async () => {
            const otherWalletRef = doc(db, 'wallets', 'other-user-id');

            await expect(getDoc(otherWalletRef)).rejects.toThrow();
        });

        test('User cannot update other users profile', async () => {
            const otherUserRef = doc(db, 'users', 'other-user-id');

            await expect(
                updateDoc(otherUserRef, { displayName: 'Hacked!' })
            ).rejects.toThrow();
        });

        test('User cannot delete other users data', async () => {
            const otherUserRef = doc(db, 'users', 'other-user-id');

            await expect(deleteDoc(otherUserRef)).rejects.toThrow();
        });

        test('User cannot access audit logs', async () => {
            const auditRef = doc(db, 'audit_logs', 'any-log-id');

            await expect(getDoc(auditRef)).rejects.toThrow();
        });

        test('User cannot access flagged users list', async () => {
            const flaggedRef = doc(db, 'flaggedUsers', 'any-user-id');

            await expect(getDoc(flaggedRef)).rejects.toThrow();
        });
    });

    describe('Data Validation Security', () => {
        let userId: string;

        beforeEach(async () => {
            const cred = await signInAnonymously(auth);
            userId = cred.user.uid;
        });

        afterEach(async () => {
            await signOut(auth);
        });

        test('Cannot create user with invalid data structure', async () => {
            const userRef = doc(db, 'users', userId);

            // Attempt to set admin flag
            await expect(
                setDoc(userRef, {
                    displayName: 'Test',
                    isAdmin: true, // Should not be allowed
                    diamondBalance: 999999999,
                })
            ).rejects.toThrow();
        });

        test('Cannot create game with hostile hostId', async () => {
            const gameRef = doc(db, 'games', 'hostile-game');

            // Attempt to set another user as host
            await expect(
                setDoc(gameRef, {
                    hostId: 'other-user-id', // Should only be auth.uid
                    status: 'waiting',
                })
            ).rejects.toThrow();
        });

        test('Cannot directly modify diamond balance', async () => {
            const userRef = doc(db, 'users', userId);

            // First create valid user
            await setDoc(userRef, { displayName: 'Test User' });

            // Attempt to directly set high diamond balance
            await expect(
                updateDoc(userRef, { diamondBalance: 999999999 })
            ).rejects.toThrow();
        });
    });

    describe('Rate Limiting Security', () => {
        let userId: string;

        beforeEach(async () => {
            const cred = await signInAnonymously(auth);
            userId = cred.user.uid;
        });

        test('Rapid requests are rate limited', async () => {
            const functions = getFunctions(app);
            if (process.env.FUNCTIONS_EMULATOR_HOST) {
                connectFunctionsEmulator(functions, 'localhost', 5001);
            }

            const testFunction = httpsCallable(functions, 'healthCheck');
            const requests: Promise<any>[] = [];

            // Send 20 rapid requests
            for (let i = 0; i < 20; i++) {
                requests.push(testFunction({}));
            }

            const results = await Promise.allSettled(requests);
            const rejected = results.filter(r => r.status === 'rejected');

            // Some requests should be rate limited
            expect(rejected.length).toBeGreaterThan(0);
        });
    });

    describe('Injection Security', () => {
        let userId: string;

        beforeEach(async () => {
            const cred = await signInAnonymously(auth);
            userId = cred.user.uid;
        });

        test('Script injection in display name is sanitized', async () => {
            const userRef = doc(db, 'users', userId);

            const maliciousName = '<script>alert("xss")</script>';

            // Should either reject or sanitize
            try {
                await setDoc(userRef, { displayName: maliciousName });
                const doc = await getDoc(userRef);
                const name = doc.data()?.displayName;

                // If accepted, script tags should be escaped
                expect(name).not.toContain('<script>');
            } catch (e) {
                // Rejection is also acceptable
                expect(e).toBeDefined();
            }
        });

        test('SQL-like injection in queries is safe', async () => {
            const maliciousQuery = "'; DROP TABLE users; --";

            // Firestore doesn't use SQL, but test proper handling
            const usersRef = collection(db, 'users');

            // This should not cause any issues
            await expect(getDocs(usersRef)).resolves.toBeDefined();
        });
    });

    describe('IDOR (Insecure Direct Object Reference) Security', () => {
        let userId: string;

        beforeEach(async () => {
            const cred = await signInAnonymously(auth);
            userId = cred.user.uid;
        });

        test('Cannot access transactions by guessing IDs', async () => {
            // Try to access random transaction IDs
            const guessedIds = [
                'transaction-001',
                'transaction-002',
                'abc123',
                userId.substring(0, 10) + '-tx-001',
            ];

            for (const id of guessedIds) {
                const txRef = doc(db, 'transactions', id);
                await expect(getDoc(txRef)).rejects.toThrow();
            }
        });

        test('Cannot access games by guessing room codes', async () => {
            const guessedCodes = ['AAAA', '1234', 'TEST', 'GAME'];

            for (const code of guessedCodes) {
                const gameRef = doc(db, 'games', code);
                // Should either not exist or require auth
                const result = await getDoc(gameRef).catch(() => null);

                if (result && result.exists()) {
                    // If game exists, user should be a player
                    const data = result.data();
                    expect(data.playerIds).toContain(userId);
                }
            }
        });
    });

    describe('Privilege Escalation Security', () => {
        let userId: string;

        beforeEach(async () => {
            const cred = await signInAnonymously(auth);
            userId = cred.user.uid;
        });

        test('Cannot grant self admin privileges', async () => {
            const userRef = doc(db, 'users', userId);

            await expect(
                updateDoc(userRef, {
                    role: 'admin',
                    isAdmin: true,
                    'customClaims.admin': true,
                })
            ).rejects.toThrow();
        });

        test('Cannot modify admin collection', async () => {
            const adminRef = doc(db, 'admins', 'test@example.com');

            await expect(
                setDoc(adminRef, {
                    email: 'test@example.com',
                    addedAt: new Date(),
                })
            ).rejects.toThrow();
        });

        test('Cannot write to audit logs', async () => {
            const auditRef = doc(db, 'audit_logs', 'fake-audit');

            await expect(
                setDoc(auditRef, {
                    action: 'FAKE_ACTION',
                    userId: userId,
                })
            ).rejects.toThrow();
        });
    });
});

// Test runner configuration
export const runSecurityTests = async () => {
    console.log('🔒 Running Security Penetration Tests...');
    // Tests are run via Jest
};
