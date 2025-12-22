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
 */
export declare const gdprExportUserData: import("firebase-functions/v2/https").CallableFunction<void, Promise<UserDataExport>, unknown>;
export {};
//# sourceMappingURL=gdprExport.d.ts.map