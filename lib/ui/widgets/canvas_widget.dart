/// Renderiza um WidgetModel como Flutter widget real no canvas de preview.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/widget_model.dart';
import '../../core/models/widget_props.dart';
import '../../core/models/project_model.dart';
import '../../core/providers/selection_provider.dart';

class CanvasWidget extends ConsumerWidget {
  final WidgetModel model;
  final ProjectModel project;
  final bool isRoot;

  const CanvasWidget({
    super.key,
    required this.model,
    required this.project,
    this.isRoot = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final isSelected = selection.selectedWidgetId == model.id;

    final rendered = _render(context, ref, model, project);

    // Scaffold não recebe overlay de seleção
    if (model.type == WidgetType.scaffold) return rendered;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(selectionProvider.notifier).selectWidget(model.id),
      child: Stack(
        children: [
          // AbsorbPointer bloqueia interações dos widgets filhos no modo edição,
          // impedindo que botões, textfields, etc. respondam a toques.
          AbsorbPointer(child: rendered),
          if (isSelected)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF6C63FF),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(
                      model.props.borderRadius > 0
                          ? model.props.borderRadius
                          : 4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _render(
    BuildContext context,
    WidgetRef ref,
    WidgetModel w,
    ProjectModel proj,
  ) {
    final p = w.props;
    final children = proj.childrenOf(w.id);

    Widget buildChild(WidgetModel child) =>
        CanvasWidget(key: ValueKey(child.id), model: child, project: proj);

    switch (w.type) {
      // ── Scaffold ────────────────────────────────────────────────────
      case WidgetType.scaffold:
        return Scaffold(
          backgroundColor: p.backgroundColor,
          appBar: p.showAppBar
              ? AppBar(
                  title: Text(
                    p.appBarTitle,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: p.appBarColor,
                  elevation: 0,
                )
              : null,
          body: children.isNotEmpty
              ? buildChild(children.first)
              : const _EmptyDropZone(),
        );

      // ── Column ──────────────────────────────────────────────────────
      case WidgetType.column:
        return Padding(
          padding: p.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: p.mainAxisAlignment,
            crossAxisAlignment: p.crossAxisAlignment,
            children: children.isEmpty
                ? [const _EmptyDropZone()]
                : children
                      .expand(
                        (c) => [
                          buildChild(c),
                          if (c != children.last && p.spacing > 0)
                            SizedBox(height: p.spacing),
                        ],
                      )
                      .toList(),
          ),
        );

      // ── Row ─────────────────────────────────────────────────────────
      case WidgetType.row:
        return Padding(
          padding: p.padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: p.mainAxisAlignment,
            crossAxisAlignment: p.crossAxisAlignment,
            children: children.isEmpty
                ? [const _EmptyDropZone()]
                : children
                      .expand(
                        (c) => [
                          buildChild(c),
                          if (c != children.last && p.spacing > 0)
                            SizedBox(width: p.spacing),
                        ],
                      )
                      .toList(),
          ),
        );

      // ── Stack ───────────────────────────────────────────────────────
      case WidgetType.stack:
        return Stack(
          children: children.isEmpty
              ? [const _EmptyDropZone()]
              : children.map(buildChild).toList(),
        );

      // ── Container ───────────────────────────────────────────────────
      case WidgetType.container:
        return Container(
          width: p.width,
          height: p.height,
          padding: p.padding,
          decoration: BoxDecoration(
            color: p.backgroundColor,
            borderRadius: BorderRadius.circular(p.borderRadius),
            border: p.borderWidth > 0
                ? Border.all(color: p.borderColor, width: p.borderWidth)
                : null,
          ),
          child: children.isNotEmpty ? buildChild(children.first) : null,
        );

      // ── Card ────────────────────────────────────────────────────────
      case WidgetType.card:
        return SizedBox(
          width: p.width,
          child: Card(
            color: p.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(p.borderRadius),
            ),
            elevation: 2,
            child: Padding(
              padding: p.padding,
              child: children.isNotEmpty
                  ? buildChild(children.first)
                  : const _EmptyDropZone(),
            ),
          ),
        );

      // ── Text ────────────────────────────────────────────────────────
      case WidgetType.text:
        return Text(
          p.text,
          textAlign: p.textAlign,
          style: TextStyle(
            fontSize: p.fontSize,
            color: p.textColor,
            fontWeight: p.fontWeight,
          ),
        );

      // ── Button ──────────────────────────────────────────────────────
      case WidgetType.button:
        return SizedBox(
          width: p.width,
          height: p.height,
          child: ElevatedButton(
            onPressed: () {
              if (p.navigateTo != null) {
                // Navega para outra página no preview
                final proj2 = project;
                final targetPage = proj2.pageById(p.navigateTo!);
                if (targetPage != null) {
                  final rootW = proj2.widgetById(targetPage.rootWidgetId);
                  if (rootW != null && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CanvasWidget(
                          model: rootW,
                          project: proj2,
                          isRoot: true,
                        ),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: p.buttonColor,
              foregroundColor: p.buttonTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(p.borderRadius),
              ),
            ),
            child: Text(p.buttonLabel),
          ),
        );

      // ── TextField ───────────────────────────────────────────────────
      case WidgetType.textField:
        return SizedBox(
          width: p.width,
          child: TextField(
            decoration: InputDecoration(
              hintText: p.hintText,
              labelText: p.labelText.isNotEmpty ? p.labelText : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        );

      // ── Image ───────────────────────────────────────────────────────
      case WidgetType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(p.borderRadius),
          child: Image.network(
            p.imageUrl,
            width: p.width,
            height: p.height,
            fit: p.imageFit,
            errorBuilder: (_, __, ___) => Container(
              width: p.width,
              height: p.height,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );

      // ── Icon ────────────────────────────────────────────────────────
      case WidgetType.icon:
        return Icon(
          IconData(p.iconCodePoint, fontFamily: 'MaterialIcons'),
          size: p.iconSize,
          color: p.iconColor,
        );

      // ── ListView ────────────────────────────────────────────────────
      case WidgetType.listView:
        return SizedBox(
          height: p.height ?? 200,
          child: ListView(
            padding: p.padding,
            children: children.map(buildChild).toList(),
          ),
        );
    }
  }
}

/// Zona vazia que indica onde soltar widgets.
class _EmptyDropZone extends StatelessWidget {
  const _EmptyDropZone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF6C63FF).withAlpha(80),
          style: BorderStyle.solid,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF6C63FF).withAlpha(15),
      ),
      child: const Center(
        child: Text(
          '+ soltar aqui',
          style: TextStyle(fontSize: 10, color: Color(0xFF6C63FF)),
        ),
      ),
    );
  }
}
