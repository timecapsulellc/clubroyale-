# Google Play Data Safety Declaration

Complete this form in the Google Play Console for your Data Safety section.

---

## Overview

| Question | Answer |
|----------|--------|
| Does your app collect or share any user data types? | **Yes** |
| Is all collected data encrypted in transit? | **Yes** |
| Do you provide a way for users to request data deletion? | **Yes** |

---

## Data Types Collected

### Account Info

| Data Type | Collected | Shared | Purpose | Optional |
|-----------|-----------|--------|---------|----------|
| Email address | ✅ Yes | ❌ No | Account authentication | ❌ Required |
| User ID | ✅ Yes | ❌ No | App functionality | ❌ Required |
| Display name | ✅ Yes | ✅ Yes (other players) | App functionality | ❌ Required |

### App Activity

| Data Type | Collected | Shared | Purpose | Optional |
|-----------|-----------|--------|---------|----------|
| Game scores | ✅ Yes | ✅ Yes (other players) | App functionality | ❌ Required |
| In-app actions | ✅ Yes | ❌ No | Analytics | ❌ Required |

### App Info and Performance

| Data Type | Collected | Shared | Purpose | Optional |
|-----------|-----------|--------|---------|----------|
| Crash logs | ✅ Yes | ❌ No | Analytics | ❌ Required |
| Performance data | ✅ Yes | ❌ No | Analytics | ❌ Required |

### Financial Info

| Data Type | Collected | Shared | Purpose | Optional |
|-----------|-----------|--------|---------|----------|
| Purchase history | ✅ Yes | ❌ No | App functionality | ✅ Optional |

---

## Data NOT Collected

We do **NOT** collect:
- ❌ Precise location (GPS)
- ❌ Approximate location
- ❌ Contacts
- ❌ Phone number
- ❌ SMS/MMS messages
- ❌ Photos or videos
- ❌ Audio recordings
- ❌ Files
- ❌ Calendar
- ❌ Health info
- ❌ Fitness info
- ❌ Web browsing history
- ❌ Credit/debit card numbers
- ❌ Bank account info

---

## Data Handling Practices

### Security

| Practice | Status |
|----------|--------|
| Data encrypted in transit | ✅ Yes (HTTPS/TLS) |
| Data encrypted at rest | ✅ Yes (Firebase encryption) |
| Secure authentication | ✅ Yes (Firebase Auth) |

### User Control

| Feature | Status |
|---------|--------|
| Request data deletion | ✅ Available (email support) |
| Opt-out of analytics | ✅ Available (in settings) |
| Account deletion | ✅ Available |

---

## Third-Party Services

| Service | Data Shared | Purpose |
|---------|-------------|---------|
| Firebase (Google) | User ID, email, usage data | Backend, auth, analytics |
| RevenueCat | Purchase info, user ID | Payment processing |
| Firebase Crashlytics | Crash logs, device info | Crash reporting |

---

## Data Retention

| Data Type | Retention Period |
|-----------|------------------|
| Account data | Until account deletion |
| Game history | 2 years |
| Purchase records | 7 years (legal requirement) |
| Crash logs | 90 days |

---

## Privacy Policy Link

https://taasclub.app/privacy

(Host the PRIVACY_POLICY.md content at this URL)

---

## Responses for Play Console Questions

### Does your app collect user data?
**Yes**

### Is all of the user data collected by your app encrypted in transit?
**Yes**

### Do you provide a way for users to request that their data is deleted?
**Yes** - Users can request deletion by emailing privacy@taasclub.app

### What is the minimum Android API level?
**API 21 (Android 5.0 Lollipop)**

### Does your app contain ads?
**No**

### Is your app designed specifically for children?
**No** - App is intended for users 18+

### Does your app offer gambling with real money?
**No** - This is a social entertainment app with no real-money gambling

### Does your app contain simulated gambling?
**Yes** - Card games with virtual currency (no cash value)
