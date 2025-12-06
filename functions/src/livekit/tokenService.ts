/**
 * LiveKit Token Generation Cloud Function
 * 
 * Generates JWT tokens for LiveKit room access with role-based permissions.
 */

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { AccessToken, VideoGrant } from 'livekit-server-sdk';

// LiveKit server configuration
// Set these in your environment variables or .env file
const LIVEKIT_API_KEY = process.env.LIVEKIT_API_KEY || 'your-api-key';
const LIVEKIT_API_SECRET = process.env.LIVEKIT_API_SECRET || 'your-api-secret';

/**
 * Generate a LiveKit token for a participant
 */
export const generateLiveKitToken = onCall(async (request) => {
    const { roomName, participantName, participantId, isSpectator } = request.data;
    const userId = request.auth?.uid;

    // Validate authentication
    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    // Validate required parameters
    if (!roomName || typeof roomName !== 'string') {
        throw new HttpsError('invalid-argument', 'Room name is required');
    }

    if (!participantName || typeof participantName !== 'string') {
        throw new HttpsError('invalid-argument', 'Participant name is required');
    }

    // Create access token
    const token = new AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET, {
        identity: participantId || userId,
        name: participantName,
        // Token expires in 24 hours
        ttl: 60 * 60 * 24,
    });

    // Define video grant based on role
    const videoGrant: VideoGrant = {
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
export const validateSpectatorAccess = onCall(async (request) => {
    const { roomId } = request.data;
    const userId = request.auth?.uid;

    if (!userId) {
        throw new HttpsError('unauthenticated', 'User must be logged in');
    }

    if (!roomId) {
        throw new HttpsError('invalid-argument', 'Room ID is required');
    }

    // Import admin here to avoid initialization issues
    const { getFirestore } = await import('firebase-admin/firestore');
    const db = getFirestore();

    // Check if user is approved
    const approvalDoc = await db
        .collection('game_rooms')
        .doc(roomId)
        .collection('approved_spectators')
        .doc(userId)
        .get();

    if (!approvalDoc.exists) {
        throw new HttpsError('permission-denied', 'Not approved as spectator');
    }

    return { approved: true };
});
