/**
 * ToT (Tree of Thought) Benchmarking Tests
 * 
 * Benchmarks AI agent reasoning performance using ToT methodology.
 */

import { getFirestore, Timestamp } from "firebase-admin/firestore";

const db = getFirestore();

interface BenchmarkResult {
    agentName: string;
    testCase: string;
    totIterations: number;
    finalDecision: string;
    correctAnswer: string;
    isCorrect: boolean;
    reasoningTime: number;
    thoughtsGenerated: number;
    pruningRate: number;
    confidence: number;
}

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

// Test cases for bot decision-making
const GAME_TEST_CASES = [
    {
        name: "teen_patti_bluff_detection",
        scenario: {
            myHand: "2-3-5 (high card)",
            opponentBets: 100,
            potSize: 200,
            opponentHistory: "aggressive_bluffer",
        },
        expectedAction: "call",
        difficulty: "medium",
    },
    {
        name: "call_break_trump_management",
        scenario: {
            hand: ["♠A", "♠K", "♠5", "♥Q", "♥J"],
            tricksNeeded: 3,
            tricksWon: 1,
            cardsRemaining: 8,
        },
        expectedAction: "save_trump",
        difficulty: "hard",
    },
    {
        name: "marriage_meld_priority",
        scenario: {
            hand: ["♠K", "♠Q", "♥K", "♥Q", "♦K"],
            trumpSuit: "hearts",
            points: 50,
            targetPoints: 120,
        },
        expectedAction: "meld_royal_marriage",
        difficulty: "medium",
    },
    {
        name: "in_between_risk_assessment",
        scenario: {
            card1: "3",
            card2: "King",
            potSize: 500,
            myChips: 200,
        },
        expectedAction: "bet_half_pot",
        difficulty: "easy",
    },
    {
        name: "teen_patti_fold_decision",
        scenario: {
            myHand: "2-4-7 (high card)",
            opponentBets: 500,
            potSize: 1000,
            opponentHistory: "conservative_player",
        },
        expectedAction: "fold",
        difficulty: "easy",
    },
];

/**
 * Run ToT benchmark for a specific agent
 */
export async function runTotBenchmark(
    agentName: string,
    agentFunction: (scenario: any) => Promise<{ action: string; confidence: number; thoughts: string[] }>
): Promise<BenchmarkSummary> {
    const results: BenchmarkResult[] = [];

    for (const testCase of GAME_TEST_CASES) {
        const startTime = Date.now();

        try {
            const result = await agentFunction(testCase.scenario);
            const endTime = Date.now();

            const benchmarkResult: BenchmarkResult = {
                agentName,
                testCase: testCase.name,
                totIterations: result.thoughts.length,
                finalDecision: result.action,
                correctAnswer: testCase.expectedAction,
                isCorrect: result.action.toLowerCase().includes(testCase.expectedAction.toLowerCase()),
                reasoningTime: endTime - startTime,
                thoughtsGenerated: result.thoughts.length,
                pruningRate: calculatePruningRate(result.thoughts),
                confidence: result.confidence,
            };

            results.push(benchmarkResult);

            // Store individual result
            await db.collection("tot_benchmark_results").add({
                ...benchmarkResult,
                timestamp: Timestamp.now(),
            });
        } catch (error) {
            console.error(`Benchmark failed for ${testCase.name}:`, error);
            results.push({
                agentName,
                testCase: testCase.name,
                totIterations: 0,
                finalDecision: "error",
                correctAnswer: testCase.expectedAction,
                isCorrect: false,
                reasoningTime: 0,
                thoughtsGenerated: 0,
                pruningRate: 0,
                confidence: 0,
            });
        }
    }

    // Calculate summary
    const correctCount = results.filter(r => r.isCorrect).length;
    const summary: BenchmarkSummary = {
        agentName,
        totalTests: results.length,
        correctCount,
        accuracy: (correctCount / results.length) * 100,
        avgReasoningTime: results.reduce((sum, r) => sum + r.reasoningTime, 0) / results.length,
        avgIterations: results.reduce((sum, r) => sum + r.totIterations, 0) / results.length,
        avgConfidence: results.reduce((sum, r) => sum + r.confidence, 0) / results.length,
        timestamp: new Date(),
    };

    // Store summary
    await db.collection("tot_benchmark_summaries").add(summary);

    console.log(`[ToT Benchmark] ${agentName}: ${summary.accuracy.toFixed(1)}% accuracy`);
    return summary;
}

function calculatePruningRate(thoughts: string[]): number {
    // Estimate pruning rate based on thought count vs expected
    const expectedThoughts = 8; // Average expected for ToT
    return Math.max(0, 1 - (thoughts.length / expectedThoughts));
}

/**
 * Mock agent for testing the benchmark framework
 */
export async function mockAgentDecision(scenario: any): Promise<{
    action: string;
    confidence: number;
    thoughts: string[];
}> {
    // Simulate ToT reasoning
    const thoughts = [
        "Analyzing initial state...",
        "Evaluating option A: aggressive play",
        "Evaluating option B: conservative play",
        "Pruning unlikely branches...",
        "Comparing expected values...",
        "Final decision reached",
    ];

    // Simple heuristic-based mock decision
    let action = "fold";
    let confidence = 0.5;

    if (scenario.potSize && scenario.opponentBets) {
        const potOdds = scenario.opponentBets / (scenario.potSize + scenario.opponentBets);
        if (potOdds < 0.3) {
            action = "call";
            confidence = 0.7;
        }
    }

    if (scenario.hand && scenario.tricksNeeded) {
        action = "save_trump";
        confidence = 0.8;
    }

    if (scenario.card1 && scenario.card2) {
        const spread = getCardValue(scenario.card2) - getCardValue(scenario.card1);
        if (spread > 8) {
            action = "bet_half_pot";
            confidence = 0.75;
        }
    }

    return { action, confidence, thoughts };
}

function getCardValue(card: string): number {
    const values: Record<string, number> = {
        '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7,
        '8': 8, '9': 9, '10': 10, 'Jack': 11, 'Queen': 12, 'King': 13, 'Ace': 14,
    };
    return values[card] || 0;
}

// Export test cases for external use
export const testCases = GAME_TEST_CASES;
