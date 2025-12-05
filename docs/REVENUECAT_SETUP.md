# RevenueCat IAP Setup Guide

This guide walks through setting up RevenueCat for in-app purchases (diamonds) in the TaasClub Flutter app.

---

## 📋 Prerequisites

- [ ] Apple Developer Account ($99/year)
- [ ] Google Play Developer Account ($25 one-time)
- [ ] RevenueCat account (free tier available)
- [ ] App Store Connect access
- [ ] Google Play Console access

---

## 🔧 Step 1: RevenueCat Dashboard Setup

### 1.1 Create RevenueCat Project
1. Go to [https://app.revenuecat.com/signup](https://app.revenuecat.com/signup)
2. Create a new project: **TaasClub**
3. Note your **Public API Key** (found in Project Settings)

### 1.2 Configure iOS App
1. In RevenueCat dashboard → Apps → Add iOS App
2. Enter:
   - Bundle ID: `com.taasclub.app` (or your bundle ID)
   - App Store Shared Secret (from App Store Connect)

### 1.3 Configure Android App
1. In RevenueCat dashboard → Apps → Add Android App
2. Enter:
   - Package Name: `com.taasclub.app`
   - Upload Google Service Account JSON

---

## 🍎 Step 2: App Store Connect Setup (iOS)

### 2.1 Create In-App Purchase Products
1. Go to App Store Connect → My Apps → TaasClub
2. Navigate to **Features** → **In-App Purchases**
3. Create **4 Consumable** products:

| Product ID | Price | Diamonds |
|------------|-------|----------|
| `diamonds_50` | $0.99 | 50 |
| `diamonds_120` | $1.99 | 120 (100 + 20 bonus) |
| `diamonds_300` | $4.99 | 300 (250 + 50 bonus) |
| `diamonds_650` | $9.99 | 650 (500 + 150 bonus) |

4. For each product:
   - **Type**: Consumable
   - **Reference Name**: e.g., "50 Diamonds Pack"
   - **Product ID**: Match the table above
   - **Price**: Set tier
   - **Description**: "Purchase [X] diamonds to create rooms"

### 2.2 Get Shared Secret
1. App Store Connect → Users and Access → Keys → In-App Purchase
2. Copy the **Shared Secret**
3. Paste it in RevenueCat → iOS App Settings

---

## 🤖 Step 3: Google Play Console Setup (Android)

### 3.1 Create In-App Products
1. Go to Google Play Console → TaasClub → Monetize → In-app products
2. Create **4 Managed products** (same IDs as iOS):

| Product ID | Price | Title |
|------------|-------|-------|
| `diamonds_50` | ₹100 | 50 Diamonds |
| `diamonds_120` | ₹200 | 120 Diamonds |
| `diamonds_300` | ₹500 | 300 Diamonds |
| `diamonds_650` | ₹1000 | 650 Diamonds |

3. For each:
   - **Product ID**: Match iOS
   - **Description**: "Get [X] diamonds for room creation"
   - **Price**: Set per country

### 3.2 Configure Service Account
1. Google Cloud Console → Enable Google Play Developer API
2. Create Service Account
3. Download JSON key
4. Upload to RevenueCat → Android App Settings

---

## 💎 Step 4: RevenueCat Entitlements & Offerings

### 4.1 Create Entitlements
1. RevenueCat → Entitlements → Create Entitlement
2. Name: **diamonds** (for checking premium access if needed)

### 4.2 Create Offerings
1. RevenueCat → Offerings → Create Offering
2. Offering ID: `default`
3. Add all 4 packages:
   - Package 1: `diamonds_50` → `$rc_monthly` identifier
   - Package 2: `diamonds_120` → `$rc_six_month` identifier
   - Package 3: `diamonds_300` → `$rc_annual` identifier
   - Package 4: `diamonds_650` → `$rc_lifetime` identifier

> **Note**: RevenueCat maps custom product IDs to standard identifiers for cross-platform consistency.

---

## 📱 Step 5: Flutter App Integration

### 5.1 Add Environment Variables
Create `.env` files in project root:

**.env.development**
```bash
REVENUECAT_API_KEY_IOS=your_ios_public_api_key_here
REVENUECAT_API_KEY_ANDROID=your_android_public_api_key_here
```

**.env.production**
```bash
REVENUECAT_API_KEY_IOS=your_production_ios_key
REVENUECAT_API_KEY_ANDROID=your_production_android_key
```

### 5.2 Update main.dart
Replace the placeholder initialization in `main.dart`:

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize RevenueCat
  await _configureRevenueCat();
  
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _configureRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug);
  
  PurchasesConfiguration configuration;
  if (Platform.isIOS) {
    configuration = PurchasesConfiguration('your_ios_api_key');
  } else if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('your_android_api_key');
  } else {
    return;
  }
  
  await Purchases.configure(configuration);
}
```

### 5.3 Update DiamondPurchaseScreen
Replace the placeholder code in `lib/features/wallet/diamond_purchase_screen.dart`:

```dart
Future<void> _purchasePackage(DiamondPackage package) async {
  setState(() => _isPurchasing = true);

  try {
    // Get offerings from RevenueCat
    final offerings = await Purchases.getOfferings();
    final currentOffering = offerings.current;
    
    if (currentOffering == null) {
      throw Exception('No offerings available');
    }
    
    // Find the package
    final rcPackage = currentOffering.availablePackages.firstWhere(
      (p) => p.storeProduct.identifier == package.productId,
      orElse: () => throw Exception('Package not found'),
    );
    
    // Make purchase
    final purchaserInfo = await Purchases.purchasePackage(rcPackage);
    
    // Verify purchase
    if (purchaserInfo.entitlements.active.isNotEmpty) {
      // Add diamonds to user's wallet
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.uid;
      
      if (userId != null) {
        final diamondService = ref.read(diamondServiceProvider);
        await diamondService.addDiamonds(
          userId,
          package.diamonds,
          DiamondTransactionType.purchase,
          description: 'Purchased ${package.diamonds} diamonds via ${Platform.isIOS ? 'App Store' : 'Google Play'}',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Successfully purchased ${package.diamonds} diamonds!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  } on PlatformException catch (e) {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);
    if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.message}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isPurchasing = false);
    }
  }
}
```

---

## 🧪 Step 6: Testing

### 6.1 iOS Sandbox Testing
1. Settings → App Store → Sandbox Account
2. Create test user in App Store Connect
3. Sign in with test account on device
4. Test purchases (they're free in sandbox)

### 6.2 Android Testing
1. Google Play Console → Setup → License Testing
2. Add test Gmail accounts
3. Upload APK to Internal Testing track
4. Install from Play Store on test device
5. Test purchases

### 6.3 RevenueCat Testing
1. Go to RevenueCat → Customers
2. Verify transactions appear
3. Check that entitlements are granted

---

## ✅ Production Checklist

Before going live:

- [ ] All IAP products approved in App Store Connect
- [ ] All IAP products active in Google Play Console
- [ ] RevenueCat production API keys configured
- [ ] Tested purchases on physical devices (iOS & Android)
- [ ] Verified webhook integration (if using backend)
- [ ] Added privacy policy link (required by Apple/Google)
- [ ] Configured tax & banking info in store consoles
- [ ] Enabled production mode in RevenueCat
- [ ] Updated `.env.production` with real keys
- [ ] Tested restore purchases functionality

---

## 🔐 Security Notes

1. **Never commit API keys** to version control
2. Use environment variables via `flutter_dotenv` or similar
3. Enable App Store Server Notifications (iOS)
4. Enable Google Play Real-time Developer Notifications (Android)
5. Implement receipt validation via RevenueCat webhooks

---

## 📚 References

- [RevenueCat Flutter SDK](https://docs.revenuecat.com/docs/flutter)
- [App Store Connect Guide](https://developer.apple.com/app-store-connect/)
- [Google Play Console Guide](https://play.google.com/console/about/)
- [RevenueCat Dashboard](https://app.revenuecat.com)

---

## 🆘 Troubleshooting

### "No products found"
- Verify product IDs match exactly in code, App Store Connect, and Google Play Console
- Check that products are approved/active
- Ensure RevenueCat is configured with correct credentials

### "Purchase failed"
- Check device has valid payment method
- Verify app is signed with correct provisioning profile (iOS)
- Ensure Google Play billing is enabled in app (Android)

### "Entitlements not granted"
- Check RevenueCat dashboard for transaction
- Verify webhook integration if using backend
- Review RevenueCat logs for errors

---

## 💰 Pricing Strategy (India)

Suggested pricing for Indian market:

| Package | Diamonds | Price (₹) | Price (USD) | Bonus | Value |
|---------|----------|-----------|-------------|-------|-------|
| Starter | 50 | 100 | $1.19 | - | 5 rooms |
| Popular | 120 | 200 | $2.39 | +20 | 12 rooms |
| Premium | 300 | 500 | $5.99 | +50 | 30 rooms |
| Ultimate | 650 | 1000 | $11.99 | +150 | 65 rooms |

**Conversion**: 1 room = 10 diamonds

---

## 🎁 Promotional Strategy

1. **First-time bonus**: Give 50 starter diamonds on signup
2. **Daily rewards**: 5 diamonds per day for login streak
3. **Referral bonus**: 20 diamonds for each friend who joins
4. **Limited offers**: 2x diamonds during festivals
5. **Loyalty tiers**: Bonus diamonds for repeat purchasers
