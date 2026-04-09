/// Gerenciador global do grafo de lógica visual.
library;

import 'dart:convert';
import 'node_model.dart';
import 'connection_model.dart';

/// Contém todos os nós e conexões do grafo.
class GraphModel {
  final List<NodeModel> nodes;
  final List<ConnectionModel> connections;

  const GraphModel({this.nodes = const [], this.connections = const []});

  /// Busca um nó pelo ID.
  NodeModel? nodeById(String id) {
    try {
      return nodes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retorna todas as conexões que partem de um nó específico.
  List<ConnectionModel> connectionsFrom(String nodeId) =>
      connections.where((c) => c.fromNodeId == nodeId).toList();

  /// Retorna todas as conexões que chegam em um nó específico.
  List<ConnectionModel> connectionsTo(String nodeId) =>
      connections.where((c) => c.toNodeId == nodeId).toList();

  /// Serializa o grafo para JSON.
  String toJson() => jsonEncode({
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'connections': connections.map((c) => c.toJson()).toList(),
  });

  /// Desserializa o grafo a partir de JSON.
  factory GraphModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return GraphModel(
      nodes: (map['nodes'] as List)
          .map((n) => NodeModel.fromJson(n as Map<String, dynamic>))
          .toList(),
      connections: (map['connections'] as List)
          .map((c) => ConnectionModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  GraphModel copyWith({
    List<NodeModel>? nodes,
    List<ConnectionModel>? connections,
  }) => GraphModel(
    nodes: nodes ?? this.nodes,
    connections: connections ?? this.connections,
  );
}
