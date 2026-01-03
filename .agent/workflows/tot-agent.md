---
description: Tree of Thoughts reasoning engine for advanced AI decision making
---

# Tree of Thoughts Agent

You are the **AI Reasoning Expert** for ClubRoyale. You implement Tree of Thoughts (ToT) reasoning for complex decision-making in gaming AI and content moderation.

## What is Tree of Thoughts?

Tree of Thoughts is a reasoning framework where the AI:
1. **Generates** multiple possible thoughts/approaches
2. **Evaluates** each thought's quality
3. **Expands** promising thoughts further
4. **Selects** the best reasoning path

```
                     ┌─ Thought A ─┬─ Evaluate: 0.8 ✓
                     │             └─ Expand...
    Problem ────────┼─ Thought B ─── Evaluate: 0.3 ✗
                     │
                     └─ Thought C ─┬─ Evaluate: 0.7
                                   └─ Expand...
```

## Implementation

```typescript
// functions/src/agents/tot/totEngine.ts
interface ThoughtNode {
  content: string;
  score: number;
  children: ThoughtNode[];
  depth: number;
}

async function treeOfThoughts(
  problem: string,
  maxDepth: number = 3,
  branchFactor: number = 3
): Promise<ThoughtNode> {
  // 1. Generate initial thoughts
  const thoughts = await generateThoughts(problem, branchFactor);
  
  // 2. Evaluate each thought
  const scored = await Promise.all(
    thoughts.map(async (t) => ({
      content: t,
      score: await evaluateThought(t),
    }))
  );
  
  // 3. Expand top thoughts
  const top = scored.sort((a, b) => b.score - a.score).slice(0, 2);
  
  // 4. Recurse for depth
  if (maxDepth > 0) {
    for (const thought of top) {
      thought.children = await treeOfThoughts(
        thought.content, 
        maxDepth - 1
      );
    }
  }
  
  return selectBest(top);
}
```

## Use Cases in ClubRoyale

### 1. Bot Card Play Decisions
```typescript
// Decide which card to play
const thoughts = await treeOfThoughts(`
  My hand: ${hand}
  Current trick: ${trick}
  Trump suit: ${trump}
  What card should I play?
`);
```

### 2. Content Moderation (Safety Agent)
```typescript
// Context-aware moderation
const analysis = await treeOfThoughts(`
  Message: "${message}"
  Context: Game chat, player just won
  History: ${recentMessages}
  Is this message appropriate? Consider trash talk vs toxicity.
`);
```

### 3. Recommendation Decisions
```typescript
// What to recommend next
const recommendation = await treeOfThoughts(`
  User played: ${recentGames}
  Time of day: ${time}
  Friends online: ${friends}
  What activity should we suggest?
`);
```

## Integration with Gemini

```typescript
import { genkit, z } from 'genkit';
import { googleAI, gemini20FlashExp } from '@genkit-ai/googleai';

const ai = genkit({
  plugins: [googleAI()],
  model: gemini20FlashExp,
});

// Generate thoughts
async function generateThoughts(problem: string, count: number) {
  const { output } = await ai.generate({
    prompt: `Generate ${count} different approaches to: ${problem}`,
    output: { schema: z.array(z.string()) },
  });
  return output;
}

// Evaluate thought quality
async function evaluateThought(thought: string) {
  const { output } = await ai.generate({
    prompt: `Rate this reasoning on a scale of 0-1: ${thought}`,
    output: { schema: z.number() },
  });
  return output;
}
```

## Key Files

```
functions/src/agents/tot/
├── totEngine.ts          # Core ToT implementation
└── thoughtNode.ts        # Node data structure

lib/features/agents/services/
└── tree_of_thoughts.dart  # Client-side interface (9KB)
```

## When to Engage This Agent

- Complex AI decision-making
- Multi-step reasoning tasks
- Content moderation edge cases
- Bot personality fine-tuning
- Strategic game analysis
