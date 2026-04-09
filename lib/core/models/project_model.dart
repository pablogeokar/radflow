/// Modelo raiz do projeto RAD.
library;

import 'dart:convert';
import 'page_model.dart';
import 'widget_model.dart';

class ProjectModel {
  final String name;
  final List<PageModel> pages;

  /// Todos os widgets do projeto, indexados por ID.
  final Map<String, WidgetModel> widgets;

  const ProjectModel({
    required this.name,
    required this.pages,
    required this.widgets,
  });

  PageModel? pageById(String id) {
    try {
      return pages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  WidgetModel? widgetById(String id) => widgets[id];

  List<WidgetModel> childrenOf(String widgetId) {
    final w = widgets[widgetId];
    if (w == null) return [];
    return w.childrenIds
        .map((id) => widgets[id])
        .whereType<WidgetModel>()
        .toList();
  }

  ProjectModel copyWith({
    String? name,
    List<PageModel>? pages,
    Map<String, WidgetModel>? widgets,
  }) => ProjectModel(
    name: name ?? this.name,
    pages: pages ?? this.pages,
    widgets: widgets ?? this.widgets,
  );

  String toJson() => jsonEncode({
    'name': name,
    'pages': pages.map((p) => p.toJson()).toList(),
    'widgets': widgets.map((k, v) => MapEntry(k, v.toJson())),
  });

  factory ProjectModel.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return ProjectModel(
      name: map['name'] as String,
      pages: (map['pages'] as List)
          .map((p) => PageModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      widgets: (map['widgets'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, WidgetModel.fromJson(v as Map<String, dynamic>)),
      ),
    );
  }
}
