import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clubroyale/games/marriage/marriage_multiplayer_screen.dart';
import 'package:clubroyale/games/marriage/marriage_service.dart';
import 'package:clubroyale/games/marriage/marriage_config.dart';
import 'package:clubroyale/features/auth/auth_service.dart';
import 'package:clubroyale/features/game/ui/components/table_layout.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:clubroyale/features/wallet/diamond_service.dart';
import 'package:clubroyale/features/wallet/diamond_wallet.dart';
import 'package:clubroyale/features/rtc/audio_service.dart';
import 'package:clubroyale/features/rtc/signaling_service.dart';
import 'package:clubroyale/features/chat/chat_service.dart';
import 'package:clubroyale/features/chat/chat_message.dart';

// Mocks
class MockMarriageService extends Mock implements MarriageService {}
class MockAuthService extends Mock implements AuthService {}
class MockUser extends Mock implements firebase_auth.User {}
class MockDiamondService extends Mock implements DiamondService {}
class MockAudioService extends Mock implements AudioService {}
class MockChatService extends Mock implements ChatService {}

void main() {
  late MockMarriageService mockMarriageService;
  late MockAuthService mockAuthService;
  late MockDiamondService mockDiamondService;
  late MockUser mockUser;
  late MockAudioService mockAudioService;
  late MockChatService mockChatService;

  setUp(() {
    registerFallbackValue(MarriageGameState(
      tipluCardId: '',
      playerHands: {},
      deckCards: [],
      discardPile: [],
      currentPlayerId: '',
      currentRound: 1,
      phase: '',
      config: const MarriageGameConfig(),
    ));

    mockMarriageService = MockMarriageService();
    mockAuthService = MockAuthService();
    mockDiamondService = MockDiamondService();
    mockAudioService = MockAudioService();
    mockChatService = MockChatService();
    mockUser = MockUser();

    // Stub AudioService
    when(() => mockAudioService.isEnabled).thenReturn(false);
    when(() => mockAudioService.state).thenReturn(AudioConnectionState.disconnected);
    when(() => mockAudioService.isMuted).thenReturn(false);
    when(() => mockAudioService.connectedPeers).thenReturn([]);
    when(() => mockAudioService.joinAudioRoom()).thenAnswer((_) async {});
    when(() => mockAudioService.toggleMute()).thenReturn(null);

    // Stub ChatService
    when(() => mockChatService.messagesStream).thenAnswer((_) => Stream.value([]));
    when(() => mockChatService.typingUsersStream).thenAnswer((_) => Stream.value([]));

    // Default mock behavior
    when(() => mockUser.uid).thenReturn('test_user_id');
    when(() => mockUser.displayName).thenReturn('Test Player');
    when(() => mockAuthService.currentUser).thenReturn(mockUser);
    
    // Stub getRemainingTurnTime to prevent null error
    when(() => mockMarriageService.getRemainingTurnTime(any())).thenReturn(30);

    // Stub watchWallet
    when(() => mockDiamondService.watchWallet(any()))
        .thenAnswer((_) => Stream.value(const DiamondWallet(userId: 'test_user_id', balance: 1000)));
  });

  testWidgets('Marriage Multiplayer Screen UI Layout Verification', (tester) async {
    // Set screen size to landscape 1080p
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Setup Game State
    final gameState = MarriageGameState(
      tipluCardId: '10_spades_0', // 10 Spades Tiplu
      playerHands: {
        'test_user_id': ['ace_spades_0', 'king_spades_0'], // My hand
        'opponent_1': ['ace_hearts_0'],
      },
      deckCards: ['2_clubs_0', '3_clubs_0'],
      discardPile: ['queen_hearts_0'], // Top discard
      currentPlayerId: 'test_user_id', // My turn
      currentRound: 1,
      phase: 'playing',
      turnPhase: 'drawing', // Drawing phase
      config: const MarriageGameConfig(),
    );

    // 2. Mock Stream
    when(() => mockMarriageService.watchGameState(any()))
        .thenAnswer((_) => Stream.value(gameState));

    // 3. Pump Widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marriageServiceProvider.overrideWithValue(mockMarriageService),
          authServiceProvider.overrideWithValue(mockAuthService),
          diamondServiceProvider.overrideWithValue(mockDiamondService),
          audioServiceProvider.overrideWith((ref, params) => mockAudioService),
          chatServiceProvider.overrideWith((ref, params) => mockChatService),
        ],
        child: const MaterialApp(
          home: MarriageMultiplayerScreen(roomId: 'test_room'),
        ),
      ),
    );

    // 4. Wait for Async/Animations
    await tester.pump(); 
    await tester.pump(const Duration(seconds: 1)); 

    // 5. Verify UI Elements (Redesign)
    debugPrint('Verifying UI elements...');
    
    // Check Deck Labels
    expect(find.text('CLOSED DECK'), findsOneWidget, reason: 'CLOSED DECK label missing');
    expect(find.text('OPEN DECK'), findsOneWidget, reason: 'OPEN DECK label missing');
    expect(find.text('FINISH SLOT'), findsOneWidget, reason: 'FINISH SLOT label missing');

    // Check Player Hand Area Gradient Container
    // We can't easily verify gradient color, but we can verify the Container exists
    // by finding the one wrapping the Status Bar or Hand
    // For now, assume if TableLayout is present and labels are there, the redesign logic is active.
    
    // Check Phase Indicator (My Turn)
    expect(find.text('📥 DRAW'), findsOneWidget, reason: 'Draw phase indicator missing');

    debugPrint('✅ Marriage UI Widget Test Passed');
  });

  testWidgets('Marriage Multiplayer - Multiple Opponents Layout', (tester) async {
    // Set screen size to landscape 1080p
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Multiplayer game state with 4 players (1 human + 3 bots)
    final multiplayerState = MarriageGameState(
      tipluCardId: 'jack_hearts_0',
      playerHands: {
        'test_user_id': ['ace_spades_0', 'king_spades_0', 'queen_spades_0'],
        'bot_trickmaster_1': ['ace_hearts_0', 'king_hearts_0'],
        'bot_cardshark_2': ['ace_clubs_0', 'king_clubs_0'],
        'bot_luckydice_3': ['ace_diamonds_0', 'king_diamonds_0'],
      },
      deckCards: ['2_clubs_0', '3_clubs_0', '4_clubs_0'],
      discardPile: ['queen_hearts_0'],
      currentPlayerId: 'bot_trickmaster_1', // Bot's turn
      currentRound: 1,
      phase: 'playing',
      turnPhase: 'drawing',
      config: const MarriageGameConfig(),
    );

    when(() => mockMarriageService.watchGameState(any()))
        .thenAnswer((_) => Stream.value(multiplayerState));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marriageServiceProvider.overrideWithValue(mockMarriageService),
          authServiceProvider.overrideWithValue(mockAuthService),
          diamondServiceProvider.overrideWithValue(mockDiamondService),
          audioServiceProvider.overrideWith((ref, params) => mockAudioService),
          chatServiceProvider.overrideWith((ref, params) => mockChatService),
        ],
        child: const MaterialApp(
          home: MarriageMultiplayerScreen(roomId: 'multiplayer_room'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify deck labels still present
    expect(find.text('CLOSED DECK'), findsOneWidget);
    expect(find.text('OPEN DECK'), findsOneWidget);
    expect(find.text('FINISH SLOT'), findsOneWidget);

    // Verify opponent names are displayed
    expect(find.text('TrickMaster'), findsOneWidget, reason: 'TrickMaster bot name missing');
    expect(find.text('CardShark'), findsOneWidget, reason: 'CardShark bot name missing');
    expect(find.text('LuckyDice'), findsOneWidget, reason: 'LuckyDice bot name missing');

    // Verify it's NOT my turn (different indicator expected)
    expect(find.text('Waiting...'), findsOneWidget, reason: 'Waiting indicator should show when not my turn');

    debugPrint('✅ Marriage Multiplayer Widget Test Passed');
  });

  testWidgets('Marriage 8-Player - Maximum Capacity Layout', (tester) async {
    // Set screen size to landscape 1080p
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 8-player game state (1 human + 7 bots - maximum capacity)
    final eightPlayerState = MarriageGameState(
      tipluCardId: 'king_clubs_0',
      playerHands: {
        'test_user_id': ['ace_spades_0', 'king_spades_0', 'queen_spades_0'],
        'bot_trickmaster_1': ['ace_hearts_0', 'king_hearts_0'],
        'bot_cardshark_2': ['ace_clubs_0', 'king_clubs_0'],
        'bot_luckydice_3': ['ace_diamonds_0', 'king_diamonds_0'],
        'bot_deepthink_4': ['2_spades_0', '3_spades_0'],
        'bot_royalace_5': ['2_hearts_0', '3_hearts_0'],
        'bot_speedy_6': ['2_clubs_0', '3_clubs_0'],
        'bot_smart_7': ['2_diamonds_0', '3_diamonds_0'],
      },
      deckCards: ['4_clubs_0', '5_clubs_0', '6_clubs_0'],
      discardPile: ['queen_hearts_0'],
      currentPlayerId: 'test_user_id', // My turn
      currentRound: 1,
      phase: 'playing',
      turnPhase: 'discarding', // Discard phase
      config: const MarriageGameConfig(),
    );

    when(() => mockMarriageService.watchGameState(any()))
        .thenAnswer((_) => Stream.value(eightPlayerState));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marriageServiceProvider.overrideWithValue(mockMarriageService),
          authServiceProvider.overrideWithValue(mockAuthService),
          diamondServiceProvider.overrideWithValue(mockDiamondService),
          audioServiceProvider.overrideWith((ref, params) => mockAudioService),
          chatServiceProvider.overrideWith((ref, params) => mockChatService),
        ],
        child: const MaterialApp(
          home: MarriageMultiplayerScreen(roomId: 'eight_player_room'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify deck labels present
    expect(find.text('CLOSED DECK'), findsOneWidget);
    expect(find.text('OPEN DECK'), findsOneWidget);
    expect(find.text('FINISH SLOT'), findsOneWidget);

    // Verify all 7 opponent bot names are displayed
    // Verify all 7 opponent bot names are displayed
    expect(find.text('TrickMaster'), findsOneWidget);
    expect(find.text('CardShark'), findsOneWidget);
    expect(find.text('LuckyDice'), findsOneWidget);
    expect(find.text('DeepThink'), findsOneWidget);
    expect(find.text('RoyalAce'), findsOneWidget);
    expect(find.text('Speedy'), findsOneWidget);
    expect(find.text('Smart'), findsOneWidget);

    // Verify it's my turn with discard phase
    expect(find.text('📤 DISCARD'), findsOneWidget, reason: 'Discard phase indicator should show');

    debugPrint('✅ Marriage 8-Player Widget Test Passed');
  });
}
