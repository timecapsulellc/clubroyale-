import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';

/// Enum defining available Rive assets
enum RiveAsset {
  cardFlip('assets/rive/card_flip.riv'),
  confetti('assets/rive/confetti.riv'),
  winner('assets/rive/winner.riv'),
  star('assets/rive/star.riv'),
  button('assets/rive/button.riv');

  final String path;
  const RiveAsset(this.path);
}

/// A wrapper for Rive animations that handles loading and basic error states
class GameRiveAnimation extends StatefulWidget {
  final RiveAsset asset;
  final String? artboard;
  final String? animation;
  final String? stateMachine;
  final BoxFit fit;
  final VoidCallback? onInit;
  final ValueChanged<StateMachineController>? onStateMachineInit;

  const GameRiveAnimation({
    super.key,
    required this.asset,
    this.artboard,
    this.animation,
    this.stateMachine,
    this.fit = BoxFit.contain,
    this.onInit,
    this.onStateMachineInit,
  });

  @override
  State<GameRiveAnimation> createState() => _GameRiveAnimationState();
}

class _GameRiveAnimationState extends State<GameRiveAnimation> {
  Artboard? _riveArtboard;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      final data = await rootBundle.load(widget.asset.path);
      final file = RiveFile.import(data);

      final artboard = widget.artboard != null
          ? file.artboardByName(widget.artboard!)
          : file.mainArtboard;

      if (artboard != null) {
        if (widget.stateMachine != null) {
          final controller = StateMachineController.fromArtboard(
            artboard,
            widget.stateMachine!,
          );
          if (controller != null) {
            artboard.addController(controller);
            widget.onStateMachineInit?.call(controller);
          }
        } else if (widget.animation != null) {
          // Simple animation playback managed by RiveAnimation widget usually,
          // but efficiently managing artboard manually gives more control
          final controller = SimpleAnimation(widget.animation!);
          artboard.addController(controller);
        }
      }

      if (mounted) {
        setState(() {
          _riveArtboard = artboard;
        });
        widget.onInit?.call();
      }
    } catch (e) {
      debugPrint('Error loading Rive asset ${widget.asset.path}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_riveArtboard == null) {
      return const SizedBox.shrink();
    }

    return Rive(artboard: _riveArtboard!, fit: widget.fit);
  }
}

/// Specific widget for the Card Flip interaction
class RiveCardFlip extends StatefulWidget {
  final bool isFaceUp;
  final double width;
  final double height;

  const RiveCardFlip({
    super.key,
    required this.isFaceUp,
    this.width = 100,
    this.height = 140,
  });

  @override
  State<RiveCardFlip> createState() => _RiveCardFlipState();
}

class _RiveCardFlipState extends State<RiveCardFlip> {
  SMIBool? _isFaceUpInput;

  void _onStateMachineInit(StateMachineController controller) {
    // Note: Actual input name depends on the Rive file.
    // Common names: 'FaceUp', 'IsUp', 'Flip'.
    // We'll try to find a boolean input.
    if (controller.inputs.isNotEmpty) {
      for (var input in controller.inputs) {
        if (input is SMIBool) {
          _isFaceUpInput = input;
          // Set initial state
          _isFaceUpInput?.value = widget.isFaceUp;
          break;
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant RiveCardFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFaceUp != widget.isFaceUp) {
      _isFaceUpInput?.value = widget.isFaceUp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: GameRiveAnimation(
        asset: RiveAsset.cardFlip,
        stateMachine: 'State Machine 1', // Default machine name usually
        onStateMachineInit: _onStateMachineInit,
      ),
    );
  }
}

/// Widget for Confetti Celebration
class RiveConfetti extends StatelessWidget {
  final bool play;

  const RiveConfetti({super.key, required this.play});

  @override
  Widget build(BuildContext context) {
    if (!play) return const SizedBox.shrink();
    return const GameRiveAnimation(
      asset: RiveAsset.confetti,
      fit: BoxFit.cover,
      // Generic animation play
      animation: 'Explosion',
    );
  }
}

/// Widget for Winner Trophy
class RiveWinnerTrophy extends StatelessWidget {
  final double size;

  const RiveWinnerTrophy({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const GameRiveAnimation(
        asset: RiveAsset.winner,
        animation: 'Float', // Assuming default animation name
      ),
    );
  }
}

/// Widget for Star/Maal
class RiveStar extends StatelessWidget {
  final double size;

  const RiveStar({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const GameRiveAnimation(
        asset: RiveAsset.star,
        // Often 'Idle' or 'Sparkle'
      ),
    );
  }
}
