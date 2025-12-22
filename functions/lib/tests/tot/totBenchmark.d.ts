/**
 * ToT (Tree of Thought) Benchmarking Tests
 *
 * Benchmarks AI agent reasoning performance using ToT methodology.
 */
interface BenchmarkSummary {
    agentName: string;
    totalTests: number;
    correctCount: number;
    accuracy: number;
    avgReasoningTime: number;
    avgIterations: number;
    avgConfidence: number;
    timestamp: Date;
}
/**
 * Run ToT benchmark for a specific agent
 */
export declare function runTotBenchmark(agentName: string, agentFunction: (scenario: any) => Promise<{
    action: string;
    confidence: number;
    thoughts: string[];
}>): Promise<BenchmarkSummary>;
/**
 * Mock agent for testing the benchmark framework
 */
export declare function mockAgentDecision(scenario: any): Promise<{
    action: string;
    confidence: number;
    thoughts: string[];
}>;
export declare const testCases: ({
    name: string;
    scenario: {
        myHand: string;
        opponentBets: number;
        potSize: number;
        opponentHistory: string;
        hand?: undefined;
        tricksNeeded?: undefined;
        tricksWon?: undefined;
        cardsRemaining?: undefined;
        trumpSuit?: undefined;
        points?: undefined;
        targetPoints?: undefined;
        card1?: undefined;
        card2?: undefined;
        myChips?: undefined;
    };
    expectedAction: string;
    difficulty: string;
} | {
    name: string;
    scenario: {
        hand: string[];
        tricksNeeded: number;
        tricksWon: number;
        cardsRemaining: number;
        myHand?: undefined;
        opponentBets?: undefined;
        potSize?: undefined;
        opponentHistory?: undefined;
        trumpSuit?: undefined;
        points?: undefined;
        targetPoints?: undefined;
        card1?: undefined;
        card2?: undefined;
        myChips?: undefined;
    };
    expectedAction: string;
    difficulty: string;
} | {
    name: string;
    scenario: {
        hand: string[];
        trumpSuit: string;
        points: number;
        targetPoints: number;
        myHand?: undefined;
        opponentBets?: undefined;
        potSize?: undefined;
        opponentHistory?: undefined;
        tricksNeeded?: undefined;
        tricksWon?: undefined;
        cardsRemaining?: undefined;
        card1?: undefined;
        card2?: undefined;
        myChips?: undefined;
    };
    expectedAction: string;
    difficulty: string;
} | {
    name: string;
    scenario: {
        card1: string;
        card2: string;
        potSize: number;
        myChips: number;
        myHand?: undefined;
        opponentBets?: undefined;
        opponentHistory?: undefined;
        hand?: undefined;
        tricksNeeded?: undefined;
        tricksWon?: undefined;
        cardsRemaining?: undefined;
        trumpSuit?: undefined;
        points?: undefined;
        targetPoints?: undefined;
    };
    expectedAction: string;
    difficulty: string;
})[];
export {};
//# sourceMappingURL=totBenchmark.d.ts.map