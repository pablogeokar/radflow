/// Modelo de conexão entre dois pinos.
library;

/// Representa um cabo (wire) conectando um pino de saída a um de entrada.
class ConnectionModel {
  final String id;
  final String fromNodeId;
  final String fromPinId;
  final String toNodeId;
  final String toPinId;

  const ConnectionModel({
    required this.id,
    required this.fromNodeId,
    required this.fromPinId,
    required this.toNodeId,
    required this.toPinId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromNodeId': fromNodeId,
    'fromPinId': fromPinId,
    'toNodeId': toNodeId,
    'toPinId': toPinId,
  };

  factory ConnectionModel.fromJson(Map<String, dynamic> json) =>
      ConnectionModel(
        id: json['id'] as String,
        fromNodeId: json['fromNodeId'] as String,
        fromPinId: json['fromPinId'] as String,
        toNodeId: json['toNodeId'] as String,
        toPinId: json['toPinId'] as String,
      );
}
