/**
 * Tree of Thoughts (ToT) Reasoning Engine
 * Multi-step reasoning with evaluation and backtracking
 */
import { z } from 'genkit';
export declare const treeOfThoughtsFlow: import("genkit").CallableFlow<z.ZodObject<{
    problem: z.ZodString;
    context: z.ZodRecord<z.ZodString, z.ZodUnknown>;
    config: z.ZodOptional<z.ZodObject<{
        maxDepth: z.ZodOptional<z.ZodNumber>;
        branchingFactor: z.ZodOptional<z.ZodNumber>;
        evaluationThreshold: z.ZodOptional<z.ZodNumber>;
        maxIterations: z.ZodOptional<z.ZodNumber>;
    }, "strip", z.ZodTypeAny, {
        maxDepth?: number | undefined;
        branchingFactor?: number | undefined;
        evaluationThreshold?: number | undefined;
        maxIterations?: number | undefined;
    }, {
        maxDepth?: number | undefined;
        branchingFactor?: number | undefined;
        evaluationThreshold?: number | undefined;
        maxIterations?: number | undefined;
    }>>;
}, "strip", z.ZodTypeAny, {
    context: Record<string, unknown>;
    problem: string;
    config?: {
        maxDepth?: number | undefined;
        branchingFactor?: number | undefined;
        evaluationThreshold?: number | undefined;
        maxIterations?: number | undefined;
    } | undefined;
}, {
    context: Record<string, unknown>;
    problem: string;
    config?: {
        maxDepth?: number | undefined;
        branchingFactor?: number | undefined;
        evaluationThreshold?: number | undefined;
        maxIterations?: number | undefined;
    } | undefined;
}>, z.ZodObject<{
    bestPath: z.ZodArray<z.ZodString, "many">;
    confidence: z.ZodNumber;
    reasoning: z.ZodString;
    alternativePaths: z.ZodArray<z.ZodArray<z.ZodString, "many">, "many">;
    totalThoughtsGenerated: z.ZodNumber;
    executionTimeMs: z.ZodNumber;
}, "strip", z.ZodTypeAny, {
    reasoning: string;
    confidence: number;
    totalThoughtsGenerated: number;
    bestPath: string[];
    alternativePaths: string[][];
    executionTimeMs: number;
}, {
    reasoning: string;
    confidence: number;
    totalThoughtsGenerated: number;
    bestPath: string[];
    alternativePaths: string[][];
    executionTimeMs: number;
}>, z.ZodTypeAny>;
export default treeOfThoughtsFlow;
//# sourceMappingURL=treeOfThoughts.d.ts.map