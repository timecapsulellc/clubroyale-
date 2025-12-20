/**
 * Bot Room Seeder - Cloud Function
 *
 * Ensures minimum bot-hosted game rooms are always available.
 * Runs on schedule (every hour) and on-demand.
 */
/**
 * Scheduled function - runs every hour
 */
export declare const seedBotRoomsScheduled: import("firebase-functions/v2/scheduler").ScheduleFunction;
/**
 * Callable function - for manual triggering or admin
 */
export declare const seedBotRoomsManual: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    success: boolean;
    roomsCreated: number;
}>, unknown>;
/**
 * Cleanup function - removes ALL non-playing rooms (for reset)
 */
export declare const cleanupAllWaitingRooms: import("firebase-functions/v2/https").CallableFunction<any, Promise<{
    cleaned: number;
    created: number;
}>, unknown>;
//# sourceMappingURL=botRoomSeeder.d.ts.map