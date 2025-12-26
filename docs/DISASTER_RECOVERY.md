# ClubRoyale Disaster Recovery Plan

## Overview
This document outlines the disaster recovery procedures for ClubRoyale to ensure business continuity in case of system failures.

---

## 1. Infrastructure Recovery

### Firebase Services
| Service | Recovery Time | Backup Strategy |
|---------|--------------|-----------------|
| Firestore | < 1 hour | Automatic daily backups |
| Auth | N/A | Managed by Google |
| Storage | < 1 hour | Cross-region replication |
| Hosting | < 5 min | Rollback to previous version |
| Functions | < 10 min | Redeploy from git |

### Backup Schedule
- **Firestore**: Automatic daily exports to Cloud Storage
- **User Data**: GDPR export available on-demand
- **Codebase**: Git repository (GitHub)

---

## 2. Recovery Procedures

### 2.1 Website Down
1. Check Firebase Hosting status
2. Verify `build/web` exists
3. Redeploy: `firebase deploy --only hosting`
4. Test at https://clubroyale-staging.web.app

### 2.2 Cloud Functions Failing
1. Check Firebase Functions logs
2. Identify failing function
3. Fix code and rebuild: `cd functions && npm run build`
4. Redeploy: `firebase deploy --only functions`

### 2.3 Database Corruption
1. Stop client writes (maintenance mode)
2. Identify last good backup in Cloud Storage
3. Restore using `gcloud firestore import`
4. Verify data integrity
5. Resume operations

### 2.4 Authentication Issues
1. Check Firebase Auth console
2. Verify OAuth providers are configured
3. Test sign-in flows
4. Clear client-side auth cache if needed

---

## 3. Monitoring & Alerts

### Health Checks
- Firebase Console: https://console.firebase.google.com
- Cloud Monitoring Dashboard
- Sentry Error Tracking (if configured)

### Alert Thresholds
| Metric | Warning | Critical |
|--------|---------|----------|
| Error Rate | > 1% | > 5% |
| Latency (p95) | > 2s | > 5s |
| Function Cold Starts | > 20% | > 40% |

---

## 4. Contact Information

### Escalation Path
1. **Level 1**: Check Firebase Console
2. **Level 2**: Review Cloud Logs
3. **Level 3**: Contact Firebase Support

### Key URLs
- Firebase Console: https://console.firebase.google.com/project/clubroyale-staging
- GitHub Repo: https://github.com/timecapsulellc/TaasClub
- Live App: https://clubroyale-staging.web.app

---

## 5. Post-Incident Review

After any incident:
1. Document timeline of events
2. Identify root cause
3. Implement preventive measures
4. Update this document if needed

---

**Last Updated**: December 26, 2025  
**Version**: 1.0
