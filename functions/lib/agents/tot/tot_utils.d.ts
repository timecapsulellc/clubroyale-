/**
 * Tree of Thoughts (ToT) Utility Library
 *
 * Implements deliberate problem-solving with LLMs through:
 * - Thought decomposition
 * - Multi-path exploration
 * - State evaluation
 * - Backtracking support
 *
 * Based on: "Tree of Thoughts: Deliberate Problem Solving with Large Language Models"
 */
import { z } from 'genkit';
export interface Thought {
    id: string;
    dimension: string;
    content: string;
    score: number;
    confidence: number;
    reasoning: string;
}
export interface ThoughtNode {
    thought: Thought;
    children: ThoughtNode[];
    parent?: ThoughtNode;
    depth: number;
}
export interface ToTConfig {
    maxDepth: number;
    branchingFactor: number;
    evaluationThreshold: number;
    searchStrategy: 'bfs' | 'dfs';
}
export interface EvaluationResult {
    score: number;
    confidence: number;
    shouldContinue: boolean;
    shouldBacktrack: boolean;
    reasoning: string;
}
export interface ToTResult<T> {
    finalAnswer: T;
    bestPath: Thought[];
    allPaths: Thought[][];
    totalThoughtsGenerated: number;
    backtrackCount: number;
}
/**
 * Generate candidate thoughts for a given problem dimension
 */
export declare function generateThoughts(context: string, dimensions: string[], currentState: string, branchingFactor?: number): Promise<Thought[]>;
/**
 * Evaluate a thought's contribution toward solving the problem
 */
export declare function evaluateThought(thought: Thought, goalDescription: string, previousThoughts?: Thought[]): Promise<EvaluationResult>;
/**
 * Breadth-First Search through thought tree
 */
export declare function bfsSearch(rootThoughts: Thought[], goalDescription: string, config: ToTConfig, generateChildThoughts: (thought: Thought) => Promise<Thought[]>): Promise<ThoughtNode[]>;
/**
 * Depth-First Search through thought tree
 */
export declare function dfsSearch(rootThoughts: Thought[], goalDescription: string, config: ToTConfig, generateChildThoughts: (thought: Thought) => Promise<Thought[]>): Promise<ThoughtNode[]>;
/**
 * Select the best paths from explored thoughts
 */
export declare function selectBestPaths(explored: ThoughtNode[], topK?: number): Thought[][];
/**
 * Aggregate multiple thought paths into a final answer
 */
export declare function aggregateResults<T>(bestPaths: Thought[][], goalDescription: string, outputSchema: z.ZodType<T>): Promise<{
    result: T;
    confidence: number;
}>;
/**
 * Main ToT orchestrator - runs the full Tree of Thoughts process
 */
export declare function runTreeOfThoughts<T>(problemDescription: string, dimensions: string[], goalDescription: string, outputSchema: z.ZodType<T>, config?: Partial<ToTConfig>): Promise<ToTResult<T>>;
/**
 * Simplified ToT for multi-factor evaluation (e.g., churn prediction)
 */
export declare function multiFactorToT<T>(factors: {
    name: string;
    context: string;
}[], evaluationGoal: string, outputSchema: z.ZodType<T>): Promise<{
    result: T;
    factorScores: Record<string, number>;
    confidence: number;
}>;
/**
 * Simplified ToT for multi-step verification (e.g., content moderation)
 */
export declare function stepwiseToT<T>(content: string, steps: {
    name: string;
    prompt: string;
}[], contextInfo: Record<string, unknown>, outputSchema: z.ZodType<T>): Promise<{
    result: T;
    stepResults: Record<string, unknown>;
    shouldBlock: boolean;
}>;
declare const _default: {
    generateThoughts: typeof generateThoughts;
    evaluateThought: typeof evaluateThought;
    bfsSearch: typeof bfsSearch;
    dfsSearch: typeof dfsSearch;
    selectBestPaths: typeof selectBestPaths;
    aggregateResults: typeof aggregateResults;
    runTreeOfThoughts: typeof runTreeOfThoughts;
    multiFactorToT: typeof multiFactorToT;
    stepwiseToT: typeof stepwiseToT;
};
export default _default;
//# sourceMappingURL=tot_utils.d.ts.map