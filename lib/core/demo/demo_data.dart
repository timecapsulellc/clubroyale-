import 'package:clubroyale/features/stories/models/story.dart';
import 'package:clubroyale/features/social/models/social_activity.dart';
import 'package:clubroyale/features/social/voice_rooms/models/voice_room.dart';
import 'package:clubroyale/features/game/game_room.dart';
import 'package:clubroyale/features/game/game_config.dart';

/// Demo data for Nanobanana UI visualization
class DemoData {
  
  // 1. Stories
  static List<UserStories> get stories => [
    UserStories(
      userId: 'demo_1',
      userName: 'Gold_Queen',
      userPhotoUrl: 'https://ui-avatars.com/api/?name=Gold+Queen&background=FFD700&color=fff&size=150',
      hasUnviewed: true,
      stories: [
        Story(
          id: 's1',
          userId: 'demo_1',
          userName: 'Gold_Queen',
          mediaUrl: 'https://picsum.photos/400/800',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        ),
      ],
    ),
    UserStories(
      userId: 'demo_2',
      userName: 'Teal_Jack',
      userPhotoUrl: 'https://ui-avatars.com/api/?name=Teal+Jack&background=008080&color=fff&size=150',
      hasUnviewed: true,
      stories: [
        Story(
          id: 's2', 
          userId: 'demo_2',
          userName: 'Teal_Jack',
          mediaUrl: 'https://picsum.photos/400/801',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        ),
      ],
    ),
    UserStories(
      userId: 'demo_3',
      userName: 'Purple_Ace',
      userPhotoUrl: 'https://ui-avatars.com/api/?name=Purple+Ace&background=7B68EE&color=fff&size=150',
      hasUnviewed: true,
      stories: [
        Story(
          id: 's3',
          userId: 'demo_3',
          userName: 'Purple_Ace',
          mediaUrl: 'https://picsum.photos/400/802',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 24)),
        ),
      ],
    ),
  ];

  // 2. Active Voice Rooms
  static List<VoiceRoom> get voiceRooms => [
    VoiceRoom(
      id: 'demo_room_1',
      name: 'AI Music Station 🎵',
      hostName: 'DJ_AI',
      hostId: 'host_1',
      participants: { 'p1': const VoiceParticipant(id: 'p1', name: 'P1') }, // Simplified
      createdAt: DateTime.now(),
    ),
    VoiceRoom(
      id: 'demo_room_2',
      name: 'Tech Podcast 🎙️',
      hostName: 'Elon_M',
      hostId: 'host_2',
      participants: Map.fromEntries(List.generate(50, (i) => MapEntry('p$i', VoiceParticipant(id: 'p$i', name: 'P$i')))),
      createdAt: DateTime.now(),
    ),
    VoiceRoom(
      id: 'demo_room_3',
      name: 'AI Film Watch Party 🎬',
      hostName: 'Cinebot',
      hostId: 'host_3',
      participants: {},
      createdAt: DateTime.now(),
    ),
  ];

  // 3. Active Games
  static List<GameRoom> get games => [
    GameRoom(
      id: 'demo_game_1',
      name: 'High Stakes #1',
      gameType: 'BlackJack Pro', 
      hostId: 'host_g1',
      status: GameStatus.playing,
      config: const GameConfig(maxPlayers: 5, bootAmount: 100),
      scores: {'p1': 100},
      players: [const Player(id: 'p1', name: 'P1')],
    ),
    GameRoom(
      id: 'demo_game_2',
      name: 'Royal Table',
      gameType: 'Poker Texas', 
      hostId: 'host_g2',
      status: GameStatus.playing,
      config: const GameConfig(maxPlayers: 8, bootAmount: 5000),
      scores: {},
      players: [],
    ),
  ];

  // 4. Activity Feed
  static List<SocialActivity> get activities => [
    SocialActivity(
      id: 'a1',
      userId: 'u1',
      userName: 'Luna_Win',
      userAvatar: 'https://ui-avatars.com/api/?name=Luna+Win&background=E91E63&color=fff&size=150',
      type: 'game_won', // String type based on model review
      content: 'won 10k coins in Roulette!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      metadata: {'amount': 10000},
    ),
    SocialActivity(
      id: 'a2',
      userId: 'u2', 
      userName: 'Max_Bet',
      userAvatar: 'https://ui-avatars.com/api/?name=Max+Bet&background=4CAF50&color=fff&size=150',
      type: 'club_joined',
      content: "joined the 'High Rollers' Club",
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];
}
