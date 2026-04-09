/// Modelo base de um nó no grafo de lógica visual.
library;

import 'package:flutter/material.dart';
import 'pin_model.dart';

/// Categorias de nós, cada uma com uma cor de cabeçalho.
enum NodeCategory { event, action, logic, variable, math, utility }

extension NodeCategoryColor on NodeCategory {
  Color get headerColor {
    switch (this) {
      case NodeCategory.event:
        return const Color(0xFF7B1FA2); // roxo
      case NodeCategory.action:
        return const Color(0xFF1565C0); // azul
      case NodeCategory.logic:
        return const Color(0xFF2E7D32); // verde
      case NodeCategory.variable:
        return const Color(0xFF00838F); // ciano
      case NodeCategory.math:
        return const Color(0xFFE65100); // laranja
      case NodeCategory.utility:
        return const Color(0xFF4E342E); // marrom
    }
  }
}

/// Representa um nó no editor visual.
class NodeModel {
  final String id;
  final String title;
  final NodeCategory category;
  Offset position;
  final List<PinModel> inputs;
  final List<PinModel> outputs;

  /// Função de execução do nó. Recebe valores dos pinos de entrada
  /// e retorna valores para os pinos de saída.
  final Map<String, dynamic> Function(Map<String, dynamic> inputs)? execute;

  NodeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.position,
    required this.inputs,
    required this.outputs,
    this.execute,
  });

  /// Retorna todos os pinos (entrada + saída).
  List<PinModel> get allPins => [...inputs, ...outputs];

  /// Busca um pino pelo ID.
  PinModel? pinById(String pinId) {
    try {
      return allPins.firstWhere((p) => p.id == pinId);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'position': {'dx': position.dx, 'dy': position.dy},
    'inputs': inputs.map((p) => p.toJson()).toList(),
    'outputs': outputs.map((p) => p.toJson()).toList(),
  };

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
    id: json['id'] as String,
    title: json['title'] as String,
    category: NodeCategory.values.firstWhere((e) => e.name == json['category']),
    position: Offset(
      (json['position']['dx'] as num).toDouble(),
      (json['position']['dy'] as num).toDouble(),
    ),
    inputs: (json['inputs'] as List)
        .map((p) => PinModel.fromJson(p as Map<String, dynamic>))
        .toList(),
    outputs: (json['outputs'] as List)
        .map((p) => PinModel.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  NodeModel copyWith({Offset? position}) => NodeModel(
    id: id,
    title: title,
    category: category,
    position: position ?? this.position,
    inputs: inputs,
    outputs: outputs,
    execute: execute,
  );
}
