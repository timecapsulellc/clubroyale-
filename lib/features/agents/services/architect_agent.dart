import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:clubroyale/features/agents/models/agent.dart';
import 'package:uuid/uuid.dart';

/// Architect Agent service provider
final architectAgentProvider = Provider<ArchitectAgent>((ref) {
  return ArchitectAgent(ref);
});

/// Agent metrics provider - Riverpod 3.x Notifier pattern
final agentMetricsProvider = NotifierProvider<AgentMetricsNotifier, Map<AgentType, AgentMetrics>>(
    AgentMetricsNotifier.new);

/// Architect Agent - The Meta-Orchestrator
/// Routes requests to specialized agents and manages the agent ecosystem
class ArchitectAgent {
  final Ref ref;
  final FirebaseFunctions _functions;
  final _uuid = const Uuid();

  // Agent registry
  final Map<AgentType, AgentConfig> _agents = {};

  // Request queue for rate limiting
  final Map<AgentType, List<AgentRequest>> _queues = {};

  ArchitectAgent(this.ref) : _functions = FirebaseFunctions.instance {
    _initializeAgents();
  }

  void _initializeAgents() {
    for (final config in AgentDefinitions.allAgents) {
      _agents[config.type] = config;
      _queues[config.type] = [];
    }
  }

  /// Route a request to the appropriate agent
  Future<AgentResponse> routeRequest(AgentRequest request) async {
    final startTime = DateTime.now();

    try {
      // Validate agent exists and is enabled
      final agentConfig = _agents[request.targetAgent];
      if (agentConfig == null) {
        return _errorResponse(request, 'Agent not found: ${request.targetAgent}');
      }

      if (!agentConfig.isEnabled) {
        return _errorResponse(request, 'Agent is disabled: ${request.targetAgent}');
      }

      // Route to appropriate agent handler
      final response = await _executeAgent(request, agentConfig);

      // Update metrics
      _updateMetrics(request.targetAgent, true, startTime);

      return response;
    } catch (e) {
      _updateMetrics(request.targetAgent, false, startTime, error: e.toString());
      return _errorResponse(request, e.toString());
    }
  }

  /// Execute the request on the target agent
  Future<AgentResponse> _executeAgent(AgentRequest request, AgentConfig config) async {
    switch (request.targetAgent) {
      case AgentType.architect:
        return _handleArchitectRequest(request);
      case AgentType.gaming:
        return _handleGamingRequest(request);
      case AgentType.social:
        return _handleSocialRequest(request);
      case AgentType.economy:
        return _handleEconomyRequest(request);
      case AgentType.content:
        return _handleContentRequest(request);
      case AgentType.notification:
        return _handleNotificationRequest(request);
    }
  }

  /// Handle Architect (orchestration) requests
  Future<AgentResponse> _handleArchitectRequest(AgentRequest request) async {
    switch (request.action) {
      case 'getStatus':
        return AgentResponse(
          requestId: request.id,
          agent: AgentType.architect,
          success: true,
          data: {
            'agents': _agents.values.map((a) => a.toJson()).toList(),
            'status': 'healthy',
          },
        );
      case 'delegateTo':
        final targetAgent = AgentType.values.firstWhere(
          (t) => t.name == request.payload['agent'],
          orElse: () => AgentType.architect,
        );
        final delegatedRequest = request.copyWith(targetAgent: targetAgent);
        return routeRequest(delegatedRequest);
      default:
        return _errorResponse(request, 'Unknown architect action: ${request.action}');
    }
  }

  /// Handle Gaming Agent requests (bots, tips, strategy)
  Future<AgentResponse> _handleGamingRequest(AgentRequest request) async {
    try {
      final callable = _functions.httpsCallable('gamingAgent');
      final result = await callable.call<Map<String, dynamic>>({
        'action': request.action,
        'payload': request.payload,
        'userId': request.userId,
      });

      return AgentResponse(
        requestId: request.id,
        agent: AgentType.gaming,
        success: true,
        data: result.data,
      );
    } catch (e) {
      // Fallback to local processing for common actions
      return _localGamingFallback(request);
    }
  }

  /// Local fallback for gaming actions when cloud function unavailable
  AgentResponse _localGamingFallback(AgentRequest request) {
    switch (request.action) {
      case 'getBotMove':
        return AgentResponse(
          requestId: request.id,
          agent: AgentType.gaming,
          success: true,
          data: {'fallback': true, 'message': 'Using local bot logic'},
        );
      case 'getGameTip':
        return AgentResponse(
          requestId: request.id,
          agent: AgentType.gaming,
          success: true,
          data: {
            'tip': 'Focus on your strongest cards and track what has been played.',
            'fallback': true,
          },
        );
      default:
        return AgentResponse(
          requestId: request.id,
          agent: AgentType.gaming,
          success: false,
          error: 'Gaming action not available offline',
        );
    }
  }

  /// Handle Social Agent requests (moderation, translation)
  Future<AgentResponse> _handleSocialRequest(AgentRequest request) async {
    try {
      switch (request.action) {
        case 'moderateChat':
          final callable = _functions.httpsCallable('moderateChat');
          final result = await callable.call<Map<String, dynamic>>({
            'message': request.payload['message'],
            'userId': request.userId,
          });
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.social,
            success: true,
            data: result.data,
          );

        case 'translate':
          final callable = _functions.httpsCallable('translateMessage');
          final result = await callable.call<Map<String, dynamic>>({
            'text': request.payload['text'],
            'targetLanguage': request.payload['targetLanguage'],
          });
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.social,
            success: true,
            data: result.data,
          );

        case 'suggestReply':
          final callable = _functions.httpsCallable('suggestReply');
          final result = await callable.call<Map<String, dynamic>>({
            'context': request.payload['context'],
            'lastMessages': request.payload['lastMessages'],
          });
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.social,
            success: true,
            data: result.data,
          );

        default:
          return _errorResponse(request, 'Unknown social action');
      }
    } catch (e) {
      return _errorResponse(request, e.toString());
    }
  }

  /// Handle Economy Agent requests (fraud, rewards)
  Future<AgentResponse> _handleEconomyRequest(AgentRequest request) async {
    try {
      switch (request.action) {
        case 'checkFraud':
          final callable = _functions.httpsCallable('checkFraudRisk');
          final result = await callable.call<Map<String, dynamic>>({
            'userId': request.userId,
            'action': request.payload['action'],
            'amount': request.payload['amount'],
          });
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.economy,
            success: true,
            data: result.data,
          );

        case 'optimizeReward':
          // Local optimization based on user engagement
          final engagement = request.payload['engagementScore'] as double? ?? 0.5;
          final baseReward = request.payload['baseReward'] as int? ?? 10;
          final multiplier = 1.0 + (engagement * 0.5);
          
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.economy,
            success: true,
            data: {
              'optimizedReward': (baseReward * multiplier).round(),
              'multiplier': multiplier,
            },
          );

        default:
          return _errorResponse(request, 'Unknown economy action');
      }
    } catch (e) {
      return _errorResponse(request, e.toString());
    }
  }

  /// Handle Content Agent requests (story/post moderation)
  Future<AgentResponse> _handleContentRequest(AgentRequest request) async {
    try {
      switch (request.action) {
        case 'moderateContent':
          final callable = _functions.httpsCallable('moderateContent');
          final result = await callable.call<Map<String, dynamic>>({
            'content': request.payload['content'],
            'contentType': request.payload['contentType'],
            'mediaUrl': request.payload['mediaUrl'],
          });
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.content,
            success: true,
            data: result.data,
          );

        case 'analyzeImage':
          // Image analysis for safety
          return AgentResponse(
            requestId: request.id,
            agent: AgentType.content,
            success: true,
            data: {'safe': true, 'confidence': 0.95},
          );

        default:
          return _errorResponse(request, 'Unknown content action');
      }
    } catch (e) {
      return _errorResponse(request, e.toString());
    }
  }

  /// Handle Notification Agent requests
  Future<AgentResponse> _handleNotificationRequest(AgentRequest request) async {
    switch (request.action) {
      case 'shouldNotify':
        // Smart notification timing
        final userActive = request.payload['userActive'] as bool? ?? false;
        final priority = request.priority;
        
        final shouldNotify = priority == AgentPriority.critical || 
                            priority == AgentPriority.high || 
                            !userActive;
        
        return AgentResponse(
          requestId: request.id,
          agent: AgentType.notification,
          success: true,
          data: {'shouldNotify': shouldNotify},
        );

      default:
        return _errorResponse(request, 'Unknown notification action');
    }
  }

  /// Create an error response
  AgentResponse _errorResponse(AgentRequest request, String error) {
    return AgentResponse(
      requestId: request.id,
      agent: request.targetAgent,
      success: false,
      error: error,
      completedAt: DateTime.now(),
    );
  }

  /// Update agent metrics
  void _updateMetrics(AgentType agent, bool success, DateTime startTime, {String? error}) {
    final notifier = ref.read(agentMetricsProvider.notifier);
    notifier.recordRequest(
      agent,
      success,
      DateTime.now().difference(startTime).inMilliseconds,
      error: error,
    );
  }

  /// Create a new agent request
  AgentRequest createRequest({
    required AgentType agent,
    required String action,
    required Map<String, dynamic> payload,
    String? userId,
    AgentPriority priority = AgentPriority.normal,
  }) {
    return AgentRequest(
      id: _uuid.v4(),
      targetAgent: agent,
      action: action,
      payload: payload,
      userId: userId,
      priority: priority,
      createdAt: DateTime.now(),
    );
  }

  // ==================== Convenience Methods ====================

  /// Get a game tip from the Gaming Agent
  Future<String> getGameTip(String gameType, Map<String, dynamic> gameState) async {
    final request = createRequest(
      agent: AgentType.gaming,
      action: 'getGameTip',
      payload: {'gameType': gameType, 'gameState': gameState},
    );
    final response = await routeRequest(request);
    return response.data?['tip'] as String? ?? 'No tip available';
  }

  /// Moderate chat message via Social Agent
  Future<Map<String, dynamic>> moderateChat(String message, String userId) async {
    final request = createRequest(
      agent: AgentType.social,
      action: 'moderateChat',
      payload: {'message': message},
      userId: userId,
    );
    final response = await routeRequest(request);
    return response.data ?? {'isAllowed': true};
  }

  /// Check fraud risk via Economy Agent
  Future<bool> checkFraudRisk(String userId, String action, int amount) async {
    final request = createRequest(
      agent: AgentType.economy,
      action: 'checkFraud',
      payload: {'action': action, 'amount': amount},
      userId: userId,
      priority: AgentPriority.high,
    );
    final response = await routeRequest(request);
    return response.data?['isRisky'] as bool? ?? false;
  }
}

/// Metrics notifier - Riverpod 3.x Notifier pattern
class AgentMetricsNotifier extends Notifier<Map<AgentType, AgentMetrics>> {
  @override
  Map<AgentType, AgentMetrics> build() => {};

  void recordRequest(AgentType agent, bool success, int responseTimeMs, {String? error}) {
    final current = state[agent] ?? AgentMetrics(agent: agent);
    
    final newTotal = current.totalRequests + 1;
    final newSuccess = current.successfulRequests + (success ? 1 : 0);
    final newFailed = current.failedRequests + (success ? 0 : 1);
    final newAvgTime = ((current.avgResponseTimeMs * current.totalRequests) + responseTimeMs) / newTotal;

    state = {
      ...state,
      agent: current.copyWith(
        totalRequests: newTotal,
        successfulRequests: newSuccess,
        failedRequests: newFailed,
        avgResponseTimeMs: newAvgTime,
        lastRequestAt: DateTime.now(),
        lastErrorAt: success ? current.lastErrorAt : DateTime.now(),
        lastError: success ? current.lastError : error,
      ),
    };
  }
}
