/// Toolbar superior do editor de blueprints.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/graph_evaluator.dart';
import '../../core/providers/graph_provider.dart';

class EditorToolbar extends ConsumerWidget {
  const EditorToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(graphProvider.notifier);
    final graph = ref.watch(graphProvider).graph;

    return Container(
      height: 48,
      color: const Color(0xFF1E1E2E),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo / título
          const Row(
            children: [
              Icon(
                Icons.account_tree_rounded,
                color: Color(0xFF89B4FA),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'RadFlow Blueprints',
                style: TextStyle(
                  color: Color(0xFFCDD6F4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Separador
          Container(width: 1, height: 24, color: const Color(0xFF313244)),
          const SizedBox(width: 16),
          // Botão Executar
          _ToolbarButton(
            icon: Icons.play_arrow_rounded,
            label: 'Executar',
            color: const Color(0xFFA6E3A1),
            onTap: () async {
              final evaluator = GraphEvaluator(graph);
              await evaluator.triggerEvent('OnButtonClicked');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grafo executado. Veja o console.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF313244),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          // Botão Exportar JSON
          _ToolbarButton(
            icon: Icons.download_rounded,
            label: 'Exportar JSON',
            color: const Color(0xFF89B4FA),
            onTap: () {
              final json = notifier.exportJson();
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('JSON copiado para a área de transferência.'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF313244),
                ),
              );
            },
          ),
          const Spacer(),
          // Contador de nós e conexões
          Text(
            '${graph.nodes.length} nós  •  ${graph.connections.length} conexões',
            style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
          ),
          const SizedBox(width: 16),
          // Legenda de tipos
          const _PinLegend(),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<_ToolbarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _hovered ? widget.color : const Color(0xFF313244),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinLegend extends StatelessWidget {
  const _PinLegend();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Exec', Color(0xFFFFFFFF)),
      ('String', Color(0xFFFF69B4)),
      ('Int', Color(0xFF4FC3F7)),
      ('Bool', Color(0xFFEF5350)),
      ('Float', Color(0xFFFFCA28)),
    ];

    return Row(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.$2,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                item.$1,
                style: const TextStyle(color: Color(0xFF6C7086), fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
