import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// MCP (Model Context Protocol) service provider
final mcpServiceProvider = Provider<MCPService>((ref) {
  return MCPService();
});

/// MCP Resource definition
class MCPResource {
  final String uri;
  final String name;
  final String? description;
  final String mimeType;

  MCPResource({
    required this.uri,
    required this.name,
    this.description,
    required this.mimeType,
  });

  factory MCPResource.fromJson(Map<String, dynamic> json) {
    return MCPResource(
      uri: json['uri'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String? ?? 'text/plain',
    );
  }
}

/// MCP Tool definition
class MCPTool {
  final String name;
  final String? description;
  final Map<String, dynamic> inputSchema;

  MCPTool({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  factory MCPTool.fromJson(Map<String, dynamic> json) {
    return MCPTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// MCP Prompt definition
class MCPPrompt {
  final String name;
  final String? description;
  final List<MCPPromptArgument> arguments;

  MCPPrompt({
    required this.name,
    this.description,
    this.arguments = const [],
  });

  factory MCPPrompt.fromJson(Map<String, dynamic> json) {
    return MCPPrompt(
      name: json['name'] as String,
      description: json['description'] as String?,
      arguments: (json['arguments'] as List?)
          ?.map((a) => MCPPromptArgument.fromJson(a))
          .toList() ?? [],
    );
  }
}

class MCPPromptArgument {
  final String name;
  final String? description;
  final bool required;

  MCPPromptArgument({
    required this.name,
    this.description,
    this.required = false,
  });

  factory MCPPromptArgument.fromJson(Map<String, dynamic> json) {
    return MCPPromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
    );
  }
}

/// MCP Service - Model Context Protocol Integration
/// Based on Anthropic's MCP specification for AI tool/resource management
class MCPService {
  String? _serverUrl;
  final Map<String, MCPResource> _resources = {};
  final Map<String, MCPTool> _tools = {};
  final Map<String, MCPPrompt> _prompts = {};

  /// Initialize connection to MCP server
  Future<bool> connect(String serverUrl) async {
    _serverUrl = serverUrl;
    
    try {
      // Fetch server capabilities
      final response = await http.get(Uri.parse('$serverUrl/capabilities'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Load resources
        if (data['resources'] != null) {
          await _loadResources();
        }
        
        // Load tools
        if (data['tools'] != null) {
          await _loadTools();
        }
        
        // Load prompts
        if (data['prompts'] != null) {
          await _loadPrompts();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('MCP connect error: $e');
      return false;
    }
  }

  Future<void> _loadResources() async {
    try {
      final response = await http.get(Uri.parse('$_serverUrl/resources/list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resources = (data['resources'] as List?)
            ?.map((r) => MCPResource.fromJson(r))
            .toList() ?? [];
        
        for (final resource in resources) {
          _resources[resource.uri] = resource;
        }
      }
    } catch (e) {
      print('Load resources error: $e');
    }
  }

  Future<void> _loadTools() async {
    try {
      final response = await http.get(Uri.parse('$_serverUrl/tools/list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tools = (data['tools'] as List?)
            ?.map((t) => MCPTool.fromJson(t))
            .toList() ?? [];
        
        for (final tool in tools) {
          _tools[tool.name] = tool;
        }
      }
    } catch (e) {
      print('Load tools error: $e');
    }
  }

  Future<void> _loadPrompts() async {
    try {
      final response = await http.get(Uri.parse('$_serverUrl/prompts/list'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prompts = (data['prompts'] as List?)
            ?.map((p) => MCPPrompt.fromJson(p))
            .toList() ?? [];
        
        for (final prompt in prompts) {
          _prompts[prompt.name] = prompt;
        }
      }
    } catch (e) {
      print('Load prompts error: $e');
    }
  }

  /// Get available resources
  List<MCPResource> get resources => _resources.values.toList();

  /// Get available tools
  List<MCPTool> get tools => _tools.values.toList();

  /// Get available prompts
  List<MCPPrompt> get prompts => _prompts.values.toList();

  /// Read a resource
  Future<String?> readResource(String uri) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/resources/read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uri': uri}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['contents']?[0]?['text'] as String?;
      }
      return null;
    } catch (e) {
      print('Read resource error: $e');
      return null;
    }
  }

  /// Call a tool
  Future<Map<String, dynamic>?> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/tools/call'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': toolName,
          'arguments': arguments,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Call tool error: $e');
      return null;
    }
  }

  /// Get a prompt
  Future<String?> getPrompt(
    String promptName,
    Map<String, String> arguments,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/prompts/get'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': promptName,
          'arguments': arguments,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['messages']?[0]?['content']?['text'] as String?;
      }
      return null;
    } catch (e) {
      print('Get prompt error: $e');
      return null;
    }
  }

  // ==================== ClubRoyale Specific MCP Methods ====================

  /// Register ClubRoyale game resources
  void registerGameResources() {
    _resources['clubroyale://games/callbreak/rules'] = MCPResource(
      uri: 'clubroyale://games/callbreak/rules',
      name: 'Call Break Rules',
      description: 'Complete rules for Call Break card game',
      mimeType: 'text/markdown',
    );

    _resources['clubroyale://games/marriage/rules'] = MCPResource(
      uri: 'clubroyale://games/marriage/rules',
      name: 'Marriage Rules',
      description: 'Complete rules for Marriage/Rummy card game',
      mimeType: 'text/markdown',
    );

    _resources['clubroyale://economy/rates'] = MCPResource(
      uri: 'clubroyale://economy/rates',
      name: 'Diamond Economy Rates',
      description: 'Current diamond earning and spending rates',
      mimeType: 'application/json',
    );
  }

  /// Register ClubRoyale tools
  void registerGameTools() {
    _tools['get_game_tip'] = MCPTool(
      name: 'get_game_tip',
      description: 'Get a strategic tip for the current game state',
      inputSchema: {
        'type': 'object',
        'properties': {
          'gameType': {'type': 'string'},
          'gameState': {'type': 'object'},
        },
        'required': ['gameType', 'gameState'],
      },
    );

    _tools['moderate_content'] = MCPTool(
      name: 'moderate_content',
      description: 'Check if content is appropriate',
      inputSchema: {
        'type': 'object',
        'properties': {
          'content': {'type': 'string'},
          'contentType': {'type': 'string'},
        },
        'required': ['content'],
      },
    );

    _tools['calculate_reward'] = MCPTool(
      name: 'calculate_reward',
      description: 'Calculate optimized reward amount',
      inputSchema: {
        'type': 'object',
        'properties': {
          'baseAmount': {'type': 'integer'},
          'userId': {'type': 'string'},
          'rewardType': {'type': 'string'},
        },
        'required': ['baseAmount'],
      },
    );
  }
}
