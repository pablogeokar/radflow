/// Modelo de pino de conexão entre nós.
library;

import 'package:flutter/material.dart';

/// Tipos de dados suportados pelos pinos.
enum PinType { exec, string, int_, bool_, object, float }

/// Direção do pino: entrada ou saída.
enum PinDirection { input, output }

/// Representa um pino de conexão em um nó.
class PinModel {
  final String id;
  final String label;
  final PinType type;
  final PinDirection direction;
  bool isConnected;

  PinModel({
    required this.id,
    required this.label,
    required this.type,
    required this.direction,
    this.isConnected = false,
  });

  /// Cor visual associada ao tipo do pino.
  Color get color {
    switch (type) {
      case PinType.exec:
        return const Color(0xFFFFFFFF);
      case PinType.string:
        return const Color(0xFFFF69B4);
      case PinType.int_:
        return const Color(0xFF4FC3F7);
      case PinType.bool_:
        return const Color(0xFFEF5350);
      case PinType.object:
        return const Color(0xFF66BB6A);
      case PinType.float:
        return const Color(0xFFFFCA28);
    }
  }

  /// Verifica se este pino é compatível para conexão com [other].
  bool isCompatibleWith(PinModel other) {
    if (direction == other.direction) return false;
    if (type == PinType.exec) return other.type == PinType.exec;
    if (type == PinType.exec || other.type == PinType.exec) return false;
    return type == other.type;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type.name,
    'direction': direction.name,
    'isConnected': isConnected,
  };

  factory PinModel.fromJson(Map<String, dynamic> json) => PinModel(
    id: json['id'] as String,
    label: json['label'] as String,
    type: PinType.values.firstWhere((e) => e.name == json['type']),
    direction: PinDirection.values.firstWhere(
      (e) => e.name == json['direction'],
    ),
    isConnected: json['isConnected'] as bool? ?? false,
  );

  PinModel copyWith({bool? isConnected}) => PinModel(
    id: id,
    label: label,
    type: type,
    direction: direction,
    isConnected: isConnected ?? this.isConnected,
  );
}
