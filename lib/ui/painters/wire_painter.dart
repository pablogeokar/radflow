/// Painter para desenhar os cabos (wires) entre pinos usando curvas Bézier.
library;

import 'package:flutter/material.dart';
import '../../core/models/pin_model.dart';

class WirePainter extends CustomPainter {
  final List<WireData> wires;
  final WireData? draggingWire;

  WirePainter({required this.wires, this.draggingWire});

  @override
  void paint(Canvas canvas, Size size) {
    for (final wire in wires) {
      _drawWire(canvas, wire, alpha: 220);
    }
    if (draggingWire != null) {
      _drawWire(canvas, draggingWire!, alpha: 160, dashed: true);
    }
  }

  void _drawWire(
    Canvas canvas,
    WireData wire, {
    int alpha = 255,
    bool dashed = false,
  }) {
    final paint = Paint()
      ..color = wire.color.withAlpha(alpha)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = _buildBezierPath(wire.start, wire.end);

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      // Sombra sutil
      final shadowPaint = Paint()
        ..color = Colors.black.withAlpha(80)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, paint);
    }
  }

  Path _buildBezierPath(Offset start, Offset end) {
    final dx = (end.dx - start.dx).abs().clamp(80.0, 300.0);
    final cp1 = Offset(start.dx + dx, start.dy);
    final cp2 = Offset(end.dx - dx, end.dy);

    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 5.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(WirePainter oldDelegate) =>
      oldDelegate.wires != wires || oldDelegate.draggingWire != draggingWire;
}

/// Dados de um cabo para renderização.
class WireData {
  final Offset start;
  final Offset end;
  final Color color;
  final String connectionId;

  const WireData({
    required this.start,
    required this.end,
    required this.color,
    required this.connectionId,
  });

  /// Cor padrão para cabo em drag.
  static WireData dragging({
    required Offset start,
    required Offset end,
    required PinType type,
  }) => WireData(
    start: start,
    end: end,
    color: _colorForType(type),
    connectionId: '__dragging__',
  );

  static Color _colorForType(PinType type) {
    switch (type) {
      case PinType.exec:
        return Colors.white;
      case PinType.string:
        return const Color(0xFFFF69B4);
      case PinType.int_:
        return const Color(0xFF4FC3F7);
      case PinType.bool_:
        return const Color(0xFFEF5350);
      case PinType.object:
        return const Color(0xFF66BB6A);
      case PinType.float:
        return const Color(0xFFFFCA28);
    }
  }
}
