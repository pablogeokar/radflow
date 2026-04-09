/// Canvas infinito do editor de nós (Blueprints).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/node_model.dart';
import '../../core/models/pin_model.dart';
import '../../core/providers/graph_provider.dart';
import '../painters/wire_painter.dart';
import '../widgets/node_widget.dart';

// Dimensões fixas do nó para cálculo de posição dos pinos sem GlobalKey.
const double _nodeWidth = 220;
const double _nodeHeaderHeight = 36;
const double _pinRowHeight = 20; // padding(4)*2 + dot(12)
const double _pinBodyPaddingV = 8;
const double _pinHPad = 8;

/// Calcula a posição central de um pino dentro do canvas (coordenadas locais).
Offset _pinOffset(NodeModel node, PinModel pin) {
  final isOutput = pin.direction == PinDirection.output;
  final pins = isOutput ? node.outputs : node.inputs;
  final index = pins.indexOf(pin);

  final dy =
      node.position.dy +
      _nodeHeaderHeight +
      _pinBodyPaddingV +
      index * (_pinRowHeight + 4) + // 4 = vertical padding entre rows
      _pinRowHeight / 2;

  final dx = isOutput
      ? node.position.dx +
            _nodeWidth -
            _pinHPad -
            6 // dot radius
      : node.position.dx + _pinHPad + 6;

  return Offset(dx, dy);
}

class NodeEditorCanvas extends ConsumerStatefulWidget {
  const NodeEditorCanvas({super.key});

  @override
  ConsumerState<NodeEditorCanvas> createState() => _NodeEditorCanvasState();
}

class _NodeEditorCanvasState extends ConsumerState<NodeEditorCanvas> {
  final TransformationController _transformController =
      TransformationController();

  String? _selectedNodeId;

  // Estado local do drag de conexão (não passa pelo provider a cada frame)
  String? _draggingFromNodeId;
  String? _draggingFromPinId;
  Offset? _dragStart; // em coordenadas do canvas
  Offset? _dragCurrent; // em coordenadas do canvas

  // Pino alvo sob o cursor
  String? _targetNodeId;
  String? _targetPinId;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // Converte posição global para coordenadas do canvas interno.
  Offset _toCanvas(Offset global) {
    final matrix = _transformController.value;
    final inverse = Matrix4.inverted(matrix);
    return MatrixUtils.transformPoint(inverse, global);
  }

  void _onPinDragStart(String nodeId, String pinId, Offset globalPos) {
    final canvasPos = _toCanvas(globalPos);
    setState(() {
      _draggingFromNodeId = nodeId;
      _draggingFromPinId = pinId;
      _dragStart = canvasPos;
      _dragCurrent = canvasPos;
      _targetNodeId = null;
      _targetPinId = null;
    });
  }

  void _onPinDragEnd(String nodeId, String pinId) {
    if (_draggingFromNodeId != null &&
        _targetNodeId != null &&
        _targetPinId != null) {
      ref
          .read(graphProvider.notifier)
          .tryConnect(
            fromNodeId: _draggingFromNodeId!,
            fromPinId: _draggingFromPinId!,
            toNodeId: _targetNodeId!,
            toPinId: _targetPinId!,
          );
    }
    setState(() {
      _draggingFromNodeId = null;
      _draggingFromPinId = null;
      _dragStart = null;
      _dragCurrent = null;
      _targetNodeId = null;
      _targetPinId = null;
    });
  }

  void _onPinHover(String nodeId, String pinId) {
    _targetNodeId = nodeId;
    _targetPinId = pinId;
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(graphProvider);
    final graph = editorState.graph;
    final notifier = ref.read(graphProvider.notifier);

    // Constrói wires a partir das posições calculadas geometricamente
    final wires = <WireData>[];
    for (final conn in graph.connections) {
      final fromNode = graph.nodeById(conn.fromNodeId);
      final toNode = graph.nodeById(conn.toNodeId);
      if (fromNode == null || toNode == null) continue;

      final fromPin = fromNode.pinById(conn.fromPinId);
      final toPin = toNode.pinById(conn.toPinId);
      if (fromPin == null || toPin == null) continue;

      wires.add(
        WireData(
          start: _pinOffset(fromNode, fromPin),
          end: _pinOffset(toNode, toPin),
          color: fromPin.color,
          connectionId: conn.id,
        ),
      );
    }

    // Cabo em drag (local, sem provider)
    WireData? draggingWire;
    if (_draggingFromNodeId != null &&
        _dragStart != null &&
        _dragCurrent != null) {
      final fromNode = graph.nodeById(_draggingFromNodeId!);
      final fromPin = fromNode?.pinById(_draggingFromPinId!);
      draggingWire = WireData.dragging(
        start: _dragStart!,
        end: _dragCurrent!,
        type: fromPin?.type ?? PinType.exec,
      );
    }

    return Listener(
      // Rastreia movimento do mouse para o cabo em drag
      onPointerMove: (event) {
        if (_draggingFromNodeId != null) {
          setState(() {
            _dragCurrent = _toCanvas(event.position);
          });
        }
      },
      onPointerUp: (_) {
        if (_draggingFromNodeId != null) {
          _onPinDragEnd(_draggingFromNodeId!, _draggingFromPinId!);
        }
      },
      child: GestureDetector(
        onTap: () => setState(() => _selectedNodeId = null),
        child: Container(
          color: const Color(0xFF11111B),
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.2,
            maxScale: 3.0,
            // Desativa pan do InteractiveViewer quando há drag de nó/pino
            panEnabled: _draggingFromNodeId == null,
            child: SizedBox(
              width: 4000,
              height: 3000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Grid de fundo
                  const Positioned.fill(child: _GridPainter()),
                  // Camada dos cabos
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: WirePainter(
                          wires: wires,
                          draggingWire: draggingWire,
                        ),
                      ),
                    ),
                  ),
                  // Camada dos nós
                  ...graph.nodes.map((node) {
                    return Positioned(
                      left: node.position.dx,
                      top: node.position.dy,
                      child: NodeWidget(
                        key: ValueKey(node.id),
                        node: node,
                        isSelected: _selectedNodeId == node.id,
                        onTap: () => setState(() => _selectedNodeId = node.id),
                        onMove: (delta) {
                          final scale = _transformController.value
                              .getMaxScaleOnAxis();
                          notifier.moveNode(node.id, delta / scale);
                        },
                        onDelete: () => notifier.removeNode(node.id),
                        onPinDragStart: _onPinDragStart,
                        onPinDragEnd: _onPinDragEnd,
                        onPinHover: _onPinHover,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grid de fundo desenhado como widget (não CustomPainter externo).
class _GridPainter extends StatelessWidget {
  const _GridPainter();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridCustomPainter());
  }
}

class _GridCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const smallStep = 24.0;
    const largeStep = 120.0;

    final smallPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..strokeWidth = 0.5;

    final largePaint = Paint()
      ..color = const Color(0xFF2A2A3E)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += smallStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), smallPaint);
    }
    for (double y = 0; y < size.height; y += smallStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), smallPaint);
    }
    for (double x = 0; x < size.width; x += largeStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), largePaint);
    }
    for (double y = 0; y < size.height; y += largeStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), largePaint);
    }
  }

  @override
  bool shouldRepaint(_GridCustomPainter old) => false;
}
