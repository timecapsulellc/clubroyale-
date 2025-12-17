import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clubroyale/features/stories/widgets/story_bar.dart';
import 'package:clubroyale/features/social/widgets/quick_social_actions.dart';
import 'package:clubroyale/features/social/widgets/social_feed_widget.dart';
import 'package:clubroyale/features/social/widgets/live_activity_section.dart';
import 'package:clubroyale/features/social/providers/dashboard_providers.dart';
import 'package:clubroyale/features/stories/services/story_service.dart';
import 'package:clubroyale/features/home/widgets/compact_header.dart';
import 'package:clubroyale/core/widgets/social_bottom_nav.dart' as social_nav;

/// HomeScreen - Nanobanana Dashboard Design
/// 
/// Layout:
/// 1. CompactHeader (Avatar + Name + Diamond Balance + Settings)
/// 2. StoryBar (Colored rings: gold/teal/purple)
/// 3. LiveActivitySection (Purple Voice Room + Green Game Match cards)
/// 4. QuickSocialActions (Pill buttons)
/// 5. SocialFeedWidget (Glassmorphism activity feed)
/// 6. SocialBottomNav (Gold Play button, frosted glass)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('📍 HomeScreen.build called');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final contentMaxWidth = 800.0;
        
        return Scaffold(
          backgroundColor: const Color(0xFF1a0a2e),
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1a0a2e), Color(0xFF2d1b4e), Color(0xFF1a0a2e)],
                  ),
                ),
              ),
              
              // Main Content
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    children: [
                      // 1. Compact Header (Avatar + Name + Diamond + Settings)
                      const CompactHeader(),
                      
                      // 2. Scrollable Content
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(unreadChatsCountProvider);
                            ref.invalidate(onlineFriendsCountProvider);
                            ref.invalidate(activeVoiceRoomsProvider);
                            ref.invalidate(spectatorGamesProvider);
                            ref.invalidate(friendsStoriesProvider);
                            ref.invalidate(myStoriesProvider);
                            ref.invalidate(activityFeedProvider(5));
                          },
                          color: const Color(0xFFD4AF37),
                          backgroundColor: const Color(0xFF1a0a2e),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: EdgeInsets.only(bottom: isDesktop ? 120 : 100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Story Bar
                                const StoryBar().animate().fadeIn(delay: 100.ms),
                                
                                const SizedBox(height: 8),
                                
                                // Live Activity Section
                                const LiveActivitySection().animate().fadeIn(delay: 150.ms),
                                
                                const SizedBox(height: 8),
                                
                                // Quick Actions
                                const QuickSocialActions().animate().fadeIn(delay: 200.ms),
                                
                                const SizedBox(height: 8),
                                
                                // Activity Feed (Glassmorphism)
                                const SocialFeedWidget(maxItems: 5).animate().fadeIn(delay: 250.ms),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 3. Bottom Navigation with Gold Play Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: isDesktop ? 24.0 : 0),
                  child: SizedBox(
                    width: isDesktop ? 450 : double.infinity,
                    child: social_nav.SocialBottomNav(
                      currentIndex: 0,
                      isFloating: isDesktop,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
