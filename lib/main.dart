
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taasclub/firebase_options.dart';
import 'core/services/analytics_service.dart';

import 'features/lobby/lobby_screen.dart';
import 'features/lobby/room_waiting_screen.dart';
import 'features/game/game_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/game/game_history_screen.dart';
import 'games/call_break/call_break_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/ledger/ledger_screen.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/auth_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/wallet/wallet_screen.dart';
import 'features/game/test_game_screen.dart';
import 'games/marriage/marriage_game_screen.dart';
import 'games/marriage/marriage_entry_screen.dart';
import 'games/marriage/marriage_multiplayer_screen.dart';
import 'games/teen_patti/teen_patti_screen.dart';
import 'games/in_between/in_between_screen.dart';
import 'features/game/settlement/settlement_preview_screen.dart';
import 'config/revenuecat_config.dart';
// Diamond Economy imports
import 'features/wallet/screens/earn_diamonds_screen.dart';
import 'package:taasclub/features/wallet/screens/transfer_screen.dart';
import 'package:taasclub/features/admin/screens/admin_panel_screen.dart';
import 'package:taasclub/features/admin/screens/grant_request_screen.dart';
import 'package:taasclub/features/admin/screens/pending_approvals_screen.dart';
// TODO: Fix chat screen API mismatches before enabling
// import 'package:taasclub/features/admin/screens/admin_chat_screen.dart';
// import 'package:taasclub/features/wallet/screens/user_support_chat_screen.dart';

// Analytics service singleton for screen tracking
final _analyticsService = AnalyticsService();

// 1. Define your routes
final GoRouter _router = GoRouter(
  observers: [_analyticsService.observer],
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthGate();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'auth',
          builder: (BuildContext context, GoRouterState state) {
            return const AuthScreen();
          },
        ),
        GoRoute(
          path: 'lobby',
          builder: (BuildContext context, GoRouterState state) {
            return const LobbyScreen();
          },
        ),
        GoRoute(
          path: 'lobby/:roomId',
          builder: (BuildContext context, GoRouterState state) {
            final String roomId = state.pathParameters['roomId']!;
            return RoomWaitingScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: 'history',
          builder: (BuildContext context, GoRouterState state) {
            return const GameHistoryScreen();
          },
        ),
        GoRoute(
          path: 'leaderboard',
          builder: (BuildContext context, GoRouterState state) {
            return const LeaderboardScreen();
          },
        ),
        GoRoute(
          path: 'game/:gameId',
          builder: (BuildContext context, GoRouterState state) {
            final String gameId = state.pathParameters['gameId']!;
            return GameScreen(gameId: gameId);
          },
        ),
        GoRoute(
            path: 'ledger/:gameId',
            builder: (BuildContext c, GoRouterState s) =>
                LedgerScreen(gameId: s.pathParameters['gameId']!)),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: 'game/:gameId/play',
          builder: (BuildContext context, GoRouterState state) {
            final String gameId = state.pathParameters['gameId']!;
            return CallBreakGameScreen(gameId: gameId);
          },
        ),
        GoRoute(
          path: 'wallet',
          builder: (BuildContext context, GoRouterState state) {
            return const WalletScreen();
          },
        ),
        GoRoute(
          path: 'test-game',
          builder: (BuildContext context, GoRouterState state) {
            return const TestGameScreen();
          },
        ),
        GoRoute(
          path: 'call-break',
          builder: (BuildContext context, GoRouterState state) {
            return const CallBreakGameScreen();
          },
        ),
        GoRoute(
          path: 'marriage',
          builder: (BuildContext context, GoRouterState state) {
            return const MarriageEntryScreen();
          },
        ),
        GoRoute(
          path: 'marriage/practice',
          builder: (BuildContext context, GoRouterState state) {
            return const MarriageGameScreen();
          },
        ),
        GoRoute(
          path: 'marriage/:roomId',
          builder: (BuildContext context, GoRouterState state) {
            final String roomId = state.pathParameters['roomId']!;
            return MarriageMultiplayerScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: 'teen_patti/:roomId',
          builder: (BuildContext context, GoRouterState state) {
            final String roomId = state.pathParameters['roomId']!;
            return TeenPattiScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: 'in_between/:roomId',
          builder: (BuildContext context, GoRouterState state) {
            final String roomId = state.pathParameters['roomId']!;
            return InBetweenScreen(roomId: roomId);
          },
        ),
        GoRoute(
          path: 'settlement/:gameId',
          builder: (BuildContext context, GoRouterState state) {
            final String gameId = state.pathParameters['gameId']!;
            return SettlementPreviewScreen(gameId: gameId);
          },
        ),
        // Diamond Economy Routes
        GoRoute(
          path: 'earn-diamonds',
          builder: (BuildContext context, GoRouterState state) {
            return const EarnDiamondsScreen();
          },
        ),
        GoRoute(
          path: 'transfer',
          builder: (BuildContext context, GoRouterState state) {
            return const TransferScreen();
          },
        ),
        GoRoute(
          path: 'admin',
          builder: (BuildContext context, GoRouterState state) {
            return const AdminPanelScreen();
          },
        ),
        GoRoute(
          path: 'admin/grant',
          builder: (BuildContext context, GoRouterState state) {
            return const GrantRequestScreen();
          },
        ),
        GoRoute(
          path: 'admin/approvals',
          builder: (BuildContext context, GoRouterState state) {
            return const PendingApprovalsScreen();
          },
        ),
        // TODO: Fix chat screen API mismatches before enabling
        // GoRoute(
        //   path: 'admin/chats',
        //   builder: (BuildContext context, GoRouterState state) {
        //     return const AdminChatScreen();
        //   },
        // ),
        // GoRoute(
        //   path: 'support',
        //   builder: (BuildContext context, GoRouterState state) {
        //     return const UserSupportChatScreen();
        //   },
        // ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Crashlytics (skip on web - not supported)
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  // Initialize RevenueCat (will skip if not configured)
  await RevenueCatConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'TaasClub',
      theme: AppTheme.theme, // Use the new Casino Theme
      darkTheme: AppTheme.theme, // Force the same theme for now
      themeMode: ThemeMode.light, // Default to our defined theme
    );
  }
}
