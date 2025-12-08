# RevenueCat Setup Guide

Complete setup guide for integrating RevenueCat with TaasClub.

---

## Step 1: Create RevenueCat Account

1. Go to [https://app.revenuecat.com](https://app.revenuecat.com)
2. Sign up with Google or email
3. Create a new Project: "TaasClub"

---

## Step 2: Add Android App

1. In RevenueCat dashboard → **Apps** → **+ New**
2. Select **Google Play Store**
3. App name: `TaasClub`
4. Package name: `app.taasclub`
5. Click **Create**

### Google Play Service Credentials

1. In Google Play Console → **Setup** → **API access**
2. Create or link a Google Cloud project
3. Create a **Service Account** with:
   - Role: **Financial Data → View financial data**
   - Role: **Financial Data → Manage orders and subscriptions**
4. Generate JSON key file
5. Upload JSON key to RevenueCat → **App Settings** → **Service Credentials**

---

## Step 3: Add iOS App (Optional)

1. In RevenueCat dashboard → **Apps** → **+ New**
2. Select **Apple App Store**
3. App name: `TaasClub`
4. Bundle ID: `app.taasclub`
5. Upload App Store Connect API key

---

## Step 4: Create Products

### In Google Play Console

Go to **Monetization** → **Products** → **In-app products**

Create these products:

| Product ID | Name | Price |
|------------|------|-------|
| `diamonds_50` | 50 Diamonds | $0.99 |
| `diamonds_110` | 110 Diamonds | $1.99 |
| `diamonds_575` | 575 Diamonds | $7.99 |
| `diamonds_1200` | 1200 Diamonds | $14.99 |

### In RevenueCat

1. Go to **Products** → **+ New**
2. Add each Google Play product ID
3. Set **Identifier** matching the product ID

---

## Step 5: Create Offerings

1. Go to **Offerings** → **+ New**
2. Create offering: `default`
3. Add all 4 diamond products to this offering
4. Set as **Current Offering**

---

## Step 6: Get API Keys

1. Go to **Project Settings** → **API Keys**
2. Copy the **Public SDK key** for Android/iOS
3. Keep the **Secret API key** for webhooks (server-side)

---

## Step 7: Update Flutter Code

Edit `lib/features/store/diamond_store.dart`:

```dart
// Replace this line:
// static const String _apiKey = 'YOUR_REVENUECAT_API_KEY';

// With your actual key:
static const String _apiKey = 'appl_XXXXXXXXXXXXXXXXXX';
```

### Full Integration Code

```dart
import 'package:purchases_flutter/purchases_flutter.dart';

class DiamondStoreService {
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  
  static Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);
    
    final configuration = PurchasesConfiguration(_apiKey)
      ..appUserID = null; // Let RevenueCat generate ID
    
    await Purchases.configure(configuration);
  }
  
  Future<void> purchaseDiamonds(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final product = offerings.current?.availablePackages
          .firstWhere((p) => p.storeProduct.identifier == productId);
      
      if (product != null) {
        final result = await Purchases.purchasePackage(product);
        // Grant diamonds based on result
        _grantDiamonds(result);
      }
    } on PurchasesErrorCode catch (e) {
      // Handle error
      print('Purchase error: $e');
    }
  }
  
  void _grantDiamonds(CustomerInfo customerInfo) {
    // Check entitlements and grant diamonds
    // Called automatically after successful purchase
  }
}
```

---

## Step 8: Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize RevenueCat
  await DiamondStoreService.initialize();
  
  runApp(const MyApp());
}
```

---

## Step 9: Set Up Webhooks (Server-side)

For server-side verification, set up RevenueCat webhooks:

1. Go to **Project Settings** → **Webhooks**
2. Add webhook URL: `https://us-central1-taasclub-app.cloudfunctions.net/revenuecatWebhook`
3. Select events: `INITIAL_PURCHASE`, `RENEWAL`, `CANCELLATION`

### Cloud Function for Webhook

```typescript
// functions/src/revenueCat/webhook.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const revenuecatWebhook = functions.https.onRequest(async (req, res) => {
  const event = req.body;
  
  if (event.type === 'INITIAL_PURCHASE') {
    const userId = event.app_user_id;
    const productId = event.product_id;
    
    // Map product to diamonds
    const diamondAmounts: Record<string, number> = {
      'diamonds_50': 50,
      'diamonds_110': 110,
      'diamonds_575': 575,
      'diamonds_1200': 1200,
    };
    
    const diamonds = diamondAmounts[productId] || 0;
    
    // Grant diamonds
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .update({
        diamonds: admin.firestore.FieldValue.increment(diamonds),
      });
  }
  
  res.status(200).send('OK');
});
```

---

## Step 10: Test Purchases

### Test on Android

1. Add test accounts in Google Play Console
2. Use license testing mode
3. Purchases will complete without charge

### Test on iOS

1. Create Sandbox testers in App Store Connect
2. Sign into sandbox account on device
3. Purchases use sandbox environment

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Product not found" | Wait 24h for Play Console to sync |
| "Purchase cancelled" | Check Google Play account status |
| "Invalid credentials" | Verify service account JSON in RevenueCat |
| Diamonds not granted | Check webhook logs in Firebase |

---

## Security Reminders

- ⚠️ Never expose secret API key in client code
- ⚠️ Always verify purchases server-side via webhooks
- ⚠️ Log all transactions for audit
