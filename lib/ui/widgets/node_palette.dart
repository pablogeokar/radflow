/// Paleta de nós disponíveis para adicionar ao grafo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/node_model.dart';
import '../../core/models/pin_model.dart';
import '../../core/providers/graph_provider.dart';

const _uuid = Uuid();

/// Definição de um template de nó na paleta.
class _NodeTemplate {
  final String title;
  final NodeCategory category;
  final List<PinModel> Function(String nodeId) inputs;
  final List<PinModel> Function(String nodeId) outputs;
  final Map<String, dynamic> Function(Map<String, dynamic>)? execute;

  const _NodeTemplate({
    required this.title,
    required this.category,
    required this.inputs,
    required this.outputs,
    this.execute,
  });
}

final _templates = <_NodeTemplate>[
  _NodeTemplate(
    title: 'OnButtonClicked',
    category: NodeCategory.event,
    inputs: (_) => [],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
  ),
  _NodeTemplate(
    title: 'OnStart',
    category: NodeCategory.event,
    inputs: (_) => [],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
  ),
  _NodeTemplate(
    title: 'Print String',
    category: NodeCategory.action,
    inputs: (id) => [
      PinModel(
        id: '${id}_in_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.input,
      ),
      PinModel(
        id: '${id}_in_str',
        label: 'Texto',
        type: PinType.string,
        direction: PinDirection.input,
      ),
    ],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
    execute: (inputs) {
      // ignore: avoid_print
      print('[Print] ${inputs.values.firstOrNull}');
      return {};
    },
  ),
  _NodeTemplate(
    title: 'Branch',
    category: NodeCategory.logic,
    inputs: (id) => [
      PinModel(
        id: '${id}_in_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.input,
      ),
      PinModel(
        id: '${id}_in_cond',
        label: 'Condição',
        type: PinType.bool_,
        direction: PinDirection.input,
      ),
    ],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_true',
        label: 'True',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
      PinModel(
        id: '${id}_out_false',
        label: 'False',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
  ),
  _NodeTemplate(
    title: 'Set Variable',
    category: NodeCategory.variable,
    inputs: (id) => [
      PinModel(
        id: '${id}_in_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.input,
      ),
      PinModel(
        id: '${id}_in_val',
        label: 'Valor',
        type: PinType.string,
        direction: PinDirection.input,
      ),
    ],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
  ),
  _NodeTemplate(
    title: 'Get Variable',
    category: NodeCategory.variable,
    inputs: (_) => [],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_val',
        label: 'Valor',
        type: PinType.string,
        direction: PinDirection.output,
      ),
    ],
    execute: (_) => {'out_val': 'variável'},
  ),
  _NodeTemplate(
    title: 'Add (Int)',
    category: NodeCategory.math,
    inputs: (id) => [
      PinModel(
        id: '${id}_in_a',
        label: 'A',
        type: PinType.int_,
        direction: PinDirection.input,
      ),
      PinModel(
        id: '${id}_in_b',
        label: 'B',
        type: PinType.int_,
        direction: PinDirection.input,
      ),
    ],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_res',
        label: 'Resultado',
        type: PinType.int_,
        direction: PinDirection.output,
      ),
    ],
    execute: (inputs) {
      final a = (inputs.values.elementAtOrNull(0) as int?) ?? 0;
      final b = (inputs.values.elementAtOrNull(1) as int?) ?? 0;
      return {'out_res': a + b};
    },
  ),
  _NodeTemplate(
    title: 'Delay',
    category: NodeCategory.utility,
    inputs: (id) => [
      PinModel(
        id: '${id}_in_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.input,
      ),
      PinModel(
        id: '${id}_in_dur',
        label: 'Duração (s)',
        type: PinType.float,
        direction: PinDirection.input,
      ),
    ],
    outputs: (id) => [
      PinModel(
        id: '${id}_out_exec',
        label: '',
        type: PinType.exec,
        direction: PinDirection.output,
      ),
    ],
  ),
];

/// Painel lateral com a paleta de nós.
class NodePalette extends ConsumerStatefulWidget {
  const NodePalette({super.key});

  @override
  ConsumerState<NodePalette> createState() => _NodePaletteState();
}

class _NodePaletteState extends ConsumerState<NodePalette> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _templates
        .where((t) => t.title.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    // Agrupa por categoria
    final grouped = <NodeCategory, List<_NodeTemplate>>{};
    for (final t in filtered) {
      grouped.putIfAbsent(t.category, () => []).add(t);
    }

    return Container(
      width: 220,
      color: const Color(0xFF181825),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E1E2E),
            child: const Text(
              'Paleta de Nós',
              style: TextStyle(
                color: Color(0xFFCDD6F4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Buscar nó...',
                hintStyle: TextStyle(color: const Color(0xFF6C7086)),
                filled: true,
                fillColor: const Color(0xFF313244),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 16,
                  color: Color(0xFF6C7086),
                ),
              ),
            ),
          ),
          // Lista de nós agrupados
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: grouped.entries.map((entry) {
                return _CategorySection(
                  category: entry.key,
                  templates: entry.value,
                  onAdd: _addNode,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _addNode(_NodeTemplate template) {
    final id = _uuid.v4();
    final node = NodeModel(
      id: id,
      title: template.title,
      category: template.category,
      position: const Offset(400, 300),
      inputs: template.inputs(id),
      outputs: template.outputs(id),
      execute: template.execute,
    );
    ref.read(graphProvider.notifier).addNode(node);
  }
}

class _CategorySection extends StatelessWidget {
  final NodeCategory category;
  final List<_NodeTemplate> templates;
  final void Function(_NodeTemplate) onAdd;

  const _CategorySection({
    required this.category,
    required this.templates,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 4),
          child: Text(
            category.name.toUpperCase(),
            style: TextStyle(
              color: category.headerColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...templates.map((t) => _NodeTile(template: t, onAdd: onAdd)),
      ],
    );
  }
}

class _NodeTile extends StatefulWidget {
  final _NodeTemplate template;
  final void Function(_NodeTemplate) onAdd;

  const _NodeTile({required this.template, required this.onAdd});

  @override
  State<_NodeTile> createState() => _NodeTileState();
}

class _NodeTileState extends State<_NodeTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onAdd(widget.template),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF313244) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.template.category.headerColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.template.title,
                  style: const TextStyle(
                    color: Color(0xFFCDD6F4),
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(
                Icons.add,
                size: 14,
                color: _hovered
                    ? const Color(0xFF89B4FA)
                    : const Color(0xFF45475A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
