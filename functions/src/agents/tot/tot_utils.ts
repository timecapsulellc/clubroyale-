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

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';

const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// =============================================================================
// TYPES & INTERFACES
// =============================================================================

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

// =============================================================================
// SCHEMAS FOR LLM INTERACTION
// =============================================================================

const ThoughtGenerationSchema = z.object({
    thoughts: z.array(z.object({
        dimension: z.string(),
        content: z.string(),
        reasoning: z.string(),
    })),
});

const ThoughtEvaluationSchema = z.object({
    score: z.number().min(0).max(1),
    confidence: z.number().min(0).max(1),
    shouldContinue: z.boolean(),
    shouldBacktrack: z.boolean(),
    reasoning: z.string(),
});

const AggregationSchema = z.object({
    synthesis: z.string(),
    confidence: z.number(),
});

// =============================================================================
// CORE TOT FUNCTIONS
// =============================================================================

/**
 * Generate candidate thoughts for a given problem dimension
 */
export async function generateThoughts(
    context: string,
    dimensions: string[],
    currentState: string,
    branchingFactor: number = 3
): Promise<Thought[]> {
    const prompt = `You are using Tree of Thoughts reasoning. Generate ${branchingFactor} distinct thoughts for each dimension.

CONTEXT:
${context}

CURRENT STATE:
${currentState}

DIMENSIONS TO EXPLORE:
${dimensions.map((d, i) => `${i + 1}. ${d}`).join('\n')}

For each dimension, generate ${branchingFactor} different thoughts/hypotheses that could lead to a solution.
Each thought should be distinct and explore a different angle.`;

    const { output } = await ai.generate({
        prompt,
        output: { schema: ThoughtGenerationSchema },
    });

    if (!output?.thoughts) {
        return [];
    }

    return output.thoughts.map((t, i) => ({
        id: `thought_${Date.now()}_${i}`,
        dimension: t.dimension,
        content: t.content,
        score: 0,
        confidence: 0,
        reasoning: t.reasoning,
    }));
}

/**
 * Evaluate a thought's contribution toward solving the problem
 */
export async function evaluateThought(
    thought: Thought,
    goalDescription: string,
    previousThoughts: Thought[] = []
): Promise<EvaluationResult> {
    const prompt = `Evaluate this thought's contribution toward solving the problem.

GOAL:
${goalDescription}

THOUGHT TO EVALUATE:
Dimension: ${thought.dimension}
Content: ${thought.content}
Reasoning: ${thought.reasoning}

${previousThoughts.length > 0 ? `
PREVIOUS THOUGHTS IN PATH:
${previousThoughts.map(t => `- [${t.dimension}] ${t.content} (score: ${t.score.toFixed(2)})`).join('\n')}
` : ''}

Evaluate:
1. Score (0-1): How much does this thought contribute to the goal?
2. Confidence (0-1): How confident are you in this evaluation?
3. Should Continue: Should we explore deeper from this thought?
4. Should Backtrack: Does this thought contradict previous thoughts or lead to a dead end?`;

    const { output } = await ai.generate({
        prompt,
        output: { schema: ThoughtEvaluationSchema },
    });

    return output ?? {
        score: 0.5,
        confidence: 0.5,
        shouldContinue: true,
        shouldBacktrack: false,
        reasoning: 'Default evaluation',
    };
}

/**
 * Breadth-First Search through thought tree
 */
export async function bfsSearch(
    rootThoughts: Thought[],
    goalDescription: string,
    config: ToTConfig,
    generateChildThoughts: (thought: Thought) => Promise<Thought[]>
): Promise<ThoughtNode[]> {
    const queue: ThoughtNode[] = rootThoughts.map(t => ({
        thought: t,
        children: [],
        depth: 0,
    }));

    const explored: ThoughtNode[] = [];
    let backtrackCount = 0;

    while (queue.length > 0) {
        const current = queue.shift()!;

        // Evaluate current thought
        const previousThoughts = getPathToRoot(current);
        const evaluation = await evaluateThought(
            current.thought,
            goalDescription,
            previousThoughts
        );

        current.thought.score = evaluation.score;
        current.thought.confidence = evaluation.confidence;

        // Check for backtracking
        if (evaluation.shouldBacktrack) {
            backtrackCount++;
            continue; // Skip this branch
        }

        explored.push(current);

        // Check if we should continue exploring
        if (
            current.depth < config.maxDepth &&
            evaluation.shouldContinue &&
            evaluation.score >= config.evaluationThreshold
        ) {
            const childThoughts = await generateChildThoughts(current.thought);
            for (const childThought of childThoughts) {
                const childNode: ThoughtNode = {
                    thought: childThought,
                    children: [],
                    parent: current,
                    depth: current.depth + 1,
                };
                current.children.push(childNode);
                queue.push(childNode);
            }
        }
    }

    return explored;
}

/**
 * Depth-First Search through thought tree
 */
export async function dfsSearch(
    rootThoughts: Thought[],
    goalDescription: string,
    config: ToTConfig,
    generateChildThoughts: (thought: Thought) => Promise<Thought[]>
): Promise<ThoughtNode[]> {
    const explored: ThoughtNode[] = [];

    async function explore(node: ThoughtNode): Promise<void> {
        const previousThoughts = getPathToRoot(node);
        const evaluation = await evaluateThought(
            node.thought,
            goalDescription,
            previousThoughts
        );

        node.thought.score = evaluation.score;
        node.thought.confidence = evaluation.confidence;

        if (evaluation.shouldBacktrack) {
            return; // Backtrack
        }

        explored.push(node);

        if (
            node.depth < config.maxDepth &&
            evaluation.shouldContinue &&
            evaluation.score >= config.evaluationThreshold
        ) {
            const childThoughts = await generateChildThoughts(node.thought);
            for (const childThought of childThoughts) {
                const childNode: ThoughtNode = {
                    thought: childThought,
                    children: [],
                    parent: node,
                    depth: node.depth + 1,
                };
                node.children.push(childNode);
                await explore(childNode);
            }
        }
    }

    for (const rootThought of rootThoughts) {
        const rootNode: ThoughtNode = {
            thought: rootThought,
            children: [],
            depth: 0,
        };
        await explore(rootNode);
    }

    return explored;
}

/**
 * Get the path from a node back to the root
 */
function getPathToRoot(node: ThoughtNode): Thought[] {
    const path: Thought[] = [];
    let current: ThoughtNode | undefined = node;

    while (current?.parent) {
        path.unshift(current.parent.thought);
        current = current.parent;
    }

    return path;
}

/**
 * Select the best paths from explored thoughts
 */
export function selectBestPaths(
    explored: ThoughtNode[],
    topK: number = 3
): Thought[][] {
    // Find leaf nodes (nodes with no children or at max depth)
    const leafNodes = explored.filter(node => node.children.length === 0);

    // Score each path by average thought score
    const scoredPaths = leafNodes.map(leaf => {
        const path = [...getPathToRoot(leaf), leaf.thought];
        const avgScore = path.reduce((sum, t) => sum + t.score, 0) / path.length;
        return { path, avgScore };
    });

    // Sort by score and take top K
    scoredPaths.sort((a, b) => b.avgScore - a.avgScore);
    return scoredPaths.slice(0, topK).map(sp => sp.path);
}

/**
 * Aggregate multiple thought paths into a final answer
 */
export async function aggregateResults<T>(
    bestPaths: Thought[][],
    goalDescription: string,
    outputSchema: z.ZodType<T>
): Promise<{ result: T; confidence: number }> {
    const pathDescriptions = bestPaths.map((path, i) =>
        `Path ${i + 1} (avg score: ${(path.reduce((s, t) => s + t.score, 0) / path.length).toFixed(2)}):\n${path.map(t => `  - [${t.dimension}] ${t.content}`).join('\n')}`
    ).join('\n\n');

    const prompt = `Synthesize the best reasoning paths into a final answer.

GOAL:
${goalDescription}

BEST REASONING PATHS:
${pathDescriptions}

Combine insights from these paths into the most effective final answer.
Consider:
1. Common themes across paths
2. Unique insights from high-scoring thoughts
3. Potential conflicts and how to resolve them`;

    const { output } = await ai.generate({
        prompt,
        output: { schema: outputSchema },
    });

    // Calculate overall confidence
    const avgConfidence = bestPaths.flat()
        .reduce((sum, t) => sum + t.confidence, 0) /
        bestPaths.flat().length;

    return {
        result: output!,
        confidence: avgConfidence,
    };
}

// =============================================================================
// HIGH-LEVEL TOT ORCHESTRATOR
// =============================================================================

/**
 * Main ToT orchestrator - runs the full Tree of Thoughts process
 */
export async function runTreeOfThoughts<T>(
    problemDescription: string,
    dimensions: string[],
    goalDescription: string,
    outputSchema: z.ZodType<T>,
    config: Partial<ToTConfig> = {}
): Promise<ToTResult<T>> {
    const fullConfig: ToTConfig = {
        maxDepth: config.maxDepth ?? 2,
        branchingFactor: config.branchingFactor ?? 3,
        evaluationThreshold: config.evaluationThreshold ?? 0.3,
        searchStrategy: config.searchStrategy ?? 'bfs',
    };

    // Step 1: Generate initial thoughts
    const rootThoughts = await generateThoughts(
        problemDescription,
        dimensions,
        'Initial state - beginning analysis',
        fullConfig.branchingFactor
    );

    // Step 2: Search through thought tree
    const generateChildThoughts = async (parentThought: Thought): Promise<Thought[]> => {
        return generateThoughts(
            problemDescription,
            [parentThought.dimension], // Focus on same dimension for depth
            `Building on: ${parentThought.content}`,
            Math.min(2, fullConfig.branchingFactor) // Fewer children at deeper levels
        );
    };

    let explored: ThoughtNode[];
    if (fullConfig.searchStrategy === 'bfs') {
        explored = await bfsSearch(rootThoughts, goalDescription, fullConfig, generateChildThoughts);
    } else {
        explored = await dfsSearch(rootThoughts, goalDescription, fullConfig, generateChildThoughts);
    }

    // Step 3: Select best paths
    const bestPaths = selectBestPaths(explored, 3);

    // Step 4: Aggregate into final answer
    const { result, confidence } = await aggregateResults(
        bestPaths,
        goalDescription,
        outputSchema
    );

    // Count backtracks (thoughts that were evaluated but not explored further)
    const backtrackCount = rootThoughts.length - explored.length;

    return {
        finalAnswer: result,
        bestPath: bestPaths[0] ?? [],
        allPaths: bestPaths,
        totalThoughtsGenerated: explored.length,
        backtrackCount: Math.max(0, backtrackCount),
    };
}

// =============================================================================
// SIMPLIFIED TOT FOR SPECIFIC USE CASES
// =============================================================================

/**
 * Simplified ToT for multi-factor evaluation (e.g., churn prediction)
 */
export async function multiFactorToT<T>(
    factors: { name: string; context: string }[],
    evaluationGoal: string,
    outputSchema: z.ZodType<T>
): Promise<{ result: T; factorScores: Record<string, number>; confidence: number }> {
    const factorScores: Record<string, number> = {};
    const thoughts: Thought[] = [];

    // Evaluate each factor independently
    for (const factor of factors) {
        const prompt = `Analyze this factor for: ${evaluationGoal}

FACTOR: ${factor.name}
CONTEXT: ${factor.context}

Rate this factor's contribution (0-1) and provide reasoning.`;

        const { output } = await ai.generate({
            prompt,
            output: {
                schema: z.object({
                    score: z.number(),
                    reasoning: z.string(),
                    concerns: z.array(z.string()).optional(),
                }),
            },
        });

        factorScores[factor.name] = output?.score ?? 0.5;
        thoughts.push({
            id: `factor_${factor.name}`,
            dimension: factor.name,
            content: output?.reasoning ?? '',
            score: output?.score ?? 0.5,
            confidence: 0.7,
            reasoning: output?.reasoning ?? '',
        });
    }

    // Check for contradictions (backtracking logic)
    const contradictionPrompt = `Check for contradictions in these factor analyses.

FACTORS AND SCORES:
${thoughts.map(t => `- ${t.dimension}: ${t.score.toFixed(2)} - ${t.content}`).join('\n')}

Are there any contradictions that should adjust the final assessment?
Example: High activity but low spending might indicate engaged-but-not-monetizing rather than high risk.`;

    const { output: contradictionCheck } = await ai.generate({
        prompt: contradictionPrompt,
        output: {
            schema: z.object({
                hasContradictions: z.boolean(),
                adjustments: z.array(z.object({
                    factor: z.string(),
                    adjustment: z.number(),
                    reason: z.string(),
                })),
            }),
        },
    });

    // Apply adjustments from backtracking
    if (contradictionCheck?.adjustments) {
        for (const adj of contradictionCheck.adjustments) {
            if (factorScores[adj.factor] !== undefined) {
                factorScores[adj.factor] = Math.min(1, Math.max(0,
                    factorScores[adj.factor] + adj.adjustment
                ));
            }
        }
    }

    // Aggregate final result
    const { result, confidence } = await aggregateResults(
        [thoughts],
        evaluationGoal,
        outputSchema
    );

    return { result, factorScores, confidence };
}

/**
 * Simplified ToT for multi-step verification (e.g., content moderation)
 */
export async function stepwiseToT<T>(
    content: string,
    steps: { name: string; prompt: string }[],
    contextInfo: Record<string, unknown>,
    outputSchema: z.ZodType<T>
): Promise<{ result: T; stepResults: Record<string, unknown>; shouldBlock: boolean }> {
    const stepResults: Record<string, unknown> = {};
    let shouldBlock = false;
    let currentContext = contextInfo;

    for (const step of steps) {
        const stepPrompt = `${step.prompt}

CONTENT: ${content}

CONTEXT:
${JSON.stringify(currentContext, null, 2)}

PREVIOUS STEPS:
${Object.entries(stepResults).map(([k, v]) => `- ${k}: ${JSON.stringify(v)}`).join('\n')}`;

        const { output } = await ai.generate({
            prompt: stepPrompt,
            output: {
                schema: z.object({
                    passed: z.boolean(),
                    severity: z.enum(['none', 'low', 'medium', 'high', 'critical']),
                    reasoning: z.string(),
                    contextUpdate: z.record(z.unknown()).optional(),
                    shouldBacktrack: z.boolean().optional(),
                }),
            },
        });

        stepResults[step.name] = output;

        // Update context for next step
        if (output?.contextUpdate) {
            currentContext = { ...currentContext, ...output.contextUpdate };
        }

        // Check if we should block immediately
        if (!output?.passed && output?.severity === 'critical') {
            shouldBlock = true;
            break;
        }

        // Backtracking: if this step suggests reconsidering previous
        if (output?.shouldBacktrack && step.name !== steps[0].name) {
            // Re-evaluate with new context
            const prevStep = steps[steps.indexOf(step) - 1];
            if (prevStep) {
                // Mark for re-evaluation (in practice, would re-run previous step)
                stepResults[`${prevStep.name}_reconsidered`] = true;
            }
        }
    }

    // Final aggregation
    const { result } = await aggregateResults(
        [[{
            id: 'final',
            dimension: 'aggregated',
            content: JSON.stringify(stepResults),
            score: shouldBlock ? 0 : 1,
            confidence: 0.8,
            reasoning: 'Stepwise analysis complete',
        }]],
        'Determine final moderation decision',
        outputSchema
    );

    return { result, stepResults, shouldBlock };
}

export default {
    generateThoughts,
    evaluateThought,
    bfsSearch,
    dfsSearch,
    selectBestPaths,
    aggregateResults,
    runTreeOfThoughts,
    multiFactorToT,
    stepwiseToT,
};
