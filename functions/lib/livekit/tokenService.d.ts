/**
 * LiveKit Token Generation Cloud Function
 *
 * Generates JWT tokens for LiveKit room access with role-based permissions.
 */
/**
 * Generate a LiveKit token for a participant
 */
export declare const generateLiveKitToken: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    token: string;
    expiresAt: number;
}>, unknown>;
/**
 * Validate if a user can join a room as spectator
 * Checks if they've been approved by the admin
 */
export declare const validateSpectatorAccess: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    approved: boolean;
}>, unknown>;
/**
 * Mute a participant in a room (Admin only)
 */
export declare const muteParticipant: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
}>, unknown>;
/**
 * Mute ALL participants in a room (Admin only)
 */
export declare const muteAllParticipants: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    count: number;
}>, unknown>;
//# sourceMappingURL=tokenService.d.ts.map