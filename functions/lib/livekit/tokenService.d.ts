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
//# sourceMappingURL=tokenService.d.ts.map