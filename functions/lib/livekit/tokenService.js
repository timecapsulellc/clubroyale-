"use strict";
/**
 * LiveKit Token Generation Cloud Function
 *
 * Generates JWT tokens for LiveKit room access with role-based permissions.
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
exports.validateSpectatorAccess = exports.generateLiveKitToken = void 0;
const https_1 = require("firebase-functions/v2/https");
const livekit_server_sdk_1 = require("livekit-server-sdk");
// LiveKit server configuration
// Set these in your environment variables or .env file
const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY || 'your-api-key';
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET || 'your-api-secret';
/**
 * Generate a LiveKit token for a participant
 */
exports.generateLiveKitToken = (0, https_1.onCall)(async (request) => {
    const { roomName, participantName, participantId, isSpectator } = request.data;
    const userId = request.auth?.uid;
    // Validate authentication
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    // Validate required parameters
    if (!roomName || typeof roomName !== 'string') {
        throw new https_1.HttpsError('invalid-argument', 'Room name is required');
    }
    if (!participantName || typeof participantName !== 'string') {
        throw new https_1.HttpsError('invalid-argument', 'Participant name is required');
    }
    // Create access token
    const token = new livekit_server_sdk_1.AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
        identity: participantId || userId,
        name: participantName,
        // Token expires in 24 hours
        ttl: 60 * 60 * 24,
    });
    // Define video grant based on role
    const videoGrant = {
        room: roomName,
        roomJoin: true,
        // Spectators can only subscribe, not publish
        canPublish: !isSpectator,
        canSubscribe: true,
        // Allow publishing data messages (for chat/reactions)
        canPublishData: true,
    };
    token.addGrant(videoGrant);
    return {
        token: await token.toJwt(),
        expiresAt: Date.now() + (60 * 60 * 24 * 1000), // 24 hours
    };
});
/**
 * Validate if a user can join a room as spectator
 * Checks if they've been approved by the admin
 */
exports.validateSpectatorAccess = (0, https_1.onCall)(async (request) => {
    const { roomId } = request.data;
    const userId = request.auth?.uid;
    if (!userId) {
        throw new https_1.HttpsError('unauthenticated', 'User must be logged in');
    }
    if (!roomId) {
        throw new https_1.HttpsError('invalid-argument', 'Room ID is required');
    }
    // Import admin here to avoid initialization issues
    const { getFirestore } = await Promise.resolve().then(() => __importStar(require('firebase-admin/firestore')));
    const db = getFirestore();
    // Check if user is approved
    const approvalDoc = await db
        .collection('game_rooms')
        .doc(roomId)
        .collection('approved_spectators')
        .doc(userId)
        .get();
    if (!approvalDoc.exists) {
        throw new https_1.HttpsError('permission-denied', 'Not approved as spectator');
    }
    return { approved: true };
});
//# sourceMappingURL=tokenService.js.map