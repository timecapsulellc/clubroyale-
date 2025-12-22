interface DeletionResult {
    success: boolean;
    deletedAt: string;
    userId: string;
    deletedCollections: string[];
    errors: string[];
}
/**
 * GDPR Data Deletion Function (Right to be Forgotten)
 *
 * Deletes all user data across all collections as required by GDPR Article 17.
 */
export declare const gdprDeleteUserData: import("firebase-functions/v2/https").CallableFunction<{
    confirmDelete: boolean;
}, Promise<DeletionResult>, unknown>;
export {};
//# sourceMappingURL=gdprDelete.d.ts.map