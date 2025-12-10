import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// A2A (Agent-to-Agent) Protocol service provider
final a2aProtocolProvider = Provider<A2AProtocolService>((ref) {
  return A2AProtocolService();
});

/// Agent Card representing an AI Agent's capabilities
class AgentCard {
  final String agentId;
  final String name;
  final String description;
  final String version;
  final List<String> skills;
  final Map<String, String> endpoints;
  final Map<String, dynamic> metadata;

  AgentCard({
    required this.agentId,
    required this.name,
    required this.description,
    required this.version,
    required this.skills,
    required this.endpoints,
    this.metadata = const {},
  });

  factory AgentCard.fromJson(Map<String, dynamic> json) {
    return AgentCard(
      agentId: json['agentId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      skills: List<String>.from(json['skills'] ?? []),
      endpoints: Map<String, String>.from(json['endpoints'] ?? {}),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'agentId': agentId,
    'name': name,
    'description': description,
    'version': version,
    'skills': skills,
    'endpoints': endpoints,
    'metadata': metadata,
  };
}

/// A2A Task for inter-agent communication
class A2ATask {
  final String taskId;
  final String sourceAgent;
  final String targetAgent;
  final String action;
  final Map<String, dynamic> input;
  final DateTime createdAt;
  A2ATaskStatus status;
  Map<String, dynamic>? output;
  String? error;

  A2ATask({
    required this.taskId,
    required this.sourceAgent,
    required this.targetAgent,
    required this.action,
    required this.input,
    DateTime? createdAt,
    this.status = A2ATaskStatus.pending,
    this.output,
    this.error,
  }) : createdAt = createdAt ?? DateTime.now();

  factory A2ATask.fromJson(Map<String, dynamic> json) {
    return A2ATask(
      taskId: json['taskId'] as String,
      sourceAgent: json['sourceAgent'] as String,
      targetAgent: json['targetAgent'] as String,
      action: json['action'] as String,
      input: json['input'] as Map<String, dynamic>,
      status: A2ATaskStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => A2ATaskStatus.pending,
      ),
      output: json['output'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'taskId': taskId,
    'sourceAgent': sourceAgent,
    'targetAgent': targetAgent,
    'action': action,
    'input': input,
    'status': status.name,
    'output': output,
    'error': error,
  };
}

enum A2ATaskStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

/// A2A Protocol Service for Agent-to-Agent communication
/// Based on Google's Agent-to-Agent Protocol specification
class A2AProtocolService {
  final Map<String, AgentCard> _registeredAgents = {};
  final Map<String, A2ATask> _activeTasks = {};

  String? _baseUrl;

  /// Initialize with backend URL
  void initialize({required String baseUrl}) {
    _baseUrl = baseUrl;
  }

  /// Register a local agent
  void registerAgent(AgentCard card) {
    _registeredAgents[card.agentId] = card;
  }

  /// Discover remote agents
  Future<List<AgentCard>> discoverAgents(String discoveryUrl) async {
    try {
      final response = await http.get(Uri.parse(discoveryUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => AgentCard.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Agent discovery error: $e');
      return [];
    }
  }

  /// Send task to another agent
  Future<A2ATask> sendTask({
    required String sourceAgent,
    required String targetAgent,
    required String action,
    required Map<String, dynamic> input,
  }) async {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final task = A2ATask(
      taskId: taskId,
      sourceAgent: sourceAgent,
      targetAgent: targetAgent,
      action: action,
      input: input,
    );

    _activeTasks[taskId] = task;

    try {
      // Get target agent endpoint
      final targetCard = _registeredAgents[targetAgent];
      if (targetCard == null) {
        task.status = A2ATaskStatus.failed;
        task.error = 'Target agent not found';
        return task;
      }

      final endpoint = targetCard.endpoints['task'] ?? '$_baseUrl/a2a/task';

      // Send task
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        task.status = A2ATaskStatus.completed;
        task.output = result['output'] as Map<String, dynamic>?;
      } else {
        task.status = A2ATaskStatus.failed;
        task.error = 'HTTP ${response.statusCode}';
      }
    } catch (e) {
      task.status = A2ATaskStatus.failed;
      task.error = e.toString();
    }

    return task;
  }

  /// Get task status
  A2ATask? getTask(String taskId) => _activeTasks[taskId];

  /// Cancel a task
  void cancelTask(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null && task.status == A2ATaskStatus.pending) {
      task.status = A2ATaskStatus.cancelled;
    }
  }

  /// Stream task updates (for long-running tasks)
  Stream<A2ATask> taskUpdates(String taskId) async* {
    final task = _activeTasks[taskId];
    if (task == null) return;

    while (task.status == A2ATaskStatus.pending || 
           task.status == A2ATaskStatus.running) {
      yield task;
      await Future.delayed(const Duration(seconds: 1));
    }
    yield task; // Final status
  }

  // ==================== ClubRoyale Specific A2A Methods ====================

  /// Request game analysis from another agent
  Future<Map<String, dynamic>?> requestGameAnalysis({
    required String gameId,
    required String gameType,
    required Map<String, dynamic> gameState,
  }) async {
    final task = await sendTask(
      sourceAgent: 'clubroyale-architect',
      targetAgent: 'clubroyale-gaming',
      action: 'analyzeGame',
      input: {
        'gameId': gameId,
        'gameType': gameType,
        'gameState': gameState,
      },
    );

    return task.output;
  }

  /// Request moderation check from social agent
  Future<bool> requestModeration(String content) async {
    final task = await sendTask(
      sourceAgent: 'clubroyale-architect',
      targetAgent: 'clubroyale-social',
      action: 'moderate',
      input: {'content': content},
    );

    return task.output?['isAllowed'] as bool? ?? true;
  }
}
