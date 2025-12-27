import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:clubroyale/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clubroyale/core/services/feature_flags.dart';
import 'package:clubroyale/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await featureFlags.init();
  });

  testWidgets('Marriage Solo Game Layout Verification', (tester) async {
    // 1. Launch App
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 4)); // Splash + Home load

    // 2. Handle Authentication (if needed)
    debugPrint('Step 2: Checking Auth State...');
    final guestButton = find.textContaining('Guest');
    final anonymousButton = find.textContaining('Anonymous');
    final playNow = find.textContaining('Play Now');
    
    if (guestButton.evaluate().isNotEmpty) {
      debugPrint('Found Guest Button, tapping...');
      await tester.tap(guestButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else if (anonymousButton.evaluate().isNotEmpty) {
      debugPrint('Found Anonymous Button, tapping...');
      await tester.tap(anonymousButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else if (playNow.evaluate().isNotEmpty) {
      debugPrint('Found Play Now Button, tapping...');
      await tester.tap(playNow.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else {
        debugPrint('No Auth buttons found. Assuming already on Home or unknown screen.');
    }

    // 3. Navigate to Solo Mode
    debugPrint('Step 3: Finding SOLO button...');
    final soloButton = find.text('SOLO');
    
    // Attempt to scroll if not found
    if (soloButton.evaluate().isEmpty) {
        debugPrint('SOLO button not visible, current widgets:');
        // Print unique widget types to identify screen
        final widgets = tester.allWidgets.map((w) => w.runtimeType.toString()).toSet();
        debugPrint(widgets.join(', '));
        
        // Try scrolling if Scrollable exists
        if (find.byType(Scrollable).evaluate().isNotEmpty) {
             debugPrint('Scrollable found, scrolling...');
             await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
             await tester.pumpAndSettle();
        } else {
             debugPrint('No Scrollable widget found!');
        }
    }
    
    expect(soloButton, findsOneWidget, reason: 'Solo button should be on Home Screen');
    await tester.tap(soloButton);
    await tester.pumpAndSettle();

    // 3. Select Marriage Game
    final marriageButton = find.text('Marriage');
    expect(marriageButton, findsOneWidget, reason: 'Marriage option should be in Solo sheet');
    await tester.tap(marriageButton);
    
    // 4. Wait for Game Loading (CircularProgressIndicator may appear)
    await tester.pump(const Duration(seconds: 2)); // Wait for dialog
    await tester.pump(const Duration(seconds: 5)); // Wait for async creation
    await tester.pumpAndSettle(); // Wait for navigation

    // 5. Verify Game Screen Loaded
    // We look for specific elements added in the redesign
    expect(find.text('CLOSED DECK'), findsOneWidget, reason: 'New CLOSED DECK label missing');
    expect(find.text('OPEN DECK'), findsOneWidget, reason: 'New OPEN DECK label missing');
    expect(find.text('FINISH SLOT'), findsOneWidget, reason: 'New FINISH SLOT label missing');

    // 6. Verify Player Hand Area
    // Attempt to find the dark gradient container using Key if possible, 
    // or just assume if text is there structure is likely correct.
    // We can check for the GameTopBar elements too
    expect(find.byType(TableLayout), findsOneWidget);
    
    // 7. Success log
    debugPrint('✅ Marriage Solo UI Layout Verified Successfully');
  });
}
