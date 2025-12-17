import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// IDE Guide Agent provider
final ideGuideAgentProvider = Provider<IDEGuideAgent>((ref) {
  return IDEGuideAgent();
});

/// IDE Guide Agent - Development Assistant for ClubRoyale
/// 
/// Provides AI-powered development assistance:
/// - Code generation with project context
/// - Architecture guidance and recommendations
/// - Bug analysis and fixing suggestions
/// - Feature implementation planning
class IDEGuideAgent {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ==================== CODE GENERATION ====================

  /// Generate code for a given task
  Future<CodeGenerationResult> generateCode({
    required String task,
    required String language,
    CodeContext? context,
    CodeStyle? style,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateCode');
      final result = await callable.call<Map<String, dynamic>>({
        'task': task,
        'language': language,
        if (context != null) 'projectContext': context.toJson(),
        if (style != null) 'codeStyle': style.toJson(),
      });

      return CodeGenerationResult.fromJson(result.data);
    } catch (e) {
      return CodeGenerationResult(
        code: '// Error generating code: $e',
        explanation: 'Failed to generate code. Please try again.',
      );
    }
  }

  /// Quick code suggestion without full generation
  Future<String> quickSuggestion(String prompt, {String language = 'dart'}) async {
    try {
      final callable = _functions.httpsCallable('quickCodeSuggestion');
      final result = await callable.call<Map<String, dynamic>>({
        'prompt': prompt,
        'language': language,
      });
      return result.data['suggestion'] as String? ?? '';
    } catch (e) {
      return '// Error: $e';
    }
  }

  // ==================== ARCHITECTURE GUIDANCE ====================

  /// Get architecture recommendations for a feature
  Future<ArchitectureRecommendation> getArchitectureGuidance({
    required String feature,
    required List<String> requirements,
    List<String>? constraints,
    String? existingArchitecture,
  }) async {
    try {
      final callable = _functions.httpsCallable('getArchitectureGuidance');
      final result = await callable.call<Map<String, dynamic>>({
        'feature': feature,
        'requirements': requirements,
        if (constraints != null) 'constraints': constraints,
        if (existingArchitecture != null) 'existingArchitecture': existingArchitecture,
      });

      return ArchitectureRecommendation.fromJson(result.data);
    } catch (e) {
      return ArchitectureRecommendation(
        approach: 'Error getting recommendation',
        components: [],
        dataFlow: '',
        integrationPoints: [],
        estimatedEffort: 'Unknown',
      );
    }
  }

  // ==================== BUG ANALYSIS ====================

  /// Analyze an error and suggest fixes
  Future<BugAnalysisResult> analyzeBug({
    required String errorMessage,
    String? stackTrace,
    String? codeContext,
    List<String>? recentChanges,
    String? environment,
  }) async {
    try {
      final callable = _functions.httpsCallable('analyzeBug');
      final result = await callable.call<Map<String, dynamic>>({
        'errorMessage': errorMessage,
        if (stackTrace != null) 'stackTrace': stackTrace,
        if (codeContext != null) 'codeContext': codeContext,
        if (recentChanges != null) 'recentChanges': recentChanges,
        if (environment != null) 'environment': environment,
      });

      return BugAnalysisResult.fromJson(result.data);
    } catch (e) {
      return BugAnalysisResult(
        rootCause: 'Unable to analyze',
        explanation: 'Error analyzing bug: $e',
        suggestedFix: '',
        preventionTips: [],
        confidence: 0.0,
      );
    }
  }

  // ==================== FEATURE PLANNING ====================

  /// Create an implementation plan for a feature
  Future<FeatureImplementationPlan> planFeature({
    required String featureName,
    required String featureDescription,
    List<String>? userStories,
    List<String>? acceptanceCriteria,
    String priority = 'medium',
  }) async {
    try {
      final callable = _functions.httpsCallable('planFeatureImplementation');
      final result = await callable.call<Map<String, dynamic>>({
        'featureName': featureName,
        'featureDescription': featureDescription,
        if (userStories != null) 'userStories': userStories,
        if (acceptanceCriteria != null) 'acceptanceCriteria': acceptanceCriteria,
        'priority': priority,
      });

      return FeatureImplementationPlan.fromJson(result.data);
    } catch (e) {
      return FeatureImplementationPlan(
        phases: [],
        totalEstimatedTime: 'Unknown',
        riskAreas: ['Unable to generate plan'],
        testPlan: [],
        filesAffected: [],
      );
    }
  }

  /// Explain what a piece of code does
  Future<CodeExplanation> explainCode(String code, {String language = 'dart'}) async {
    try {
      final callable = _functions.httpsCallable('explainCode');
      final result = await callable.call<Map<String, dynamic>>({
        'code': code,
        'language': language,
      });

      return CodeExplanation(
        explanation: result.data['explanation'] as String? ?? '',
        keyComponents: List<String>.from(result.data['keyComponents'] ?? []),
        potentialIssues: List<String>.from(result.data['potentialIssues'] ?? []),
      );
    } catch (e) {
      return CodeExplanation(
        explanation: 'Error explaining code: $e',
        keyComponents: [],
        potentialIssues: [],
      );
    }
  }
}

// ==================== DATA MODELS ====================

class CodeContext {
  final List<String>? existingPatterns;
  final String? currentFile;
  final List<String>? dependencies;
  final String? architecture;

  CodeContext({
    this.existingPatterns,
    this.currentFile,
    this.dependencies,
    this.architecture,
  });

  Map<String, dynamic> toJson() => {
    if (existingPatterns != null) 'existingPatterns': existingPatterns,
    if (currentFile != null) 'currentFile': currentFile,
    if (dependencies != null) 'dependencies': dependencies,
    if (architecture != null) 'architecture': architecture,
  };
}

class CodeStyle {
  final String? naming;
  final bool useRiverpod;
  final bool useFreezed;

  CodeStyle({
    this.naming,
    this.useRiverpod = true,
    this.useFreezed = true,
  });

  Map<String, dynamic> toJson() => {
    if (naming != null) 'naming': naming,
    'useRiverpod': useRiverpod,
    'useFreezed': useFreezed,
  };
}

class CodeGenerationResult {
  final String code;
  final String explanation;
  final List<FileToCreate>? filesToCreate;
  final List<FileToModify>? filesToModify;
  final String? tests;
  final List<String>? dependencies;

  CodeGenerationResult({
    required this.code,
    required this.explanation,
    this.filesToCreate,
    this.filesToModify,
    this.tests,
    this.dependencies,
  });

  factory CodeGenerationResult.fromJson(Map<String, dynamic> json) {
    return CodeGenerationResult(
      code: json['code'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      filesToCreate: (json['filesToCreate'] as List<dynamic>?)
          ?.map((f) => FileToCreate.fromJson(f))
          .toList(),
      filesToModify: (json['filesToModify'] as List<dynamic>?)
          ?.map((f) => FileToModify.fromJson(f))
          .toList(),
      tests: json['tests'] as String?,
      dependencies: (json['dependencies'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class FileToCreate {
  final String path;
  final String content;
  final String description;

  FileToCreate({required this.path, required this.content, required this.description});

  factory FileToCreate.fromJson(Map<String, dynamic> json) {
    return FileToCreate(
      path: json['path'] as String? ?? '',
      content: json['content'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class FileToModify {
  final String path;
  final String changes;
  final String reason;

  FileToModify({required this.path, required this.changes, required this.reason});

  factory FileToModify.fromJson(Map<String, dynamic> json) {
    return FileToModify(
      path: json['path'] as String? ?? '',
      changes: json['changes'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class ArchitectureRecommendation {
  final String approach;
  final List<ComponentSpec> components;
  final String dataFlow;
  final List<String> integrationPoints;
  final List<AlternativeApproach>? alternatives;
  final String estimatedEffort;
  final List<String>? risks;

  ArchitectureRecommendation({
    required this.approach,
    required this.components,
    required this.dataFlow,
    required this.integrationPoints,
    this.alternatives,
    required this.estimatedEffort,
    this.risks,
  });

  factory ArchitectureRecommendation.fromJson(Map<String, dynamic> json) {
    final rec = json['recommendation'] as Map<String, dynamic>? ?? json;
    return ArchitectureRecommendation(
      approach: rec['approach'] as String? ?? '',
      components: (rec['components'] as List<dynamic>?)
          ?.map((c) => ComponentSpec.fromJson(c))
          .toList() ?? [],
      dataFlow: rec['dataFlow'] as String? ?? '',
      integrationPoints: (rec['integrationPoints'] as List<dynamic>?)?.cast<String>() ?? [],
      alternatives: (json['alternatives'] as List<dynamic>?)
          ?.map((a) => AlternativeApproach.fromJson(a))
          .toList(),
      estimatedEffort: json['estimatedEffort'] as String? ?? '',
      risks: (json['risks'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class ComponentSpec {
  final String name;
  final String type;
  final String responsibility;
  final String file;

  ComponentSpec({
    required this.name,
    required this.type,
    required this.responsibility,
    required this.file,
  });

  factory ComponentSpec.fromJson(Map<String, dynamic> json) {
    return ComponentSpec(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      responsibility: json['responsibility'] as String? ?? '',
      file: json['file'] as String? ?? '',
    );
  }
}

class AlternativeApproach {
  final String approach;
  final List<String> pros;
  final List<String> cons;

  AlternativeApproach({required this.approach, required this.pros, required this.cons});

  factory AlternativeApproach.fromJson(Map<String, dynamic> json) {
    return AlternativeApproach(
      approach: json['approach'] as String? ?? '',
      pros: (json['pros'] as List<dynamic>?)?.cast<String>() ?? [],
      cons: (json['cons'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class BugAnalysisResult {
  final String rootCause;
  final String explanation;
  final String suggestedFix;
  final List<String> preventionTips;
  final List<String>? relatedIssues;
  final double confidence;

  BugAnalysisResult({
    required this.rootCause,
    required this.explanation,
    required this.suggestedFix,
    required this.preventionTips,
    this.relatedIssues,
    required this.confidence,
  });

  factory BugAnalysisResult.fromJson(Map<String, dynamic> json) {
    return BugAnalysisResult(
      rootCause: json['rootCause'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      suggestedFix: json['suggestedFix'] as String? ?? '',
      preventionTips: (json['preventionTips'] as List<dynamic>?)?.cast<String>() ?? [],
      relatedIssues: (json['relatedIssues'] as List<dynamic>?)?.cast<String>(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FeatureImplementationPlan {
  final List<ImplementationPhase> phases;
  final String totalEstimatedTime;
  final List<String> riskAreas;
  final List<String> testPlan;
  final List<String> filesAffected;

  FeatureImplementationPlan({
    required this.phases,
    required this.totalEstimatedTime,
    required this.riskAreas,
    required this.testPlan,
    required this.filesAffected,
  });

  factory FeatureImplementationPlan.fromJson(Map<String, dynamic> json) {
    return FeatureImplementationPlan(
      phases: (json['implementationPlan'] as List<dynamic>?)
          ?.map((p) => ImplementationPhase.fromJson(p))
          .toList() ?? [],
      totalEstimatedTime: json['totalEstimatedTime'] as String? ?? '',
      riskAreas: (json['riskAreas'] as List<dynamic>?)?.cast<String>() ?? [],
      testPlan: (json['testPlan'] as List<dynamic>?)?.cast<String>() ?? [],
      filesAffected: (json['filesAffected'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}

class ImplementationPhase {
  final int phase;
  final String title;
  final String description;
  final List<ImplementationTask> tasks;

  ImplementationPhase({
    required this.phase,
    required this.title,
    required this.description,
    required this.tasks,
  });

  factory ImplementationPhase.fromJson(Map<String, dynamic> json) {
    return ImplementationPhase(
      phase: json['phase'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tasks: (json['tasks'] as List<dynamic>?)
          ?.map((t) => ImplementationTask.fromJson(t))
          .toList() ?? [],
    );
  }
}

class ImplementationTask {
  final String task;
  final String file;
  final String estimatedTime;
  final List<String>? dependencies;
  final String? codeSnippet;

  ImplementationTask({
    required this.task,
    required this.file,
    required this.estimatedTime,
    this.dependencies,
    this.codeSnippet,
  });

  factory ImplementationTask.fromJson(Map<String, dynamic> json) {
    return ImplementationTask(
      task: json['task'] as String? ?? '',
      file: json['file'] as String? ?? '',
      estimatedTime: json['estimatedTime'] as String? ?? '',
      dependencies: (json['dependencies'] as List<dynamic>?)?.cast<String>(),
      codeSnippet: json['codeSnippet'] as String?,
    );
  }
}

class CodeExplanation {
  final String explanation;
  final List<String> keyComponents;
  final List<String> potentialIssues;

  CodeExplanation({
    required this.explanation,
    required this.keyComponents,
    required this.potentialIssues,
  });
}
