import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/voice_room_service.dart';

class VoiceRoomScreen extends ConsumerWidget {
  final String chatId;
  
  const VoiceRoomScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(voiceRoomServiceProvider(chatId));
    
    // Connect on mount if not connected
    // Note: Provider is autoDispose, so it creates fresh service.
    // We should trigger join once.
    
    // Ideally use useEffect or a StatefulWidget to init.
    
    return const _VoiceRoomContent();
  }
}

class _VoiceRoomContent extends ConsumerStatefulWidget {
  const _VoiceRoomContent();

  @override
  ConsumerState<_VoiceRoomContent> createState() => _VoiceRoomContentState();
}

class _VoiceRoomContentState extends ConsumerState<_VoiceRoomContent> {
  
  @override
  void initState() {
    super.initState();
    // Auto-join as speaker for now (or pass param)
    // Delay to allow build
    Future.microtask(() {
       // We can get chatId from parent provider family? No.
       // We need to pass chatId down or find it.
       // Actually, the provider is family. We can't easily find "which family" was used in parent
       // unless we pass it.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Redesign: Passed chatId to View
    // Rethink: The parent wrapper `VoiceRoomScreen` has `chatId`. 
    // It should pass it to `_VoiceRoomContent` or `_VoiceRoomContent` should take it.
    // Let's refactor the Screen to be StatefulWidget itself.
    return const SizedBox(); // Placeholder to fix compile error for now
  }
}

// Correct Implementation
class VoiceRoomPage extends ConsumerStatefulWidget {
  final String chatId;
  const VoiceRoomPage({super.key, required this.chatId});

  @override
  ConsumerState<VoiceRoomPage> createState() => _VoiceRoomPageState();
}

class _VoiceRoomPageState extends ConsumerState<VoiceRoomPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final service = ref.read(voiceRoomServiceProvider(widget.chatId));
      service.joinRoom(asListener: false); // Default to speaker for testing
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(voiceRoomServiceProvider(widget.chatId));
    final participants = service.allParticipants;

    return Scaffold(
      backgroundColor: const Color(0xFF1a0a2e), // Deep purple
      appBar: AppBar(
        title: const Text('Voice Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${participants.length} Active • ${service.state.name}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 3,
                 crossAxisSpacing: 16,
                 mainAxisSpacing: 16,
                 childAspectRatio: 0.8,
              ),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return _ParticipantTile(participant: participants[index]);
              },
            ),
          ),
          
          // Controls
          _buildControls(service),
        ],
      ),
    );
  }

  Widget _buildControls(VoiceRoomService service) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mic Toggle
            IconButton(
              onPressed: service.toggleMicrophone,
              icon: Icon(
                service.isMicEnabled ? Icons.mic : Icons.mic_off,
                color: service.isMicEnabled ? Colors.white : Colors.red,
                size: 32,
              ),
              style: IconButton.styleFrom(
                backgroundColor: service.isMicEnabled ? Colors.white.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            // Leave (Hangup)
            IconButton(
              onPressed: () {
                service.leaveRoom();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.call_end, color: Colors.white, size: 32),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;
  
  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    final isSpeaking = participant.isSpeaking;
    
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade800,
              border: isSpeaking ? Border.all(color: Colors.greenAccent, width: 3) : null,
              boxShadow: isSpeaking ? [
                BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)
              ] : null,
            ),
            child: Center(
              child: Text(
                participant.identity.isNotEmpty ? participant.identity[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ).animate(target: isSpeaking ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 200.ms),
        ),
        const SizedBox(height: 8),
        Text(
          participant.name ?? participant.identity,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
