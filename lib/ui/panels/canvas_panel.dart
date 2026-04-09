/// Painel central: preview da tela com device frame.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/widget_model.dart';
import '../../core/models/widget_props.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/selection_provider.dart';
import '../widgets/canvas_widget.dart';

class CanvasPanel extends ConsumerWidget {
  const CanvasPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final selection = ref.watch(selectionProvider);
    final device = selection.devicePreset;

    final page = project.pageById(selection.activePageId);
    final rootWidget = page != null
        ? project.widgetById(page.rootWidgetId)
        : null;

    return Container(
      color: const Color(0xFF181825),
      child: Column(
        children: [
          // Barra de device selector
          _DeviceBar(current: device),
          // Canvas com device frame
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(selectionProvider.notifier).selectWidget(null),
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.3,
                  maxScale: 2.0,
                  child: _DeviceFrame(
                    width: device.width,
                    height: device.height,
                    label: device.label,
                    child: rootWidget != null
                        ? _DropTarget(
                            project: project,
                            scaffoldId: rootWidget.id,
                            child: CanvasWidget(
                              model: rootWidget,
                              project: project,
                              isRoot: true,
                            ),
                          )
                        : const Center(child: Text('Nenhuma página')),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Device selector bar ───────────────────────────────────────────────────

class _DeviceBar extends ConsumerWidget {
  final DevicePreset current;
  const _DeviceBar({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 40,
      color: const Color(0xFF1E1E2E),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: DevicePreset.values.map((preset) {
          final active = preset == current;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () =>
                  ref.read(selectionProvider.notifier).setDevice(preset),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF6C63FF).withAlpha(40)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: active
                          ? const Color(0xFF6C63FF)
                          : const Color(0xFF313244),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _iconFor(preset),
                        size: 13,
                        color: active
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF6C7086),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        preset.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: active
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF6C7086),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(DevicePreset p) {
    switch (p) {
      case DevicePreset.phone:
        return Icons.phone_iphone;
      case DevicePreset.tablet:
        return Icons.tablet_mac;
      case DevicePreset.desktop:
        return Icons.desktop_mac;
    }
  }
}

// ── Device frame ──────────────────────────────────────────────────────────

class _DeviceFrame extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final Widget child;

  const _DeviceFrame({
    required this.width,
    required this.height,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label do device
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '$label  ${width.toInt()}×${height.toInt()}',
            style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
          ),
        ),
        // Frame
        Container(
          width: width + 24,
          height: height + 48,
          decoration: BoxDecoration(
            color: const Color(0xFF11111B),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFF45475A), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(120),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(33),
            child: Column(
              children: [
                // Notch
                Container(
                  height: 24,
                  color: const Color(0xFF11111B),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF313244),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                // Conteúdo
                SizedBox(width: width, height: height, child: child),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Drop target para soltar componentes no scaffold ───────────────────────

class _DropTarget extends ConsumerWidget {
  final dynamic project;
  final String scaffoldId;
  final Widget child;

  const _DropTarget({
    required this.project,
    required this.scaffoldId,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<WidgetType>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final scaffold = project.widgetById(scaffoldId);
        if (scaffold == null) return;
        // Adiciona ao primeiro filho (column/row) ou direto no scaffold
        final targetId = scaffold.childrenIds.isNotEmpty
            ? scaffold.childrenIds.first
            : scaffoldId;
        final newWidget = WidgetModel.create(details.data);
        ref.read(projectProvider.notifier).addWidget(newWidget, targetId);
        ref.read(selectionProvider.notifier).selectWidget(newWidget.id);
      },
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            child,
            if (candidateData.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withAlpha(20),
                      border: Border.all(
                        color: const Color(0xFF6C63FF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
