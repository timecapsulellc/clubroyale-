/// Agent Models
/// 
/// Defines the data models for the agent system.
/// Using plain Dart classes for compatibility.
library;

import 'package:json_annotation/json_annotation.dart';

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

/// Agent request model
@JsonSerializable()
class AgentRequest {
  final String id;
  final AgentType targetAgent;
  final String action;
  final Map<String, dynamic> payload;
  final String? userId;
  final String? sessionId;
  final AgentPriority priority;
  final DateTime? createdAt;
  final int maxRetries;

  const AgentRequest({
    required this.id,
    required this.targetAgent,
    required this.action,
    required this.payload,
    this.userId,
    this.sessionId,
    this.priority = AgentPriority.normal,
    this.createdAt,
    this.maxRetries = 3,
  });

  factory AgentRequest.fromJson(Map<String, dynamic> json) =>
      _$AgentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AgentRequestToJson(this);

  AgentRequest copyWith({
    String? id,
    AgentType? targetAgent,
    String? action,
    Map<String, dynamic>? payload,
    String? userId,
    String? sessionId,
    AgentPriority? priority,
    DateTime? createdAt,
    int? maxRetries,
  }) {
    return AgentRequest(
      id: id ?? this.id,
      targetAgent: targetAgent ?? this.targetAgent,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentRequest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Agent response model
@JsonSerializable()
class AgentResponse {
  final String requestId;
  final AgentType agent;
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final DateTime? completedAt;
  final int processingTimeMs;
  final AgentType? delegatedTo;

  const AgentResponse({
    required this.requestId,
    required this.agent,
    required this.success,
    this.data,
    this.error,
    this.completedAt,
    this.processingTimeMs = 0,
    this.delegatedTo,
  });

  factory AgentResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AgentResponseToJson(this);

  AgentResponse copyWith({
    String? requestId,
    AgentType? agent,
    bool? success,
    Map<String, dynamic>? data,
    String? error,
    DateTime? completedAt,
    int? processingTimeMs,
    AgentType? delegatedTo,
  }) {
    return AgentResponse(
      requestId: requestId ?? this.requestId,
      agent: agent ?? this.agent,
      success: success ?? this.success,
      data: data ?? this.data,
      error: error ?? this.error,
      completedAt: completedAt ?? this.completedAt,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      delegatedTo: delegatedTo ?? this.delegatedTo,
    );
  }
}

/// Agent configuration
@JsonSerializable()
class AgentConfig {
  final AgentType type;
  final String name;
  final String description;
  final List<AgentCapability> capabilities;
  final bool isEnabled;
  final int maxConcurrentRequests;
  final int timeoutMs;
  final String? modelId;
  final Map<String, dynamic>? customConfig;

  const AgentConfig({
    required this.type,
    required this.name,
    required this.description,
    this.capabilities = const [],
    this.isEnabled = true,
    this.maxConcurrentRequests = 5,
    this.timeoutMs = 30000,
    this.modelId,
    this.customConfig,
  });

  factory AgentConfig.fromJson(Map<String, dynamic> json) =>
      _$AgentConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AgentConfigToJson(this);

  AgentConfig copyWith({
    AgentType? type,
    String? name,
    String? description,
    List<AgentCapability>? capabilities,
    bool? isEnabled,
    int? maxConcurrentRequests,
    int? timeoutMs,
    String? modelId,
    Map<String, dynamic>? customConfig,
  }) {
    return AgentConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      capabilities: capabilities ?? this.capabilities,
      isEnabled: isEnabled ?? this.isEnabled,
      maxConcurrentRequests: maxConcurrentRequests ?? this.maxConcurrentRequests,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      modelId: modelId ?? this.modelId,
      customConfig: customConfig ?? this.customConfig,
    );
  }
}

/// Agent metrics for monitoring
@JsonSerializable()
class AgentMetrics {
  final AgentType agent;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double avgResponseTimeMs;
  final DateTime? lastRequestAt;
  final DateTime? lastErrorAt;
  final String? lastError;

  const AgentMetrics({
    required this.agent,
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.failedRequests = 0,
    this.avgResponseTimeMs = 0,
    this.lastRequestAt,
    this.lastErrorAt,
    this.lastError,
  });

  factory AgentMetrics.fromJson(Map<String, dynamic> json) =>
      _$AgentMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$AgentMetricsToJson(this);

  AgentMetrics copyWith({
    AgentType? agent,
    int? totalRequests,
    int? successfulRequests,
    int? failedRequests,
    double? avgResponseTimeMs,
    DateTime? lastRequestAt,
    DateTime? lastErrorAt,
    String? lastError,
  }) {
    return AgentMetrics(
      agent: agent ?? this.agent,
      totalRequests: totalRequests ?? this.totalRequests,
      successfulRequests: successfulRequests ?? this.successfulRequests,
      failedRequests: failedRequests ?? this.failedRequests,
      avgResponseTimeMs: avgResponseTimeMs ?? this.avgResponseTimeMs,
      lastRequestAt: lastRequestAt ?? this.lastRequestAt,
      lastErrorAt: lastErrorAt ?? this.lastErrorAt,
      lastError: lastError ?? this.lastError,
    );
  }
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
