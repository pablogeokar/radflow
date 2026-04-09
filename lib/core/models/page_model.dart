/// Modelo de uma página/tela do projeto.
library;

import 'package:uuid/uuid.dart';
import 'widget_model.dart';
import 'widget_props.dart';

const _uuid = Uuid();

class PageModel {
  final String id;
  final String name;
  final String rootWidgetId; // sempre um Scaffold

  const PageModel({
    required this.id,
    required this.name,
    required this.rootWidgetId,
  });

  /// Cria uma nova página com um Scaffold raiz.
  static (PageModel, WidgetModel) create(String name) {
    final scaffold = WidgetModel.create(WidgetType.scaffold);
    final page = PageModel(
      id: _uuid.v4(),
      name: name,
      rootWidgetId: scaffold.id,
    );
    return (page, scaffold);
  }

  PageModel copyWith({String? name}) =>
      PageModel(id: id, name: name ?? this.name, rootWidgetId: rootWidgetId);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'rootWidgetId': rootWidgetId,
  };

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
    id: json['id'] as String,
    name: json['name'] as String,
    rootWidgetId: json['rootWidgetId'] as String,
  );
}
