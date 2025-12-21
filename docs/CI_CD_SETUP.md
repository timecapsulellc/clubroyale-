# ClubRoyale Infrastructure Setup Guide
## CI/CD, Staging & Monitoring Configuration

---

## CI/CD Pipeline (✅ Complete)

The GitHub Actions CI/CD pipeline is fully configured in `.github/workflows/`:

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| `ci.yml` | Full CI/CD with tests, builds, deploy | Push to main |
| `staging.yml` | Staging deployment | Push to develop |

### Required GitHub Secrets

Set these in **Settings → Secrets and variables → Actions**:

| Secret | Purpose | How to Get |
|--------|---------|------------|
| `FIREBASE_TOKEN` | Production deploy | `firebase login:ci` |
| `FIREBASE_TOKEN_STAGING` | Staging deploy | Same, use staging project |
| `SLACK_WEBHOOK_URL` | Alert notifications | Slack App Webhook |

### Firebase CLI Token Setup

```bash
# Generate Firebase CI token
firebase login:ci

# Copy the token and add to GitHub secrets
```

---

## Staging Environment

### Setup Steps

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create new project: `clubroyale-staging`
   - Enable: Firestore, Auth, Functions, Hosting

2. **Copy Security Rules**
   ```bash
   # Deploy rules to staging
   firebase use staging
   firebase deploy --only firestore:rules
   ```

3. **Configure `.firebaserc`** (✅ Already done)
   ```json
   {
     "projects": {
       "default": "taasclub-app",
       "production": "taasclub-app",
       "staging": "clubroyale-staging"
     }
   }
   ```

4. **Environment Variables**
   - Create `.env.staging` with staging API keys
   - Pass via `--dart-define=ENV=staging`

---

## Cloud Monitoring Dashboards

### Manual Setup in Google Cloud Console

1. Go to **Monitoring → Dashboards → Create**
2. Add these widgets:

| Widget | Metric |
|--------|--------|
| Function Invocations | `cloudfunctions.googleapis.com/function/execution_count` |
| Function Latency | `cloudfunctions.googleapis.com/function/execution_times` |
| Function Errors | `cloudfunctions.googleapis.com/function/execution_count` (filter: status != ok) |
| Firestore Reads | `firestore.googleapis.com/document/read_count` |
| Firestore Writes | `firestore.googleapis.com/document/write_count` |
| Hosting Requests | `firebase.googleapis.com/hosting/request_count` |

---

## Structured Logging (✅ Complete)

The `Logger` class in `functions/src/utils/logger.ts` provides:

- JSON structured logs for Cloud Logging
- Request tracing with `traceId`
- User context with `userId`
- Error stack traces
- Environment-aware formatting

### Usage

```typescript
import { createLogger } from './utils/logger';

const logger = createLogger('functionName', userId);

logger.info('Operation started', { gameId: '123' });
logger.error('Failed to process', error, { context: 'data' });
```

---

## Alerting Configuration

### Slack Integration

1. **Create Slack App**
   - Go to [Slack API](https://api.slack.com/apps)
   - Create app → Add Incoming Webhook
   - Select channel (e.g., `#clubroyale-alerts`)
   - Copy webhook URL

2. **Add to GitHub Secrets**
   - `SLACK_WEBHOOK_URL` = webhook URL

### Cloud Monitoring Alerts

Create these alert policies in **Monitoring → Alerting**:

| Alert | Condition | Channel |
|-------|-----------|---------|
| High Error Rate | Error rate > 1% for 5min | Slack |
| High Latency | P99 latency > 5s for 5min | Slack |
| Quota Warning | Firestore ops > 80% quota | Email |
| Function Failure | Any function fails | Slack |

---

## Infrastructure Checklist

| Item | Status |
|------|--------|
| CI/CD Pipeline | ✅ Complete |
| Staging Environment | ✅ Configured (needs project creation) |
| Structured Logging | ✅ Complete |
| Cloud Monitoring | 📋 Manual setup needed |
| Alerting | 📋 Manual setup needed |

---

**Last Updated:** December 21, 2025
