// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AgentRequest _$AgentRequestFromJson(Map<String, dynamic> json) =>
    _AgentRequest(
      id: json['id'] as String,
      targetAgent: $enumDecode(_$AgentTypeEnumMap, json['targetAgent']),
      action: json['action'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
      priority:
          $enumDecodeNullable(_$AgentPriorityEnumMap, json['priority']) ??
          AgentPriority.normal,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$AgentRequestToJson(_AgentRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetAgent': _$AgentTypeEnumMap[instance.targetAgent]!,
      'action': instance.action,
      'payload': instance.payload,
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'priority': _$AgentPriorityEnumMap[instance.priority]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'maxRetries': instance.maxRetries,
    };

const _$AgentTypeEnumMap = {
  AgentType.architect: 'architect',
  AgentType.gaming: 'gaming',
  AgentType.social: 'social',
  AgentType.economy: 'economy',
  AgentType.content: 'content',
  AgentType.notification: 'notification',
};

const _$AgentPriorityEnumMap = {
  AgentPriority.low: 'low',
  AgentPriority.normal: 'normal',
  AgentPriority.high: 'high',
  AgentPriority.critical: 'critical',
};

_AgentResponse _$AgentResponseFromJson(Map<String, dynamic> json) =>
    _AgentResponse(
      requestId: json['requestId'] as String,
      agent: $enumDecode(_$AgentTypeEnumMap, json['agent']),
      success: json['success'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt() ?? 0,
      delegatedTo: $enumDecodeNullable(_$AgentTypeEnumMap, json['delegatedTo']),
    );

Map<String, dynamic> _$AgentResponseToJson(_AgentResponse instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'agent': _$AgentTypeEnumMap[instance.agent]!,
      'success': instance.success,
      'data': instance.data,
      'error': instance.error,
      'completedAt': instance.completedAt?.toIso8601String(),
      'processingTimeMs': instance.processingTimeMs,
      'delegatedTo': _$AgentTypeEnumMap[instance.delegatedTo],
    };

_AgentConfig _$AgentConfigFromJson(Map<String, dynamic> json) => _AgentConfig(
  type: $enumDecode(_$AgentTypeEnumMap, json['type']),
  name: json['name'] as String,
  description: json['description'] as String,
  capabilities:
      (json['capabilities'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AgentCapabilityEnumMap, e))
          .toList() ??
      const [],
  isEnabled: json['isEnabled'] as bool? ?? true,
  maxConcurrentRequests: (json['maxConcurrentRequests'] as num?)?.toInt() ?? 5,
  timeoutMs: (json['timeoutMs'] as num?)?.toInt() ?? 30000,
  modelId: json['modelId'] as String?,
  customConfig: json['customConfig'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AgentConfigToJson(_AgentConfig instance) =>
    <String, dynamic>{
      'type': _$AgentTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'capabilities': instance.capabilities
          .map((e) => _$AgentCapabilityEnumMap[e]!)
          .toList(),
      'isEnabled': instance.isEnabled,
      'maxConcurrentRequests': instance.maxConcurrentRequests,
      'timeoutMs': instance.timeoutMs,
      'modelId': instance.modelId,
      'customConfig': instance.customConfig,
    };

const _$AgentCapabilityEnumMap = {
  AgentCapability.textGeneration: 'textGeneration',
  AgentCapability.imageAnalysis: 'imageAnalysis',
  AgentCapability.translation: 'translation',
  AgentCapability.moderation: 'moderation',
  AgentCapability.gameStrategy: 'gameStrategy',
  AgentCapability.fraudDetection: 'fraudDetection',
  AgentCapability.orchestration: 'orchestration',
};

_AgentMetrics _$AgentMetricsFromJson(Map<String, dynamic> json) =>
    _AgentMetrics(
      agent: $enumDecode(_$AgentTypeEnumMap, json['agent']),
      totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
      successfulRequests: (json['successfulRequests'] as num?)?.toInt() ?? 0,
      failedRequests: (json['failedRequests'] as num?)?.toInt() ?? 0,
      avgResponseTimeMs: (json['avgResponseTimeMs'] as num?)?.toDouble() ?? 0,
      lastRequestAt: json['lastRequestAt'] == null
          ? null
          : DateTime.parse(json['lastRequestAt'] as String),
      lastErrorAt: json['lastErrorAt'] == null
          ? null
          : DateTime.parse(json['lastErrorAt'] as String),
      lastError: json['lastError'] as String?,
    );

Map<String, dynamic> _$AgentMetricsToJson(_AgentMetrics instance) =>
    <String, dynamic>{
      'agent': _$AgentTypeEnumMap[instance.agent]!,
      'totalRequests': instance.totalRequests,
      'successfulRequests': instance.successfulRequests,
      'failedRequests': instance.failedRequests,
      'avgResponseTimeMs': instance.avgResponseTimeMs,
      'lastRequestAt': instance.lastRequestAt?.toIso8601String(),
      'lastErrorAt': instance.lastErrorAt?.toIso8601String(),
      'lastError': instance.lastError,
    };
