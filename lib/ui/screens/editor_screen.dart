/// Tela principal do editor de blueprints.
library;

import 'package:flutter/material.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/node_palette.dart';
import 'node_editor_canvas.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11111B),
      body: Column(
        children: [
          // Toolbar superior
          const EditorToolbar(),
          // Divisor
          Container(height: 1, color: const Color(0xFF313244)),
          // Corpo: paleta + canvas
          Expanded(
            child: Row(
              children: [
                // Paleta lateral esquerda
                const NodePalette(),
                // Divisor vertical
                Container(width: 1, color: const Color(0xFF313244)),
                // Canvas principal
                const Expanded(child: NodeEditorCanvas()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
