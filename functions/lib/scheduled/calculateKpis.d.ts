interface KPISnapshot {
    date: string;
    dau: number;
    mau: number;
    dauMauRatio: number;
    newUsersToday: number;
    gamesPlayedToday: number;
    averageSessionMinutes: number;
    diamondsSpentToday: number;
    diamondsEarnedToday: number;
    retentionD1: number;
    retentionD7: number;
    retentionD30: number;
    agentActionsToday: number;
    instantPlayRate: number;
    calculatedAt: string;
}
/**
 * Calculate KPIs - Scheduled Daily Job
 *
 * Runs daily at 1 AM UTC to calculate key performance indicators.
 * Results are stored in the kpi_snapshots collection for dashboards.
 */
export declare const calculateDailyKpis: import("firebase-functions/v2/scheduler").ScheduleFunction;
/**
 * Get KPI Dashboard Data
 *
 * Returns KPI data for the specified date range.
 */
export declare const getKpiDashboard: import("firebase-functions/v2/https").CallableFunction<{
    days?: number;
}, Promise<{
    snapshots: KPISnapshot[];
    summary: Record<string, number>;
}>, unknown>;
export {};
//# sourceMappingURL=calculateKpis.d.ts.map