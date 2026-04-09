/// Modelo de um widget na árvore visual do projeto.
library;

import 'package:uuid/uuid.dart';
import 'widget_props.dart';

const _uuid = Uuid();

class WidgetModel {
  final String id;
  final WidgetType type;
  final WidgetProps props;
  final List<String> childrenIds; // IDs dos filhos (ordem importa)
  final String? parentId;

  const WidgetModel({
    required this.id,
    required this.type,
    required this.props,
    this.childrenIds = const [],
    this.parentId,
  });

  factory WidgetModel.create(WidgetType type, {String? parentId}) =>
      WidgetModel(
        id: _uuid.v4(),
        type: type,
        props: WidgetProps.defaultsFor(type),
        parentId: parentId,
      );

  WidgetModel copyWith({
    WidgetProps? props,
    List<String>? childrenIds,
    String? parentId,
    bool clearParent = false,
  }) => WidgetModel(
    id: id,
    type: type,
    props: props ?? this.props,
    childrenIds: childrenIds ?? this.childrenIds,
    parentId: clearParent ? null : (parentId ?? this.parentId),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'props': props.toJson(),
    'childrenIds': childrenIds,
    'parentId': parentId,
  };

  factory WidgetModel.fromJson(Map<String, dynamic> json) => WidgetModel(
    id: json['id'] as String,
    type: WidgetType.values.firstWhere((e) => e.name == json['type']),
    props: WidgetProps.fromJson((json['props'] as Map<String, dynamic>?) ?? {}),
    childrenIds:
        (json['childrenIds'] as List?)?.map((e) => e as String).toList() ?? [],
    parentId: json['parentId'] as String?,
  );
}
