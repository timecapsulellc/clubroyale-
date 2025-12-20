/**
 * GDPR Compliance Utilities
 * Data export and deletion for user privacy
 */
interface UserDataExport {
    exportedAt: string;
    userId: string;
    profile: Record<string, unknown> | null;
    wallet: Record<string, unknown> | null;
    games: Record<string, unknown>[];
    messages: Record<string, unknown>[];
    friends: string[];
    settings: Record<string, unknown> | null;
}
/**
 * Export all user data (GDPR Article 15 & 20)
 */
export declare function exportUserData(userId: string): Promise<UserDataExport>;
/**
 * Delete all user data (GDPR Article 17 - Right to be Forgotten)
 */
export declare function deleteUserData(userId: string, options?: {
    keepAnonymizedGameData?: boolean;
}): Promise<{
    deletedCollections: string[];
    errors: string[];
}>;
/**
 * Update user consent preferences
 */
export declare function updateConsent(userId: string, consent: {
    analytics: boolean;
    marketing: boolean;
    thirdParty: boolean;
}): Promise<void>;
declare const _default: {
    exportUserData: typeof exportUserData;
    deleteUserData: typeof deleteUserData;
    updateConsent: typeof updateConsent;
};
export default _default;
//# sourceMappingURL=gdpr.d.ts.map