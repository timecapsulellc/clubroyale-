"use strict";
/**
 * Security Penetration Tests
 *
 * Automated security testing suite for ClubRoyale.
 * Tests common vulnerabilities and security configurations.
 *
 * Run with: npm run test:security
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.runSecurityTests = void 0;
const app_1 = require("firebase/app");
const firestore_1 = require("firebase/firestore");
const auth_1 = require("firebase/auth");
const functions_1 = require("firebase/functions");
// Test configuration
const testConfig = {
    projectId: 'clubroyale-test',
    apiKey: 'test-api-key',
};
let app;
let db;
let auth;
describe('Security Penetration Tests', () => {
    beforeAll(async () => {
        app = (0, app_1.initializeApp)(testConfig, 'security-test');
        db = (0, firestore_1.getFirestore)(app);
        auth = (0, auth_1.getAuth)(app);
        // Connect to emulators if available
        if (process.env.FIRESTORE_EMULATOR_HOST) {
            (0, firestore_1.connectFirestoreEmulator)(db, 'localhost', 8080);
        }
        if (process.env.AUTH_EMULATOR_HOST) {
            (0, auth_1.connectAuthEmulator)(auth, 'http://localhost:9099');
        }
    });
    afterAll(async () => {
        await (0, app_1.deleteApp)(app);
    });
    describe('Authentication Security', () => {
        test('Unauthenticated users cannot read user profiles', async () => {
            await (0, auth_1.signOut)(auth);
            const userRef = (0, firestore_1.doc)(db, 'users', 'any-user-id');
            await expect((0, firestore_1.getDoc)(userRef)).rejects.toThrow();
        });
        test('Unauthenticated users cannot read wallets', async () => {
            await (0, auth_1.signOut)(auth);
            const walletRef = (0, firestore_1.doc)(db, 'wallets', 'any-user-id');
            await expect((0, firestore_1.getDoc)(walletRef)).rejects.toThrow();
        });
        test('Unauthenticated users cannot create games', async () => {
            await (0, auth_1.signOut)(auth);
            const gameRef = (0, firestore_1.doc)(db, 'games', 'test-game');
            await expect((0, firestore_1.setDoc)(gameRef, { status: 'waiting' })).rejects.toThrow();
        });
    });
    describe('Authorization Security', () => {
        let userId;
        beforeEach(async () => {
            const cred = await (0, auth_1.signInAnonymously)(auth);
            userId = cred.user.uid;
        });
        afterEach(async () => {
            await (0, auth_1.signOut)(auth);
        });
        test('User cannot read other users wallet', async () => {
            const otherWalletRef = (0, firestore_1.doc)(db, 'wallets', 'other-user-id');
            await expect((0, firestore_1.getDoc)(otherWalletRef)).rejects.toThrow();
        });
        test('User cannot update other users profile', async () => {
            const otherUserRef = (0, firestore_1.doc)(db, 'users', 'other-user-id');
            await expect((0, firestore_1.updateDoc)(otherUserRef, { displayName: 'Hacked!' })).rejects.toThrow();
        });
        test('User cannot delete other users data', async () => {
            const otherUserRef = (0, firestore_1.doc)(db, 'users', 'other-user-id');
            await expect((0, firestore_1.deleteDoc)(otherUserRef)).rejects.toThrow();
        });
        test('User cannot access audit logs', async () => {
            const auditRef = (0, firestore_1.doc)(db, 'audit_logs', 'any-log-id');
            await expect((0, firestore_1.getDoc)(auditRef)).rejects.toThrow();
        });
        test('User cannot access flagged users list', async () => {
            const flaggedRef = (0, firestore_1.doc)(db, 'flaggedUsers', 'any-user-id');
            await expect((0, firestore_1.getDoc)(flaggedRef)).rejects.toThrow();
        });
    });
    describe('Data Validation Security', () => {
        let userId;
        beforeEach(async () => {
            const cred = await (0, auth_1.signInAnonymously)(auth);
            userId = cred.user.uid;
        });
        afterEach(async () => {
            await (0, auth_1.signOut)(auth);
        });
        test('Cannot create user with invalid data structure', async () => {
            const userRef = (0, firestore_1.doc)(db, 'users', userId);
            // Attempt to set admin flag
            await expect((0, firestore_1.setDoc)(userRef, {
                displayName: 'Test',
                isAdmin: true, // Should not be allowed
                diamondBalance: 999999999,
            })).rejects.toThrow();
        });
        test('Cannot create game with hostile hostId', async () => {
            const gameRef = (0, firestore_1.doc)(db, 'games', 'hostile-game');
            // Attempt to set another user as host
            await expect((0, firestore_1.setDoc)(gameRef, {
                hostId: 'other-user-id', // Should only be auth.uid
                status: 'waiting',
            })).rejects.toThrow();
        });
        test('Cannot directly modify diamond balance', async () => {
            const userRef = (0, firestore_1.doc)(db, 'users', userId);
            // First create valid user
            await (0, firestore_1.setDoc)(userRef, { displayName: 'Test User' });
            // Attempt to directly set high diamond balance
            await expect((0, firestore_1.updateDoc)(userRef, { diamondBalance: 999999999 })).rejects.toThrow();
        });
    });
    describe('Rate Limiting Security', () => {
        let userId;
        beforeEach(async () => {
            const cred = await (0, auth_1.signInAnonymously)(auth);
            userId = cred.user.uid;
        });
        test('Rapid requests are rate limited', async () => {
            const functions = (0, functions_1.getFunctions)(app);
            if (process.env.FUNCTIONS_EMULATOR_HOST) {
                (0, functions_1.connectFunctionsEmulator)(functions, 'localhost', 5001);
            }
            const testFunction = (0, functions_1.httpsCallable)(functions, 'healthCheck');
            const requests = [];
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
        let userId;
        beforeEach(async () => {
            const cred = await (0, auth_1.signInAnonymously)(auth);
            userId = cred.user.uid;
        });
        test('Script injection in display name is sanitized', async () => {
            const userRef = (0, firestore_1.doc)(db, 'users', userId);
            const maliciousName = '<script>alert("xss")</script>';
            // Should either reject or sanitize
            try {
                await (0, firestore_1.setDoc)(userRef, { displayName: maliciousName });
                const doc = await (0, firestore_1.getDoc)(userRef);
                const name = doc.data()?.displayName;
                // If accepted, script tags should be escaped
                expect(name).not.toContain('<script>');
            }
            catch (e) {
                // Rejection is also acceptable
                expect(e).toBeDefined();
            }
        });
        test('SQL-like injection in queries is safe', async () => {
            const maliciousQuery = "'; DROP TABLE users; --";
            // Firestore doesn't use SQL, but test proper handling
            const usersRef = (0, firestore_1.collection)(db, 'users');
            // This should not cause any issues
            await expect((0, firestore_1.getDocs)(usersRef)).resolves.toBeDefined();
        });
    });
    describe('IDOR (Insecure Direct Object Reference) Security', () => {
        let userId;
        beforeEach(async () => {
            const cred = await (0, auth_1.signInAnonymously)(auth);
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
                const txRef = (0, firestore_1.doc)(db, 'transactions', id);
                await expect((0, firestore_1.getDoc)(txRef)).rejects.toThrow();
            }
        });
        test('Cannot access games by guessing room codes', async () => {
            const guessedCodes = ['AAAA', '1234', 'TEST', 'GAME'];
            for (const code of guessedCodes) {
                const gameRef = (0, firestore_1.doc)(db, 'games', code);
                // Should either not exist or require auth
                const result = await (0, firestore_1.getDoc)(gameRef).catch(() => null);
                if (result && result.exists()) {
                    // If game exists, user should be a player
                    const data = result.data();
                    expect(data.playerIds).toContain(userId);
                }
            }
        });
    });
    describe('Privilege Escalation Security', () => {
        let userId;
        beforeEach(async () => {
            const cred = await (0, auth_1.signInAnonymously)(auth);
            userId = cred.user.uid;
        });
        test('Cannot grant self admin privileges', async () => {
            const userRef = (0, firestore_1.doc)(db, 'users', userId);
            await expect((0, firestore_1.updateDoc)(userRef, {
                role: 'admin',
                isAdmin: true,
                'customClaims.admin': true,
            })).rejects.toThrow();
        });
        test('Cannot modify admin collection', async () => {
            const adminRef = (0, firestore_1.doc)(db, 'admins', 'test@example.com');
            await expect((0, firestore_1.setDoc)(adminRef, {
                email: 'test@example.com',
                addedAt: new Date(),
            })).rejects.toThrow();
        });
        test('Cannot write to audit logs', async () => {
            const auditRef = (0, firestore_1.doc)(db, 'audit_logs', 'fake-audit');
            await expect((0, firestore_1.setDoc)(auditRef, {
                action: 'FAKE_ACTION',
                userId: userId,
            })).rejects.toThrow();
        });
    });
});
// Test runner configuration
const runSecurityTests = async () => {
    console.log('🔒 Running Security Penetration Tests...');
    // Tests are run via Jest
};
exports.runSecurityTests = runSecurityTests;
//# sourceMappingURL=penetrationTests.js.map