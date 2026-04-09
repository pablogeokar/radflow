/// Toolbar superior do RadFlow Studio.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../codegen/dart_generator.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/selection_provider.dart';

class StudioToolbar extends ConsumerWidget {
  const StudioToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final selection = ref.watch(selectionProvider);
    final notifier = ref.read(projectProvider.notifier);

    return Container(
      height: 48,
      color: const Color(0xFF1E1E2E),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Logo
          const Row(
            children: [
              Icon(Icons.widgets_rounded, color: Color(0xFF6C63FF), size: 22),
              SizedBox(width: 8),
              Text(
                'RadFlow Studio',
                style: TextStyle(
                  color: Color(0xFFCDD6F4),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Container(width: 1, height: 24, color: const Color(0xFF313244)),
          const SizedBox(width: 16),

          // Páginas
          ..._buildPageTabs(context, ref, project, selection),

          // Botão nova página
          _ToolbarIconButton(
            icon: Icons.add,
            tooltip: 'Nova página',
            onTap: () => _showAddPageDialog(context, notifier),
          ),

          const Spacer(),

          // Exportar código
          _ToolbarButton(
            icon: Icons.code_rounded,
            label: 'Exportar Dart',
            color: const Color(0xFFA6E3A1),
            onTap: () {
              final code = DartGenerator(project).generate();
              _showCodeDialog(context, code);
            },
          ),
          const SizedBox(width: 8),

          // Exportar JSON
          _ToolbarButton(
            icon: Icons.download_rounded,
            label: 'Salvar JSON',
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
        ],
      ),
    );
  }

  List<Widget> _buildPageTabs(
    BuildContext context,
    WidgetRef ref,
    dynamic project,
    SelectionState selection,
  ) {
    return project.pages.map<Widget>((page) {
      final isActive = page.id == selection.activePageId;
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: GestureDetector(
          onTap: () =>
              ref.read(selectionProvider.notifier).setActivePage(page.id),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6C63FF).withAlpha(30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF313244),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 12,
                    color: isActive
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF6C7086),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    page.name as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
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
    }).toList();
  }

  void _showAddPageDialog(BuildContext context, ProjectNotifier notifier) {
    final ctrl = TextEditingController(text: 'Nova Página');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text(
          'Nova Página',
          style: TextStyle(color: Color(0xFFCDD6F4)),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Color(0xFFCDD6F4)),
          decoration: const InputDecoration(
            labelText: 'Nome',
            labelStyle: TextStyle(color: Color(0xFF6C7086)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF313244)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6C63FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF6C7086)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                notifier.addPage(ctrl.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1E1E2E),
        child: SizedBox(
          width: 700,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF181825),
                child: Row(
                  children: [
                    const Icon(Icons.code, color: Color(0xFFA6E3A1), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Código Dart Gerado',
                        style: TextStyle(
                          color: Color(0xFFCDD6F4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Color(0xFF6C7086),
                        size: 18,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código copiado.'),
                            backgroundColor: Color(0xFF313244),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF6C7086),
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFFCDD6F4),
                      height: 1.6,
                    ),
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
              Icon(widget.icon, size: 15, color: widget.color),
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

class _ToolbarIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_ToolbarIconButton> createState() => _ToolbarIconButtonState();
}

class _ToolbarIconButtonState extends State<_ToolbarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xFF313244) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, size: 18, color: const Color(0xFF6C7086)),
          ),
        ),
      ),
    );
  }
}
