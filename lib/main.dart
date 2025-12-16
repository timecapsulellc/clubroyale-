
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubroyale/firebase_options.dart';
import 'core/services/analytics_service.dart';

import 'features/lobby/lobby_screen.dart';
import 'features/lobby/room_waiting_screen.dart';
import 'features/game/game_screen.dart';
import 'core/theme/multi_theme.dart';
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
// RevenueCat removed - app is FREE with ads only
// Diamond Economy imports
import 'features/wallet/screens/earn_diamonds_screen.dart';
import 'features/wallet/diamond_purchase_screen.dart';
import 'package:clubroyale/features/wallet/screens/transfer_screen.dart';
import 'package:clubroyale/features/admin/screens/admin_panel_screen.dart';
import 'package:clubroyale/features/admin/screens/grant_request_screen.dart';
import 'package:clubroyale/features/admin/screens/pending_approvals_screen.dart';
import 'package:clubroyale/features/settings/settings_screen.dart';
// Stories imports
import 'package:clubroyale/features/stories/screens/story_viewer_screen.dart';
import 'package:clubroyale/features/stories/screens/story_creator_screen.dart';
import 'package:clubroyale/features/stories/models/story.dart';
// Voice Room imports
import 'package:clubroyale/features/social/screens/voice_room_screen.dart';
// Enhanced Profile imports
import 'package:clubroyale/features/profile/screens/profile_view_screen.dart';
import 'package:clubroyale/features/profile/screens/followers_list_screen.dart';
import 'package:clubroyale/features/profile/screens/create_post_screen.dart';
// TODO: Fix chat screen API mismatches before enabling


// import 'package:clubroyale/features/admin/screens/admin_chat_screen.dart';
// import 'package:clubroyale/features/wallet/screens/user_support_chat_screen.dart';

// Info Screens imports
import 'package:clubroyale/features/info/screens/faq_screen.dart';
import 'package:clubroyale/features/info/screens/how_to_play_screen.dart';
import 'package:clubroyale/features/info/screens/terms_screen.dart';
import 'package:clubroyale/features/info/screens/about_screen.dart';
import 'package:clubroyale/features/info/screens/landing_page.dart';
import 'package:clubroyale/features/info/screens/privacy_screen.dart';

// Social & Gaming Features imports
import 'package:clubroyale/features/social/screens/chat_list_screen.dart';
import 'package:clubroyale/features/social/screens/chat_room_screen.dart';
import 'package:clubroyale/features/social/screens/friends_screen.dart';
import 'package:clubroyale/features/social/screens/activity_feed_screen.dart';
import 'package:clubroyale/features/tournament/screens/tournament_lobby_screen.dart';
import 'package:clubroyale/features/clubs/screens/clubs_list_screen.dart';
import 'package:clubroyale/features/replay/screens/replay_list_screen.dart';

// Onboarding
import 'package:clubroyale/features/onboarding/onboarding_screen.dart';


// Analytics service singleton for screen tracking
final _analyticsService = AnalyticsService();

// 1. Define your routes
final GoRouter _router = GoRouter(
  initialLocation: '/', // Start directly at home/auth gate
  observers: [_analyticsService.observer],
  routes: <RouteBase>[
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
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
          path: 'diamond-store',
          builder: (BuildContext context, GoRouterState state) {
            return const DiamondPurchaseScreen();
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
          path: 'voice-room/:chatId',
          builder: (BuildContext context, GoRouterState state) {
            final String chatId = state.pathParameters['chatId']!;
            return VoiceRoomScreen(chatId: chatId);
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
        
        // Info Screens Routes
        GoRoute(
          path: 'faq',
          builder: (BuildContext context, GoRouterState state) {
            return const FAQScreen();
          },
        ),
        GoRoute(
          path: 'how-to-play',
          builder: (BuildContext context, GoRouterState state) {
            return const HowToPlayMarriageScreen();
          },
        ),
        GoRoute(
          path: 'terms',
          builder: (BuildContext context, GoRouterState state) {
            return const TermsScreen();
          },
        ),
        GoRoute(
          path: 'privacy',
          builder: (BuildContext context, GoRouterState state) {
            return const PrivacyScreen();
          },
        ),
        GoRoute(
          path: 'about',
          builder: (BuildContext context, GoRouterState state) {
            return const AboutScreen();
          },
        ),
        GoRoute(
          path: 'landing',
          builder: (BuildContext context, GoRouterState state) {
            return const LandingPage();
          },
        ),
        // Social & Gaming Feature Routes
        GoRoute(
          path: 'activity',
          builder: (BuildContext context, GoRouterState state) {
            return const ActivityFeedScreen();
          },
        ),
        GoRoute(
          path: 'tournaments',
          builder: (BuildContext context, GoRouterState state) {
            return const TournamentLobbyScreen();
          },
        ),
        GoRoute(
          path: 'clubs',
          builder: (BuildContext context, GoRouterState state) {
            return const ClubsListScreen();
          },
        ),
        GoRoute(
          path: 'replays',
          builder: (BuildContext context, GoRouterState state) {
            return const ReplayListScreen();
          },
        ),
        // Social-First Features
        GoRoute(
          path: 'chats',
          builder: (BuildContext context, GoRouterState state) {
            return const ChatListScreen();
          },
        ),
        GoRoute(
          path: 'social/chat/:chatId',
          builder: (BuildContext context, GoRouterState state) {
            final String chatId = state.pathParameters['chatId']!;
            return ChatRoomScreen(chatId: chatId);
          },
        ),
        GoRoute(
          path: 'friends',
          builder: (BuildContext context, GoRouterState state) {
             // Import needed at top
             return const FriendsScreen();
          },
        ),
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
  
  // App is FREE - no IAP/subscriptions (Safe Harbor model)
  // Revenue comes from AdMob ads only
  // initialized in ProviderScope
  debugPrint('ℹ️ App runs in FREE mode (ads only)');
  
  runApp(

    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme changes from provider
    final themeData = ref.watch(themeDataProvider);
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp.router(
      routerConfig: _router,
      title: 'ClubRoyale',
      theme: themeData, // Dynamic theme from provider
      darkTheme: themeData, // Same theme for dark mode
      themeMode: themeState.mode == AppThemeMode.light 
          ? ThemeMode.light 
          : ThemeMode.dark,
    );
  }
}

