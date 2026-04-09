/// Tela principal do RadFlow Studio.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/selection_provider.dart';
import '../panels/canvas_panel.dart';
import '../panels/component_panel.dart';
import '../panels/properties_panel.dart';
import '../widgets/studio_toolbar.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializa a seleção com a primeira página do projeto
    final project = ref.watch(projectProvider);
    final selection = ref.watch(selectionProvider);

    // Se o activePageId ainda é o placeholder, inicializa com a primeira página
    if (selection.activePageId == '__init__' && project.pages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectionProvider.notifier)
            .setActivePage(project.pages.first.id);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF11111B),
      body: Column(
        children: [
          // Toolbar superior
          const StudioToolbar(),
          // Divisor
          Container(height: 1, color: const Color(0xFF313244)),
          // Layout de 3 colunas
          Expanded(
            child: Row(
              children: [
                // Painel esquerdo: componentes + árvore
                const ComponentPanel(),
                Container(width: 1, color: const Color(0xFF313244)),
                // Canvas central
                const Expanded(child: CanvasPanel()),
                Container(width: 1, color: const Color(0xFF313244)),
                // Painel direito: propriedades
                const PropertiesPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
