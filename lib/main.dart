
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
import 'core/config/club_royale_theme.dart';
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
import 'package:taasclub/features/settings/settings_screen.dart';
import 'package:taasclub/core/config/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Stories imports
import 'package:taasclub/features/stories/screens/story_viewer_screen.dart';
import 'package:taasclub/features/stories/screens/story_creator_screen.dart';
import 'package:taasclub/features/stories/models/story.dart';
// Voice Room imports
import 'package:taasclub/features/social/voice_rooms/screens/voice_room_screen.dart';
// Enhanced Profile imports
import 'package:taasclub/features/profile/screens/profile_view_screen.dart';
import 'package:taasclub/features/profile/screens/followers_list_screen.dart';
import 'package:taasclub/features/profile/screens/create_post_screen.dart';
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
        // Settings route
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            // Import at top: import 'features/settings/settings_screen.dart';
            return const SettingsScreen();
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
        // Stories routes
        GoRoute(
          path: 'stories/create',
          builder: (BuildContext context, GoRouterState state) {
            return const StoryCreatorScreen();
          },
        ),
        GoRoute(
          path: 'stories/view',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, dynamic>?;
            final stories = (extra?['stories'] as List<Story>?) ?? [];
            final initialIndex = (extra?['initialIndex'] as int?) ?? 0;
            final isOwn = (extra?['isOwn'] as bool?) ?? false;
            return StoryViewerScreen(
              stories: stories,
              initialIndex: initialIndex,
              isOwn: isOwn,
            );
          },
        ),
        // Voice Room route
        GoRoute(
          path: 'voice-room/:roomId',
          builder: (BuildContext context, GoRouterState state) {
            final String roomId = state.pathParameters['roomId']!;
            return VoiceRoomScreen(roomId: roomId);
          },
        ),
        // Enhanced Profile routes
        GoRoute(
          path: 'user/:userId',
          builder: (BuildContext context, GoRouterState state) {
            final String userId = state.pathParameters['userId']!;
            return ProfileViewScreen(userId: userId);
          },
        ),
        GoRoute(
          path: 'followers/:userId',
          builder: (BuildContext context, GoRouterState state) {
            final String userId = state.pathParameters['userId']!;
            return FollowersListScreen(userId: userId, isFollowers: true);
          },
        ),
        GoRoute(
          path: 'following/:userId',
          builder: (BuildContext context, GoRouterState state) {
            final String userId = state.pathParameters['userId']!;
            return FollowersListScreen(userId: userId, isFollowers: false);
          },
        ),
        GoRoute(
          path: 'create-post',
          builder: (BuildContext context, GoRouterState state) {
            return const CreatePostScreen();
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
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    // Continue anyway - app can work with limited functionality
  }
  
  // Initialize Firebase Crashlytics (skip on web - not supported)
  if (!kIsWeb) {
    try {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      debugPrint('✅ Crashlytics initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Crashlytics initialization failed: $e');
      // Continue anyway
    }
  }
  
  // Initialize RevenueCat (will skip if not configured)
  try {
    await RevenueCatConfig.initialize();
    debugPrint('✅ RevenueCat initialized successfully');
  } catch (e) {
    debugPrint('⚠️ RevenueCat initialization failed: $e');
    // Continue anyway - app can work without IAP
  }
  // Initialize GameSettings for locale detection
  try {
    final prefs = await SharedPreferences.getInstance();
    final gameSettings = GameSettings(prefs);
    await gameSettings.init();
    debugPrint('✅ GameSettings initialized (region: ${gameSettings.region})');
  } catch (e) {
    debugPrint('⚠️ GameSettings initialization failed: $e');
    // Continue with default (global) region
  }
  
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
      title: 'ClubRoyale',
      theme: ClubRoyaleTheme.theme, // Premium ClubRoyale Theme
      darkTheme: ClubRoyaleTheme.theme, // Premium dark theme
      themeMode: ThemeMode.dark, // Dark mode for premium casino feel
    );


  }
}
