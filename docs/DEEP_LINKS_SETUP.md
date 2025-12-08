# Deep Links Setup Guide

Complete setup for Android App Links and iOS Universal Links.

---

## Android App Links

### Step 1: Get SHA256 Fingerprint

```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256

# For release keystore
keytool -list -v -keystore /path/to/release.keystore -alias your_alias | grep SHA256
```

Example output:
```
SHA256: 14:6D:E9:83:54:B4:...
```

### Step 2: Update assetlinks.json

Edit `web/.well-known/assetlinks.json`:

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "app.taasclub",
    "sha256_cert_fingerprints": [
      "14:6D:E9:83:54:B4:YOUR_ACTUAL_FINGERPRINT_HERE"
    ]
  }
}]
```

### Step 3: Deploy to Firebase Hosting

The file is already in `web/.well-known/` and will be deployed with:

```bash
firebase deploy --only hosting
```

### Step 4: Verify Deployment

Check URL: `https://taasclub-app.web.app/.well-known/assetlinks.json`

### Step 5: Update AndroidManifest.xml

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<activity android:name=".MainActivity" ...>
  <!-- Existing intent-filters -->
  
  <!-- Deep link intent filter -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https" 
          android:host="taasclub.app" 
          android:pathPrefix="/join"/>
    <data android:scheme="https" 
          android:host="taasclub-app.web.app" 
          android:pathPrefix="/join"/>
  </intent-filter>
</activity>
```

---

## iOS Universal Links

### Step 1: Get Team ID

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Find your Team ID in Membership section

### Step 2: Update apple-app-site-association

Edit `web/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.app.taasclub",
        "paths": ["/join/*", "/invite/*", "/room/*"]
      }
    ]
  },
  "webcredentials": {
    "apps": ["TEAM_ID.app.taasclub"]
  }
}
```

Replace `TEAM_ID` with your actual Apple Team ID (e.g., `ABC123DEF4`).

### Step 3: Configure Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** target → **Signing & Capabilities**
3. Add **Associated Domains** capability
4. Add domains:
   - `applinks:taasclub.app`
   - `applinks:taasclub-app.web.app`

### Step 4: Deploy and Verify

```bash
firebase deploy --only hosting
```

Check: `https://taasclub-app.web.app/.well-known/apple-app-site-association`

---

## Flutter Deep Link Handling

### Add go_router Configuration

```dart
// lib/router/app_router.dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    // ... existing routes
    
    // Deep link route
    GoRoute(
      path: '/join',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return JoinRoomScreen(token: token);
      },
    ),
  ],
);
```

### Handle Incoming Links

```dart
// lib/core/deep_links/deep_link_handler.dart
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  
  Future<void> initialize() async {
    // Handle link if app was opened from link
    final initialLink = await _appLinks.getInitialAppLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }
    
    // Listen for links while app is running
    _appLinks.uriLinkStream.listen(_handleLink);
  }
  
  void _handleLink(Uri uri) {
    if (uri.path.startsWith('/join')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        // Navigate to join flow
        NavigationService.navigateTo('/join?token=$token');
      }
    }
  }
}
```

### Add Dependency

```bash
flutter pub add app_links
```

---

## Testing Deep Links

### Android Testing

```bash
# Test deep link via adb
adb shell am start -a android.intent.action.VIEW \
  -d "https://taasclub-app.web.app/join?token=test123" \
  app.taasclub
```

### iOS Testing

1. Open Safari on simulator/device
2. Navigate to: `https://taasclub-app.web.app/join?token=test123`
3. Should open app and navigate to join screen

### Verify App Links

```bash
# Android App Links verification
adb shell pm get-app-links app.taasclub
```

Expected output:
```
app.taasclub:
    ID: ...
    Signatures: [SHA256:...]
    Domain verification state:
      taasclub-app.web.app: verified
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Link opens browser | Check assetlinks.json SHA256 fingerprint |
| AASA not loading | Ensure file has no .json extension |
| iOS not verifying | Wait up to 24h for Apple CDN cache |
| Android not verifying | Run `adb shell pm verify-app-links` |
| Wrong screen opens | Check GoRouter path configuration |

---

## Custom URL Scheme (Fallback)

For older devices without App Links support:

### Android (AndroidManifest.xml)
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="taasclub"/>
</intent-filter>
```

### iOS (Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>taasclub</string>
    </array>
  </dict>
</array>
```

Link format: `taasclub://join?token=xxx`
