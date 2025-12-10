import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent.freezed.dart';
part 'agent.g.dart';

/// Base agent type enumeration
enum AgentType {
  architect,   // Meta-orchestrator agent
  gaming,      // Game AI, bots, tips
  social,      // Chat moderation, translation
  economy,     // Rewards, fraud detection
  content,     // Story/post moderation
  notification, // Smart notifications
}

/// Agent capability flags
enum AgentCapability {
  textGeneration,
  imageAnalysis,
  translation,
  moderation,
  gameStrategy,
  fraudDetection,
  orchestration,
}

/// Agent request model
@freezed
class AgentRequest with _$AgentRequest {
  const factory AgentRequest({
    required String id,
    required AgentType targetAgent,
    required String action,
    required Map<String, dynamic> payload,
    String? userId,
    String? sessionId,
    @Default(AgentPriority.normal) AgentPriority priority,
    DateTime? createdAt,
    @Default(3) int maxRetries,
  }) = _AgentRequest;

  factory AgentRequest.fromJson(Map<String, dynamic> json) =>
      _$AgentRequestFromJson(json);
}

/// Agent response model
@freezed
class AgentResponse with _$AgentResponse {
  const factory AgentResponse({
    required String requestId,
    required AgentType agent,
    required bool success,
    Map<String, dynamic>? data,
    String? error,
    DateTime? completedAt,
    @Default(0) int processingTimeMs,
    AgentType? delegatedTo,
  }) = _AgentResponse;

  factory AgentResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentResponseFromJson(json);
}

/// Agent priority levels
enum AgentPriority {
  low,
  normal,
  high,
  critical,
}

/// Agent status
enum AgentStatus {
  idle,
  processing,
  waiting,
  error,
  disabled,
}

/// Agent configuration
@freezed
class AgentConfig with _$AgentConfig {
  const factory AgentConfig({
    required AgentType type,
    required String name,
    required String description,
    @Default([]) List<AgentCapability> capabilities,
    @Default(true) bool isEnabled,
    @Default(5) int maxConcurrentRequests,
    @Default(30000) int timeoutMs,
    String? modelId,
    Map<String, dynamic>? customConfig,
  }) = _AgentConfig;

  factory AgentConfig.fromJson(Map<String, dynamic> json) =>
      _$AgentConfigFromJson(json);
}

/// Agent metrics for monitoring
@freezed
class AgentMetrics with _$AgentMetrics {
  const factory AgentMetrics({
    required AgentType agent,
    @Default(0) int totalRequests,
    @Default(0) int successfulRequests,
    @Default(0) int failedRequests,
    @Default(0) double avgResponseTimeMs,
    DateTime? lastRequestAt,
    DateTime? lastErrorAt,
    String? lastError,
  }) = _AgentMetrics;

  factory AgentMetrics.fromJson(Map<String, dynamic> json) =>
      _$AgentMetricsFromJson(json);
}

/// Pre-configured agent definitions
class AgentDefinitions {
  static const architectAgent = AgentConfig(
    type: AgentType.architect,
    name: 'Architect Agent',
    description: 'Meta-orchestrator that routes requests to specialized agents',
    capabilities: [AgentCapability.orchestration],
    maxConcurrentRequests: 20,
  );

  static const gamingAgent = AgentConfig(
    type: AgentType.gaming,
    name: 'Gaming Agent',
    description: 'Handles game AI, bot behavior, and strategic tips',
    capabilities: [AgentCapability.gameStrategy, AgentCapability.textGeneration],
    modelId: 'gemini-1.5-flash',
  );

  static const socialAgent = AgentConfig(
    type: AgentType.social,
    name: 'Social Agent',
    description: 'Chat moderation, translation, and social interactions',
    capabilities: [AgentCapability.moderation, AgentCapability.translation, AgentCapability.textGeneration],
    modelId: 'gemini-1.5-flash',
  );

  static const economyAgent = AgentConfig(
    type: AgentType.economy,
    name: 'Economy Agent',
    description: 'Fraud detection, reward optimization, economy balancing',
    capabilities: [AgentCapability.fraudDetection],
  );

  static const contentAgent = AgentConfig(
    type: AgentType.content,
    name: 'Content Agent',
    description: 'Story and post content moderation',
    capabilities: [AgentCapability.moderation, AgentCapability.imageAnalysis],
  );

  static List<AgentConfig> get allAgents => [
    architectAgent,
    gamingAgent,
    socialAgent,
    economyAgent,
    contentAgent,
  ];
}
