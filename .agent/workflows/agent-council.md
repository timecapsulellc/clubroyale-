---
description: Multi-Agent Council for collaborative validation, debate, and approval of game implementations
---

# AI Agent Council Framework

> **Mission**: Establish a world-class validation and approval system for ClubRoyale's card game UI/UX, mechanics, and codebase through structured AI agent collaboration.

## Council Structure (Minimum Viable Team)

```
                    ┌─────────────────────┐
                    │   CHIEF ARCHITECT   │ ← Final Authority
                    │   /chief-architect  │
                    └──────────┬──────────┘
           ┌───────────────────┼───────────────────┐
           │                   │                   │
    ┌──────▼──────┐    ┌───────▼───────┐   ┌──────▼──────┐
    │  DEVELOPER  │    │   REVIEWER    │   │     QA      │
    │ /card-engine│    │ /code-quality │   │ /testing-qa │
    └─────────────┘    └───────────────┘   └─────────────┘
           │                   │                   │
           └───────────────────┴───────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  SPECIALIZED AGENTS │ (On-Demand)
                    │  /ui-ux-designer    │
                    │  /game-mechanics    │
                    │  /bot-ai            │
                    └─────────────────────┘
```

## Core Agent Roles

### 1. Chief Architect (Orchestrator)
**Workflow**: `/chief-architect`  
**Responsibilities**:
- Receives incoming task/feature request
- Decomposes into subtasks for council
- Manages debate rounds
- Resolves conflicts between agents
- Issues final approval or veto

### 2. Primary Developer (Implementer)
**Workflow**: `/card-engine` + `/game-mechanics`  
**Responsibilities**:
- Proposes implementation approach
- Writes code changes
- Defends design decisions during debate
- Iterates based on council feedback

### 3. Code Reviewer (Critic)
**Workflow**: `/code-quality`  
**Responsibilities**:
- Reviews code for quality, patterns, security
- Identifies anti-patterns and tech debt
- Proposes alternative implementations
- Scores changes (1-10) with detailed rationale

### 4. QA Agent (Validator)
**Workflow**: `/testing-qa`  
**Responsibilities**:
- Designs verification strategy
- Executes automated tests
- Performs manual validation
- Reports bugs and edge cases
- Signs off on production readiness

## Council Workflow Protocol

### Phase 1: Task Intake (Architect)
```markdown
1. Architect receives task from user
2. Architect decomposes into:
   - Functional requirements
   - Non-functional requirements (performance, UX)
   - Acceptance criteria
3. Architect assigns to Developer
```

### Phase 2: Implementation (Developer)
```markdown
1. Developer researches codebase
2. Developer proposes RFC (Request for Comments):
   - Approach summary
   - Files to modify
   - Risks and trade-offs
3. RFC posted for council review
```

### Phase 3: Debate Round (All Agents)
```markdown
DEBATE PROTOCOL:
├── Round 1: Initial Positions (Each agent states concerns)
│   ├── Reviewer: Code quality issues?
│   ├── QA: Testability concerns?
│   └── Specialist: Domain-specific issues?
│
├── Round 2: Cross-Examination
│   ├── Developer defends approach
│   ├── Agents question specific decisions
│   └── Alternative solutions proposed
│
└── Round 3: Consensus Building
    ├── Agents vote: APPROVE / REQUEST_CHANGES / BLOCK
    ├── Blocking vote requires justification
    └── Architect mediates unresolved conflicts
```

### Phase 4: Iteration (Developer + Reviewers)
```markdown
1. Developer addresses feedback
2. Targeted re-review by concerned agents
3. Repeat until consensus reached
```

### Phase 5: Verification (QA)
```markdown
1. QA executes test plan
2. QA verifies acceptance criteria
3. QA signs off or reports blockers
```

### Phase 6: Approval (Architect)
```markdown
1. Architect reviews council deliberations
2. Architect issues final verdict:
   - APPROVED: Ready for merge
   - CONDITIONAL: Needs minor fixes (no re-debate)
   - REJECTED: Fundamental issues, restart
```

## Voting System

| Vote | Meaning | Required For |
|------|---------|--------------|
| ✅ APPROVE | No concerns | Merge |
| 🔄 REQUEST_CHANGES | Minor issues | Iteration |
| 🚫 BLOCK | Critical issues | Debate resolution |

**Approval Threshold**: 3/4 agents must APPROVE (Architect can override with justification)

## Specialized Agent Pool

Invoke on-demand based on task type:

| Task Type | Specialist Agent |
|-----------|------------------|
| UI/UX changes | `/ui-ux-designer` |
| Game rule logic | `/game-mechanics` |
| Bot AI behavior | `/bot-ai` |
| Animation/effects | `/animation-effects` |
| Multiplayer sync | `/multiplayer-sync` |
| Economy/rewards | `/economy-rewards` |
| Analytics | `/analytics-insights` |

## Tree of Thoughts Integration

For complex decisions, agents use `/tot-agent` reasoning:

```
Problem: "Should we use packet dealing for 8 players?"

┌─ Thought A: Individual animations (realism)
│   ├─ Eval: 0.4 (performance concerns)
│   └─ REJECT
│
├─ Thought B: Packet dealing (performance)
│   ├─ Eval: 0.8 (good balance)
│   └─ EXPAND → Sub-thoughts on packet size
│
└─ Thought C: Skip animation entirely
    ├─ Eval: 0.2 (poor UX)
    └─ REJECT
```

## Debate Example

**Task**: Add Nepali localization  
**Developer RFC**: Use internal JSON map with `flutter_riverpod`

```
┌─ REVIEW ROUND ─────────────────────────────────────────┐
│                                                        │
│ 🏗️ ARCHITECT:                                         │
│ "Proposal is clean. Concern: scalability for 10+ langs"│
│                                                        │
│ 🔍 REVIEWER:                                           │
│ "Using .tr(ref) extension is elegant. +1."             │
│ "Consider: ARB files for professional translation."    │
│                                                        │
│ 🧪 QA:                                                 │
│ "How do we test Nepali rendering? Need font fallback." │
│ "Add unit test for all string keys."                   │
│                                                        │
│ 🎨 UI/UX SPECIALIST (called in):                       │
│ "Nepali chars are wider. Check button overflow."       │
│                                                        │
├─ VOTES ────────────────────────────────────────────────┤
│ Architect: ✅ APPROVE                                  │
│ Reviewer:  🔄 REQUEST_CHANGES (want ARB consideration) │
│ QA:        ✅ APPROVE (with font test note)            │
│ UI/UX:     ✅ APPROVE                                  │
├─ RESULT ───────────────────────────────────────────────┤
│ APPROVED with conditions:                              │
│ 1. Add note in docs about ARB migration path           │
│ 2. QA to verify font rendering on Android              │
└────────────────────────────────────────────────────────┘
```

## How to Invoke the Council

### Option 1: Full Council Review
```
/chief-architect review [task description]
```
Triggers full debate workflow for major changes.

### Option 2: Quick Validation
```
/testing-qa validate [feature]
```
QA-only verification for minor changes.

### Option 3: Specialized Consultation
```
/ui-ux-designer audit [screen/component]
```
Single-agent feedback without full council.

## Implementation Artifacts

Council sessions produce:
1. **RFC Document**: Developer's proposal
2. **Debate Transcript**: Agent positions and votes
3. **Decision Record**: Final verdict with rationale
4. **Action Items**: Required changes before merge

## Best Practices

1. **Don't skip debate for "small" changes** — Small changes cause big bugs
2. **Document blocking votes** — Future reference for similar decisions
3. **Rotate devil's advocate** — Prevents groupthink
4. **Time-box debates** — Max 3 rounds, then Architect decides
5. **Celebrate consensus** — Builds team culture

---

## Quick Start Checklist

- [ ] User submits task
- [ ] Architect decomposes and assigns
- [ ] Developer posts RFC
- [ ] Council debates (3 rounds max)
- [ ] Developer iterates
- [ ] QA verifies
- [ ] Architect approves
- [ ] Changes merged
