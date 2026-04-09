/// Widget visual de um pino de conexão.
library;

import 'package:flutter/material.dart';
import '../../core/models/pin_model.dart';

class PinWidget extends StatelessWidget {
  final PinModel pin;
  final String nodeId;
  final void Function(String nodeId, String pinId, Offset globalPos)
  onDragStart;
  final void Function(String nodeId, String pinId) onDragEnd;

  const PinWidget({
    super.key,
    required this.pin,
    required this.nodeId,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isExec = pin.type == PinType.exec;
    final isOutput = pin.direction == PinDirection.output;

    final dot = GestureDetector(
      // Usa onPanStart para capturar o início do drag no pino
      onPanStart: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final center = box.localToGlobal(box.size.center(Offset.zero));
        onDragStart(nodeId, pin.id, center);
      },
      // onPanUpdate e onPanEnd são tratados pelo Listener do canvas
      // para rastrear o cursor fora dos limites do widget
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: _PinDot(pin: pin, isExec: isExec),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isOutput
            ? [
                if (pin.label.isNotEmpty)
                  Text(
                    pin.label,
                    style: const TextStyle(
                      color: Color(0xFFCDD6F4),
                      fontSize: 11,
                    ),
                  ),
                if (pin.label.isNotEmpty) const SizedBox(width: 6),
                dot,
              ]
            : [
                dot,
                if (pin.label.isNotEmpty) const SizedBox(width: 6),
                if (pin.label.isNotEmpty)
                  Text(
                    pin.label,
                    style: const TextStyle(
                      color: Color(0xFFCDD6F4),
                      fontSize: 11,
                    ),
                  ),
              ],
      ),
    );
  }
}

class _PinDot extends StatefulWidget {
  final PinModel pin;
  final bool isExec;

  const _PinDot({required this.pin, required this.isExec});

  @override
  State<_PinDot> createState() => _PinDotState();
}

class _PinDotState extends State<_PinDot> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.pin.color;
    final size = widget.isExec ? 14.0 : 12.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.pin.isConnected || _hovered
              ? color
              : color.withAlpha(60),
          border: Border.all(color: color, width: 2),
          shape: widget.isExec ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: widget.isExec ? BorderRadius.circular(2) : null,
          boxShadow: _hovered
              ? [BoxShadow(color: color.withAlpha(120), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }
}
