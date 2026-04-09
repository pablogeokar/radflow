/// Provider Riverpod para gerenciamento reativo do grafo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/graph_model.dart';
import '../models/node_model.dart';
import '../models/connection_model.dart';
import '../models/pin_model.dart';

const _uuid = Uuid();

/// Estado do editor: apenas o grafo.
/// O estado de drag de conexão é gerenciado localmente no canvas.
class EditorState {
  final GraphModel graph;

  const EditorState({required this.graph});

  EditorState copyWith({GraphModel? graph}) =>
      EditorState(graph: graph ?? this.graph);
}

/// Notifier principal do editor de grafos.
class GraphNotifier extends StateNotifier<EditorState> {
  GraphNotifier() : super(EditorState(graph: _buildDemoGraph()));

  // ── Nós ──────────────────────────────────────────────────────────────────

  void addNode(NodeModel node) {
    final nodes = [...state.graph.nodes, node];
    state = state.copyWith(graph: state.graph.copyWith(nodes: nodes));
  }

  void removeNode(String nodeId) {
    final nodes = state.graph.nodes.where((n) => n.id != nodeId).toList();
    final connections = state.graph.connections
        .where((c) => c.fromNodeId != nodeId && c.toNodeId != nodeId)
        .toList();
    state = state.copyWith(
      graph: state.graph.copyWith(nodes: nodes, connections: connections),
    );
  }

  void moveNode(String nodeId, Offset delta) {
    final nodes = state.graph.nodes.map((n) {
      if (n.id == nodeId) return n.copyWith(position: n.position + delta);
      return n;
    }).toList();
    state = state.copyWith(graph: state.graph.copyWith(nodes: nodes));
  }

  // ── Conexões ─────────────────────────────────────────────────────────────

  /// Tenta criar uma conexão entre dois pinos.
  /// [fromNodeId]/[fromPinId] = pino de origem do drag.
  /// [toNodeId]/[toPinId] = pino alvo onde o drag foi solto.
  void tryConnect({
    required String fromNodeId,
    required String fromPinId,
    required String toNodeId,
    required String toPinId,
  }) {
    if (fromNodeId == toNodeId) return;

    final fromNode = state.graph.nodeById(fromNodeId);
    final toNode = state.graph.nodeById(toNodeId);
    if (fromNode == null || toNode == null) return;

    final fromPin = fromNode.pinById(fromPinId);
    final toPin = toNode.pinById(toPinId);
    if (fromPin == null || toPin == null) return;

    if (!fromPin.isCompatibleWith(toPin)) return;

    // Normaliza: sempre output -> input
    final String srcNodeId;
    final String srcPinId;
    final String dstNodeId;
    final String dstPinId;

    if (fromPin.direction == PinDirection.output) {
      srcNodeId = fromNodeId;
      srcPinId = fromPinId;
      dstNodeId = toNodeId;
      dstPinId = toPinId;
    } else {
      srcNodeId = toNodeId;
      srcPinId = toPinId;
      dstNodeId = fromNodeId;
      dstPinId = fromPinId;
    }

    // Remove conexão existente no pino de entrada (1 entrada por pino)
    final connections =
        state.graph.connections
            .where((c) => !(c.toNodeId == dstNodeId && c.toPinId == dstPinId))
            .toList()
          ..add(
            ConnectionModel(
              id: _uuid.v4(),
              fromNodeId: srcNodeId,
              fromPinId: srcPinId,
              toNodeId: dstNodeId,
              toPinId: dstPinId,
            ),
          );

    // Marca pinos como conectados
    final nodes = state.graph.nodes.map((n) {
      if (n.id != srcNodeId && n.id != dstNodeId) return n;
      final updatedPins = n.allPins.map((p) {
        if ((n.id == srcNodeId && p.id == srcPinId) ||
            (n.id == dstNodeId && p.id == dstPinId)) {
          return p.copyWith(isConnected: true);
        }
        return p;
      }).toList();
      return NodeModel(
        id: n.id,
        title: n.title,
        category: n.category,
        position: n.position,
        inputs: updatedPins
            .where((p) => p.direction == PinDirection.input)
            .toList(),
        outputs: updatedPins
            .where((p) => p.direction == PinDirection.output)
            .toList(),
        execute: n.execute,
      );
    }).toList();

    state = state.copyWith(
      graph: state.graph.copyWith(nodes: nodes, connections: connections),
    );
  }

  void removeConnection(String connectionId) {
    final connections = state.graph.connections
        .where((c) => c.id != connectionId)
        .toList();
    state = state.copyWith(
      graph: state.graph.copyWith(connections: connections),
    );
  }

  // ── Serialização ─────────────────────────────────────────────────────────

  String exportJson() => state.graph.toJson();

  void importJson(String json) {
    state = state.copyWith(graph: GraphModel.fromJson(json));
  }
}

final graphProvider = StateNotifierProvider<GraphNotifier, EditorState>(
  (ref) => GraphNotifier(),
);

// ── Grafo de demonstração ─────────────────────────────────────────────────

GraphModel _buildDemoGraph() {
  final onClickNode = NodeModel(
    id: 'node_event_1',
    title: 'OnButtonClicked',
    category: NodeCategory.event,
    position: const Offset(80, 120),
    inputs: [],
    outputs: [
      PinModel(
        id: 'out_exec_1',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
    execute: (_) => {},
  );

  final printNode = NodeModel(
    id: 'node_action_1',
    title: 'Print String',
    category: NodeCategory.action,
    position: const Offset(380, 100),
    inputs: [
      PinModel(
        id: 'in_exec_1',
        label: '',
        type: PinType.exec,
        direction: PinDirection.input,
      ),
      PinModel(
        id: 'in_str_1',
        label: 'Texto',
        type: PinType.string,
        direction: PinDirection.input,
      ),
    ],
    outputs: [
      PinModel(
        id: 'out_exec_2',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
    execute: (inputs) {
      // ignore: avoid_print
      print('[Print] ${inputs['in_str_1']}');
      return {};
    },
  );

  final varNode = NodeModel(
    id: 'node_var_1',
    title: 'Get Variable',
    category: NodeCategory.variable,
    position: const Offset(80, 320),
    inputs: [],
    outputs: [
      PinModel(
        id: 'out_str_1',
        label: 'Valor',
        type: PinType.string,
        direction: PinDirection.output,
      ),
    ],
    execute: (_) => {'out_str_1': 'Olá, Blueprints!'},
  );

  final branchNode = NodeModel(
    id: 'node_logic_1',
    title: 'Branch',
    category: NodeCategory.logic,
    position: const Offset(680, 100),
    inputs: [
      PinModel(
        id: 'in_exec_b',
        label: '',
        type: PinType.exec,
        direction: PinDirection.input,
      ),
      PinModel(
        id: 'in_bool_1',
        label: 'Condição',
        type: PinType.bool_,
        direction: PinDirection.input,
      ),
    ],
    outputs: [
      PinModel(
        id: 'out_true',
        label: 'True',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
      PinModel(
        id: 'out_false',
        label: 'False',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
    execute: (inputs) {
      final cond = inputs['in_bool_1'] as bool? ?? false;
      return {'result': cond};
    },
  );

  return GraphModel(
    nodes: [onClickNode, printNode, varNode, branchNode],
    connections: [
      ConnectionModel(
        id: 'conn_1',
        fromNodeId: 'node_event_1',
        fromPinId: 'out_exec_1',
        toNodeId: 'node_action_1',
        toPinId: 'in_exec_1',
      ),
      ConnectionModel(
        id: 'conn_2',
        fromNodeId: 'node_var_1',
        fromPinId: 'out_str_1',
        toNodeId: 'node_action_1',
        toPinId: 'in_str_1',
      ),
      ConnectionModel(
        id: 'conn_3',
        fromNodeId: 'node_action_1',
        fromPinId: 'out_exec_2',
        toNodeId: 'node_logic_1',
        toPinId: 'in_exec_b',
      ),
    ],
  );
}
