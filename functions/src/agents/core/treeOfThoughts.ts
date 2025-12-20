/**
 * Tree of Thoughts (ToT) Reasoning Engine
 * Multi-step reasoning with evaluation and backtracking
 */

import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';
import { createLogger } from '../../utils/logger';
import { BusinessMetrics } from '../../utils/metrics';

const logger = createLogger('treeOfThoughts');

// Initialize Genkit
const ai = genkit({
    plugins: [googleAI()],
    model: gemini20FlashExp,
});

// ============================================
// Types
// ============================================

interface ThoughtNode {
    id: string;
    thought: string;
    evaluation: number;
    confidence: number;
    reasoning: string;
    children: ThoughtNode[];
    depth: number;
}

interface ToTConfig {
    maxDepth: number;
    branchingFactor: number;
    evaluationThreshold: number;
    maxIterations: number;
}

interface ToTResult {
    bestPath: string[];
    confidence: number;
    reasoning: string;
    alternativePaths: string[][];
    totalThoughtsGenerated: number;
    executionTimeMs: number;
}

// ============================================
// Default Configuration
// ============================================

const DEFAULT_CONFIG: ToTConfig = {
    maxDepth: 3,
    branchingFactor: 3,
    evaluationThreshold: 0.4,
    maxIterations: 50,
};

// ============================================
// Core ToT Functions
// ============================================

/**
 * Generate initial thoughts for a problem
 */
async function generateThoughts(
    problem: string,
    context: Record<string, unknown>,
    count: number
): Promise<string[]> {
    const { output } = await ai.generate({
        prompt: `
Problem: ${problem}
Context: ${JSON.stringify(context, null, 2)}

Generate ${count} distinct approaches to solve this problem.
Each approach should be a single clear thought/strategy.
Be creative and consider different angles.
    `,
        output: {
            schema: z.object({
                thoughts: z.array(z.string()).describe('List of distinct approaches'),
            }),
        },
    });

    return output?.thoughts || [];
}

/**
 * Evaluate a thought's quality and viability
 */
async function evaluateThought(
    thought: string,
    problem: string,
    context: Record<string, unknown>
): Promise<{ score: number; reasoning: string; confidence: number }> {
    const { output } = await ai.generate({
        prompt: `
Problem: ${problem}
Proposed Approach: ${thought}
Context: ${JSON.stringify(context, null, 2)}

Evaluate this approach on a scale of 0.0 to 1.0:

Scoring Criteria:
- Feasibility (0.3 weight): Can this be implemented given the constraints?
- Effectiveness (0.4 weight): Will this solve the problem well?
- Safety/Risk (0.3 weight): What are the risks and downsides?

Provide your evaluation with reasoning.
    `,
        output: {
            schema: z.object({
                score: z.number().min(0).max(1),
                reasoning: z.string(),
                confidence: z.number().min(0).max(1),
            }),
        },
    });

    return output || { score: 0.5, reasoning: 'Unable to evaluate', confidence: 0.5 };
}

/**
 * Expand a thought into more specific sub-thoughts
 */
async function expandThought(
    parentThought: string,
    problem: string,
    context: Record<string, unknown>,
    count: number
): Promise<string[]> {
    const { output } = await ai.generate({
        prompt: `
Problem: ${problem}
Current Approach: ${parentThought}
Context: ${JSON.stringify(context, null, 2)}

Expand this approach into ${count} more specific sub-strategies.
Each sub-strategy should be a concrete next step building on the parent approach.
    `,
        output: {
            schema: z.object({
                subThoughts: z.array(z.string()),
            }),
        },
    });

    return output?.subThoughts || [];
}

/**
 * Build thought tree recursively
 */
async function buildThoughtTree(
    problem: string,
    context: Record<string, unknown>,
    config: ToTConfig,
    currentDepth: number = 0,
    parentThought: string | null = null,
    iterationCount: { value: number } = { value: 0 }
): Promise<ThoughtNode[]> {
    // Check iteration limit
    if (iterationCount.value >= config.maxIterations) {
        return [];
    }

    // Check depth limit
    if (currentDepth >= config.maxDepth) {
        return [];
    }

    // Generate thoughts (initial or expanded)
    const thoughts = parentThought
        ? await expandThought(parentThought, problem, context, config.branchingFactor)
        : await generateThoughts(problem, context, config.branchingFactor);

    const nodes: ThoughtNode[] = [];

    for (const thought of thoughts) {
        iterationCount.value++;
        if (iterationCount.value >= config.maxIterations) break;

        // Evaluate thought
        const evaluation = await evaluateThought(thought, problem, context);

        // Prune low-quality thoughts (backtracking)
        if (evaluation.score < config.evaluationThreshold) {
            logger.debug(`Pruned thought: ${thought.substring(0, 50)}...`, { score: evaluation.score });
            continue;
        }

        const node: ThoughtNode = {
            id: `t${currentDepth}_${nodes.length}`,
            thought,
            evaluation: evaluation.score,
            confidence: evaluation.confidence,
            reasoning: evaluation.reasoning,
            children: [],
            depth: currentDepth,
        };

        // Recursively build children
        if (currentDepth < config.maxDepth - 1 && evaluation.score > 0.6) {
            node.children = await buildThoughtTree(
                problem,
                context,
                config,
                currentDepth + 1,
                thought,
                iterationCount
            );
        }

        nodes.push(node);
    }

    return nodes;
}

/**
 * Find best path through thought tree
 */
function findBestPath(nodes: ThoughtNode[]): { path: string[]; score: number; reasoning: string } {
    let bestPath: string[] = [];
    let bestScore = 0;
    let bestReasoning = '';

    function traverse(node: ThoughtNode, currentPath: string[], currentScore: number) {
        const newPath = [...currentPath, node.thought];
        const newScore = (currentScore + node.evaluation) / newPath.length;

        if (node.children.length === 0) {
            // Leaf node - check if best
            if (newScore > bestScore) {
                bestPath = newPath;
                bestScore = newScore;
                bestReasoning = node.reasoning;
            }
        } else {
            // Continue traversal
            for (const child of node.children) {
                traverse(child, newPath, currentScore + node.evaluation);
            }
        }
    }

    for (const node of nodes) {
        traverse(node, [], 0);
    }

    return { path: bestPath, score: bestScore, reasoning: bestReasoning };
}

/**
 * Find alternative paths for comparison
 */
function findAlternativePaths(nodes: ThoughtNode[], count: number): string[][] {
    const allPaths: { path: string[]; score: number }[] = [];

    function collectPaths(node: ThoughtNode, currentPath: string[], currentScore: number) {
        const newPath = [...currentPath, node.thought];
        const newScore = (currentScore + node.evaluation);

        if (node.children.length === 0) {
            allPaths.push({ path: newPath, score: newScore / newPath.length });
        } else {
            for (const child of node.children) {
                collectPaths(child, newPath, newScore);
            }
        }
    }

    for (const node of nodes) {
        collectPaths(node, [], 0);
    }

    // Sort by score and return top N (excluding best)
    return allPaths
        .sort((a, b) => b.score - a.score)
        .slice(1, count + 1)
        .map((p) => p.path);
}

// ============================================
// Main ToT Flow
// ============================================

export const treeOfThoughtsFlow = ai.defineFlow(
    {
        name: 'treeOfThoughts',
        inputSchema: z.object({
            problem: z.string().describe('The problem to solve'),
            context: z.record(z.unknown()).describe('Additional context'),
            config: z.object({
                maxDepth: z.number().optional(),
                branchingFactor: z.number().optional(),
                evaluationThreshold: z.number().optional(),
                maxIterations: z.number().optional(),
            }).optional(),
        }),
        outputSchema: z.object({
            bestPath: z.array(z.string()),
            confidence: z.number(),
            reasoning: z.string(),
            alternativePaths: z.array(z.array(z.string())),
            totalThoughtsGenerated: z.number(),
            executionTimeMs: z.number(),
        }),
    },
    async (input): Promise<ToTResult> => {
        const startTime = Date.now();
        const config: ToTConfig = { ...DEFAULT_CONFIG, ...input.config };
        const iterationCount = { value: 0 };

        logger.info('Starting Tree of Thoughts', {
            problem: input.problem.substring(0, 100),
            config,
        });

        try {
            // Build thought tree
            const thoughtTree = await buildThoughtTree(
                input.problem,
                input.context,
                config,
                0,
                null,
                iterationCount
            );

            // Find best and alternative paths
            const best = findBestPath(thoughtTree);
            const alternatives = findAlternativePaths(thoughtTree, 3);

            const executionTimeMs = Date.now() - startTime;

            // Track metrics
            await BusinessMetrics.aiAgentAction('treeOfThoughts', 'reason', executionTimeMs);

            logger.info('Tree of Thoughts complete', {
                bestPathLength: best.path.length,
                confidence: best.score,
                thoughtsGenerated: iterationCount.value,
                executionTimeMs,
            });

            return {
                bestPath: best.path,
                confidence: best.score,
                reasoning: best.reasoning,
                alternativePaths: alternatives,
                totalThoughtsGenerated: iterationCount.value,
                executionTimeMs,
            };
        } catch (error) {
            logger.error('Tree of Thoughts failed', error as Error);
            throw error;
        }
    }
);

export default treeOfThoughtsFlow;
