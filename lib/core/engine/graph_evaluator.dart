/// Motor de execução do grafo de lógica visual.
library;

import '../models/graph_model.dart';
import '../models/node_model.dart';
import '../models/pin_model.dart';

/// Interpreta e executa o grafo a partir de um nó de evento.
class GraphEvaluator {
  final GraphModel graph;

  /// Cache de valores resolvidos por pino durante uma execução.
  final Map<String, dynamic> _resolvedValues = {};

  GraphEvaluator(this.graph);

  /// Inicia a execução a partir de um nó de evento pelo título.
  /// Ex: 'OnButtonClicked'
  Future<void> triggerEvent(String eventTitle) async {
    _resolvedValues.clear();

    final eventNode = _findEventNode(eventTitle);
    if (eventNode == null) {
      // ignore: avoid_print
      print('[GraphEvaluator] Evento "$eventTitle" não encontrado.');
      return;
    }

    await _executeNode(eventNode);
  }

  /// Executa um nó e segue o fluxo pelos pinos Exec de saída.
  Future<void> _executeNode(NodeModel node) async {
    // Resolve todos os pinos de dados de entrada antes de executar
    final inputValues = <String, dynamic>{};
    for (final pin in node.inputs) {
      if (pin.type != PinType.exec) {
        inputValues[pin.id] = await _resolveDataPin(node.id, pin.id);
      }
    }

    // Executa a lógica do nó
    Map<String, dynamic> outputValues = {};
    if (node.execute != null) {
      outputValues = node.execute!(inputValues);
    }

    // Armazena os valores de saída no cache
    for (final entry in outputValues.entries) {
      _resolvedValues['${node.id}:${entry.key}'] = entry.value;
    }

    // Segue o fluxo pelos pinos Exec de saída
    for (final outPin in node.outputs.where((p) => p.type == PinType.exec)) {
      final nextConnections = graph.connections
          .where((c) => c.fromNodeId == node.id && c.fromPinId == outPin.id)
          .toList();

      for (final conn in nextConnections) {
        final nextNode = graph.nodeById(conn.toNodeId);
        if (nextNode != null) {
          await _executeNode(nextNode);
        }
      }
    }
  }

  /// Resolve recursivamente o valor de um pino de dados de entrada.
  Future<dynamic> _resolveDataPin(String nodeId, String pinId) async {
    final cacheKey = '$nodeId:$pinId';
    if (_resolvedValues.containsKey(cacheKey)) {
      return _resolvedValues[cacheKey];
    }

    // Busca a conexão que alimenta este pino de entrada
    final connection = graph.connections
        .where((c) => c.toNodeId == nodeId && c.toPinId == pinId)
        .firstOrNull;

    if (connection == null) return null;

    // Resolve o nó de origem primeiro
    final sourceNode = graph.nodeById(connection.fromNodeId);
    if (sourceNode == null) return null;

    // Resolve os dados do nó de origem recursivamente
    final sourceInputs = <String, dynamic>{};
    for (final pin in sourceNode.inputs) {
      if (pin.type != PinType.exec) {
        sourceInputs[pin.id] = await _resolveDataPin(sourceNode.id, pin.id);
      }
    }

    Map<String, dynamic> sourceOutputs = {};
    if (sourceNode.execute != null) {
      sourceOutputs = sourceNode.execute!(sourceInputs);
    }

    // Armazena no cache
    for (final entry in sourceOutputs.entries) {
      _resolvedValues['${sourceNode.id}:${entry.key}'] = entry.value;
    }

    return _resolvedValues['${sourceNode.id}:${connection.fromPinId}'];
  }

  NodeModel? _findEventNode(String title) {
    try {
      return graph.nodes.firstWhere(
        (n) =>
            n.category == NodeCategory.event &&
            n.title.toLowerCase() == title.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
