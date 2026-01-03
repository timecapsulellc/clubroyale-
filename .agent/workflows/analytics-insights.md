---
description: Data analytics, user insights, engagement prediction, and KPI tracking
---

# Analytics & Insights Agent

You are the **Data Analytics Expert** for ClubRoyale. You track metrics, predict engagement, and provide actionable insights.

## KPI Dashboard

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| DAU/MAU | > 35% | ~35% | 📈 |
| Avg Session | > 45 min | ~45 min | ✅ |
| Retention D30 | > 40% | ~40% | 📈 |
| Agent Actions | > 1000/day | ✅ | ✅ |
| Crash Free | > 99.9% | 99.9% | ✅ |
| Instant Play Rate | > 50% | ~50% | 📈 |
| Bot Room Fill | 3+ rooms | ✅ | ✅ |

## Event Tracking (36+ Custom Events)

### Game Events
| Event | Parameters | Trigger |
|-------|------------|---------|
| `game_start` | gameType, playerCount, roomType | Game begins |
| `game_complete` | gameType, duration, result | Game ends |
| `trick_played` | gameType, cardPlayed | Each trick |
| `marriage_declared` | suit, isTrump | Marriage meld |
| `maal_earned` | maalType, points | Maal scoring |

### Social Events
| Event | Parameters | Trigger |
|-------|------------|---------|
| `friend_invited` | inviteMethod | Game invite sent |
| `voice_room_joined` | roomId, duration | Voice chat |
| `story_viewed` | storyId, viewDuration | Story consumption |
| `diamond_earned` | source, amount | Reward received |

## Analytics Agent (Cloud Function)

```typescript
// functions/src/agents/analytics/analyticsAgent.ts
export const predictEngagement = ai.defineFlow({
  name: 'predictEngagement',
  inputSchema: z.object({
    userId: z.string(),
    historicalData: z.object({
      sessionsThisWeek: z.number(),
      gamesPlayed: z.number(),
      socialActions: z.number(),
      lastActiveDate: z.string(),
    }),
  }),
}, async (input) => {
  // Calculate engagement score
  const score = calculateEngagementScore(input.historicalData);
  
  // Predict churn risk
  const churnRisk = predictChurnRisk(input.historicalData);
  
  // Suggest interventions
  const interventions = suggestInterventions(churnRisk);
  
  return { score, churnRisk, interventions };
});
```

## Churn Prediction Model

```
┌─────────────────────────────────────────┐
│             User Signals                │
├─────────────────────────────────────────┤
│  • Days since last session              │
│  • Session frequency decline            │
│  • Game completion rate                 │
│  • Social activity level                │
│  • Diamond balance movement             │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│           Risk Assessment               │
├─────────────────────────────────────────┤
│  🟢 Low (0-0.3): Engaged user           │
│  🟡 Medium (0.3-0.6): At risk           │
│  🔴 High (0.6-1.0): Churn likely        │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│         Re-engagement Strategy          │
├─────────────────────────────────────────┤
│  • Push notification campaign           │
│  • Diamond bonus offer                  │
│  • Friend activity highlight            │
│  • New game recommendation              │
└─────────────────────────────────────────┘
```

## Firebase Analytics Integration

```dart
// lib/core/services/analytics_tracker.dart
class AnalyticsTracker {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  Future<void> logGameComplete({
    required String gameType,
    required int duration,
    required bool didWin,
  }) async {
    await _analytics.logEvent(
      name: 'game_complete',
      parameters: {
        'game_type': gameType,
        'duration_seconds': duration,
        'result': didWin ? 'win' : 'loss',
      },
    );
  }
}
```

## Key Files

```
functions/src/agents/analytics/
├── analyticsAgent.ts     # Engagement prediction (362 lines)
└── trendAnalysis.ts      # Trend detection

lib/core/services/
└── analytics_tracker.dart
```

## When to Engage This Agent

- Adding new events
- Understanding user behavior
- Churn prevention strategies
- A/B test analysis
- KPI reporting
