/// Painel esquerdo: componentes arrastáveis + árvore de widgets.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/widget_props.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/selection_provider.dart';

class ComponentPanel extends ConsumerStatefulWidget {
  const ComponentPanel({super.key});

  @override
  ConsumerState<ComponentPanel> createState() => _ComponentPanelState();
}

class _ComponentPanelState extends ConsumerState<ComponentPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF181825),
      child: Column(
        children: [
          // Tabs
          Container(
            color: const Color(0xFF1E1E2E),
            child: TabBar(
              controller: _tabs,
              labelColor: const Color(0xFF6C63FF),
              unselectedLabelColor: const Color(0xFF6C7086),
              indicatorColor: const Color(0xFF6C63FF),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Componentes'),
                Tab(text: 'Árvore'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [_ComponentsTab(), _LayersTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aba de componentes ────────────────────────────────────────────────────

const _componentGroups = {
  'Layout': [
    WidgetType.column,
    WidgetType.row,
    WidgetType.stack,
    WidgetType.container,
    WidgetType.card,
    WidgetType.listView,
  ],
  'Básicos': [
    WidgetType.text,
    WidgetType.button,
    WidgetType.textField,
    WidgetType.image,
    WidgetType.icon,
  ],
};

class _ComponentsTab extends StatelessWidget {
  const _ComponentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: _componentGroups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6C7086),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 2.2,
              children: entry.value
                  .map((type) => _DraggableComponent(type: type))
                  .toList(),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _DraggableComponent extends StatefulWidget {
  final WidgetType type;
  const _DraggableComponent({required this.type});

  @override
  State<_DraggableComponent> createState() => _DraggableComponentState();
}

class _DraggableComponentState extends State<_DraggableComponent> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Draggable<WidgetType>(
      data: widget.type,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withAlpha(100),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.type.icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.type.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _ComponentTile(type: widget.type, hovered: false),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.grab,
        child: _ComponentTile(type: widget.type, hovered: _hovered),
      ),
    );
  }
}

class _ComponentTile extends StatelessWidget {
  final WidgetType type;
  final bool hovered;
  const _ComponentTile({required this.type, required this.hovered});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: hovered
            ? const Color(0xFF6C63FF).withAlpha(30)
            : const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hovered ? const Color(0xFF6C63FF) : const Color(0xFF313244),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type.icon,
            size: 18,
            color: hovered ? const Color(0xFF6C63FF) : const Color(0xFF6C7086),
          ),
          const SizedBox(height: 4),
          Text(
            type.label,
            style: TextStyle(
              fontSize: 10,
              color: hovered
                  ? const Color(0xFF6C63FF)
                  : const Color(0xFF6C7086),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aba de árvore de widgets ──────────────────────────────────────────────

class _LayersTab extends ConsumerWidget {
  const _LayersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final selection = ref.watch(selectionProvider);
    final page = project.pageById(selection.activePageId);
    if (page == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _LayerNode(widgetId: page.rootWidgetId, project: project, depth: 0),
      ],
    );
  }
}

class _LayerNode extends ConsumerWidget {
  final String widgetId;
  final dynamic project;
  final int depth;

  const _LayerNode({
    super.key,
    required this.widgetId,
    required this.project,
    required this.depth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widget = project.widgetById(widgetId);
    if (widget == null) return const SizedBox();

    final selection = ref.watch(selectionProvider);
    final isSelected = selection.selectedWidgetId == widgetId;
    final children = project.childrenOf(widgetId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () =>
              ref.read(selectionProvider.notifier).selectWidget(widgetId),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: EdgeInsets.only(left: depth * 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF).withAlpha(30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.type.icon,
                    size: 13,
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF6C7086),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.type.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFFCDD6F4),
                      ),
                    ),
                  ),
                  if (widget.type != WidgetType.scaffold)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Para a propagação para o GestureDetector pai (seleção)
                        ref
                            .read(projectProvider.notifier)
                            .removeWidget(widgetId);
                        ref.read(selectionProvider.notifier).selectWidget(null);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: const Color(0xFF6C7086).withAlpha(180),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ...children.map(
          (c) => _LayerNode(
            key: ValueKey(c.id),
            widgetId: c.id,
            project: project,
            depth: depth + 1,
          ),
        ),
      ],
    );
  }
}
