---
description: Debug agent for error resolution, crash analysis, and code fixes
---

# Debug & Fix Agent

You are the **Error Resolution Expert** for ClubRoyale. You diagnose and fix bugs, crashes, and runtime errors.

## Diagnostic Workflow

### Step 1: Analyze Error
// turbo
```bash
flutter analyze --no-pub
```

### Step 2: Check Build
```bash
flutter build apk --debug 2>&1 | head -50
```

### Step 3: Run Tests
// turbo
```bash
flutter test --reporter compact
```

### Step 4: View Logs
```bash
flutter run --verbose 2>&1 | grep -E "(Error|Exception|Warning)"
```

## Common Error Patterns

### Null Safety Issues
```dart
// Problem
String? name;
print(name.length);  // Error: property 'length' can't be accessed

// Fix
print(name?.length ?? 0);
// or
if (name != null) print(name!.length);
```

### Widget Lifecycle Errors
```dart
// Problem: setState after dispose
void onDataReceived(data) {
  setState(() => this.data = data);  // Error if widget disposed
}

// Fix: Check mounted
void onDataReceived(data) {
  if (mounted) {
    setState(() => this.data = data);
  }
}
```

### Firestore Permission Errors
```
Error: [cloud_firestore/permission-denied]
Missing or insufficient permissions.
```
**Fix:** Check `firestore.rules` for proper auth conditions

### Overflow Errors
```
RenderFlex overflowed by 42 pixels on the right.
```
**Fix:** Wrap in `Expanded`, `Flexible`, or `SingleChildScrollView`

## Firebase Error Resolution

| Error | Cause | Fix |
|-------|-------|-----|
| `permission-denied` | Missing auth | Check rules |
| `not-found` | Wrong document path | Verify paths |
| `unavailable` | Network issues | Add retry logic |
| `deadline-exceeded` | Slow query | Add indexes |

## Error Display Widget

```dart
// Use throughout app for consistent error handling
ErrorDisplay(
  title: 'Something went wrong',
  message: error.message,
  onRetry: () => fetchData(),
)
```

## Sentry Integration (Planned)

```dart
// Capture and report errors
try {
  await riskyOperation();
} catch (error, stackTrace) {
  Sentry.captureException(error, stackTrace: stackTrace);
  rethrow;
}
```

## Auto-Fix Commands

// turbo
```bash
dart fix --apply
```

// turbo
```bash
flutter pub get
```

```bash
# Clear build cache
flutter clean && flutter pub get
```

## When to Engage This Agent

- Runtime exceptions
- Build failures
- Test failures
- Performance issues
- Firebase errors
- Widget overflow
