/// Widget visual de um nó no editor de blueprints.
library;

import 'package:flutter/material.dart';
import '../../core/models/node_model.dart';
import '../../core/models/pin_model.dart';
import 'pin_widget.dart';

class NodeWidget extends StatefulWidget {
  final NodeModel node;
  final bool isSelected;
  final void Function(Offset delta) onMove;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final void Function(String nodeId, String pinId, Offset globalPos)
  onPinDragStart;
  final void Function(String nodeId, String pinId) onPinDragEnd;
  final void Function(String nodeId, String pinId) onPinHover;

  const NodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.onMove,
    required this.onTap,
    required this.onDelete,
    required this.onPinDragStart,
    required this.onPinDragEnd,
    required this.onPinHover,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final headerColor = node.category.headerColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF89B4FA)
                  : _hovered
                  ? const Color(0xFF585B70)
                  : const Color(0xFF313244),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? const Color(0xFF89B4FA).withAlpha(60)
                    : Colors.black.withAlpha(100),
                blurRadius: widget.isSelected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho: drag para mover o nó
                _DraggableHeader(
                  title: node.title,
                  color: headerColor,
                  onMove: widget.onMove,
                  onDelete: widget.onDelete,
                ),
                // Corpo com pinos
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _NodeBody(
                    node: node,
                    onPinDragStart: widget.onPinDragStart,
                    onPinDragEnd: widget.onPinDragEnd,
                    onPinHover: widget.onPinHover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Header do nó com drag para mover — isolado para não conflitar com pinos.
class _DraggableHeader extends StatelessWidget {
  final String title;
  final Color color;
  final void Function(Offset delta) onMove;
  final VoidCallback onDelete;

  const _DraggableHeader({
    required this.title,
    required this.color,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) => onMove(d.delta),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          height: 36,
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NodeBody extends StatelessWidget {
  final NodeModel node;
  final void Function(String, String, Offset) onPinDragStart;
  final void Function(String, String) onPinDragEnd;
  final void Function(String, String) onPinHover;

  const _NodeBody({
    required this.node,
    required this.onPinDragStart,
    required this.onPinDragEnd,
    required this.onPinHover,
  });

  @override
  Widget build(BuildContext context) {
    final maxRows = node.inputs.length > node.outputs.length
        ? node.inputs.length
        : node.outputs.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRows, (i) {
        final input = i < node.inputs.length ? node.inputs[i] : null;
        final output = i < node.outputs.length ? node.outputs[i] : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (input != null)
                _buildPin(input)
              else
                const SizedBox(width: 80),
              if (output != null)
                _buildPin(output)
              else
                const SizedBox(width: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPin(PinModel pin) {
    return MouseRegion(
      onEnter: (_) => onPinHover(node.id, pin.id),
      child: PinWidget(
        pin: pin,
        nodeId: node.id,
        onDragStart: onPinDragStart,
        onDragEnd: onPinDragEnd,
      ),
    );
  }
}
