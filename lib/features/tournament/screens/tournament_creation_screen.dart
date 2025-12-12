/// Tournament Creation Screen
/// 
/// Allows users to create new tournaments

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clubroyale/features/tournament/tournament_model.dart';
import 'package:clubroyale/features/tournament/tournament_service.dart';
import 'package:clubroyale/features/auth/auth_service.dart';

class TournamentCreationScreen extends ConsumerStatefulWidget {
  const TournamentCreationScreen({super.key});

  @override
  ConsumerState<TournamentCreationScreen> createState() => _TournamentCreationScreenState();
}

class _TournamentCreationScreenState extends ConsumerState<TournamentCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _gameType = 'marriage';
  TournamentFormat _format = TournamentFormat.singleElimination;
  int _maxParticipants = 8;
  int? _prizePool;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tournament'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tournament Name',
                  hintText: 'e.g., Weekend Marriage Championship',
                  prefixIcon: Icon(Icons.emoji_events),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your tournament...',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Game Type
              Text('Game Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _GameTypeChip(
                    label: 'Marriage',
                    value: 'marriage',
                    selected: _gameType == 'marriage',
                    onSelected: () => setState(() => _gameType = 'marriage'),
                  ),
                  _GameTypeChip(
                    label: 'Call Break',
                    value: 'call_break',
                    selected: _gameType == 'call_break',
                    onSelected: () => setState(() => _gameType = 'call_break'),
                  ),
                  _GameTypeChip(
                    label: 'Teen Patti',
                    value: 'teen_patti',
                    selected: _gameType == 'teen_patti',
                    onSelected: () => setState(() => _gameType = 'teen_patti'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Format
              Text('Format', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<TournamentFormat>(
                segments: const [
                  ButtonSegment(
                    value: TournamentFormat.singleElimination,
                    label: Text('Single Elim'),
                    icon: Icon(Icons.arrow_forward),
                  ),
                  ButtonSegment(
                    value: TournamentFormat.roundRobin,
                    label: Text('Round Robin'),
                    icon: Icon(Icons.loop),
                  ),
                ],
                selected: {_format},
                onSelectionChanged: (s) => setState(() => _format = s.first),
              ),
              const SizedBox(height: 24),
              
              // Max Participants
              Text('Max Participants', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Slider(
                value: _maxParticipants.toDouble(),
                min: 4,
                max: 32,
                divisions: 7,
                label: '$_maxParticipants players',
                onChanged: (v) => setState(() => _maxParticipants = v.round()),
              ),
              Center(
                child: Text(
                  '$_maxParticipants players',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 24),
              
              // Prize Pool (optional)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Prize Pool (Diamonds)',
                  hintText: 'Optional',
                  prefixIcon: Icon(Icons.diamond),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _prizePool = int.tryParse(v),
              ),
              const SizedBox(height: 32),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _createTournament,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Tournament'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final tournamentId = await ref.read(tournamentServiceProvider).createTournament(
        hostId: user.uid,
        hostName: user.displayName ?? 'Host',
        name: _nameController.text,
        description: _descriptionController.text,
        gameType: _gameType,
        format: _format,
        maxParticipants: _maxParticipants,
        prizePool: _prizePool,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _GameTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onSelected;

  const _GameTypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
