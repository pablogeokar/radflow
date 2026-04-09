/// Propriedades tipadas para cada tipo de widget.
library;

import 'package:flutter/material.dart';

// ── Helpers de serialização ───────────────────────────────────────────────

Color colorFromJson(dynamic v) {
  if (v == null) return Colors.transparent;
  return Color(int.parse(v.toString()));
}

int colorToJson(Color c) => c.toARGB32();

TextAlign textAlignFromJson(String? v) {
  return TextAlign.values.firstWhere(
    (e) => e.name == v,
    orElse: () => TextAlign.left,
  );
}

FontWeight fontWeightFromJson(String? v) {
  return FontWeight.values.firstWhere(
    (e) => e.toString() == v,
    orElse: () => FontWeight.normal,
  );
}

MainAxisAlignment mainAxisAlignmentFromJson(String? v) {
  return MainAxisAlignment.values.firstWhere(
    (e) => e.name == v,
    orElse: () => MainAxisAlignment.start,
  );
}

CrossAxisAlignment crossAxisAlignmentFromJson(String? v) {
  return CrossAxisAlignment.values.firstWhere(
    (e) => e.name == v,
    orElse: () => CrossAxisAlignment.start,
  );
}

// ── Tipos de widget suportados ────────────────────────────────────────────

enum WidgetType {
  container,
  text,
  button,
  textField,
  image,
  icon,
  row,
  column,
  stack,
  listView,
  card,
  scaffold,
}

extension WidgetTypeLabel on WidgetType {
  String get label {
    const labels = {
      WidgetType.container: 'Container',
      WidgetType.text: 'Text',
      WidgetType.button: 'Button',
      WidgetType.textField: 'TextField',
      WidgetType.image: 'Image',
      WidgetType.icon: 'Icon',
      WidgetType.row: 'Row',
      WidgetType.column: 'Column',
      WidgetType.stack: 'Stack',
      WidgetType.listView: 'ListView',
      WidgetType.card: 'Card',
      WidgetType.scaffold: 'Scaffold',
    };
    return labels[this] ?? name;
  }

  IconData get icon {
    switch (this) {
      case WidgetType.container:
        return Icons.crop_square;
      case WidgetType.text:
        return Icons.text_fields;
      case WidgetType.button:
        return Icons.smart_button;
      case WidgetType.textField:
        return Icons.input;
      case WidgetType.image:
        return Icons.image;
      case WidgetType.icon:
        return Icons.star;
      case WidgetType.row:
        return Icons.table_rows;
      case WidgetType.column:
        return Icons.view_column;
      case WidgetType.stack:
        return Icons.layers;
      case WidgetType.listView:
        return Icons.list;
      case WidgetType.card:
        return Icons.credit_card;
      case WidgetType.scaffold:
        return Icons.phone_android;
    }
  }

  /// Widgets que podem ter filhos
  bool get isLayout => const {
    WidgetType.container,
    WidgetType.row,
    WidgetType.column,
    WidgetType.stack,
    WidgetType.listView,
    WidgetType.card,
    WidgetType.scaffold,
  }.contains(this);
}

// ── Modelo de propriedades (mapa dinâmico + helpers tipados) ──────────────

class WidgetProps {
  final Map<String, dynamic> _data;

  WidgetProps([Map<String, dynamic>? data]) : _data = data ?? {};

  // Getters genéricos
  T get<T>(String key, T defaultValue) {
    final v = _data[key];
    if (v == null) return defaultValue;
    if (v is T) return v;
    return defaultValue;
  }

  WidgetProps set(String key, dynamic value) {
    final copy = Map<String, dynamic>.from(_data);
    copy[key] = value;
    return WidgetProps(copy);
  }

  WidgetProps remove(String key) {
    final copy = Map<String, dynamic>.from(_data);
    copy.remove(key);
    return WidgetProps(copy);
  }

  // ── Propriedades comuns ───────────────────────────────────────────────

  double? get width => _data['width'] as double?;
  double? get height => _data['height'] as double?;
  Color get backgroundColor =>
      colorFromJson(_data['backgroundColor'] ?? Colors.transparent.toARGB32());
  EdgeInsets get padding {
    final v = _data['padding'];
    if (v == null) return EdgeInsets.zero;
    return EdgeInsets.fromLTRB(
      (v['left'] as num?)?.toDouble() ?? 0,
      (v['top'] as num?)?.toDouble() ?? 0,
      (v['right'] as num?)?.toDouble() ?? 0,
      (v['bottom'] as num?)?.toDouble() ?? 0,
    );
  }

  double get borderRadius => ((_data['borderRadius'] as num?) ?? 0).toDouble();
  Color get borderColor =>
      colorFromJson(_data['borderColor'] ?? Colors.transparent.toARGB32());
  double get borderWidth => ((_data['borderWidth'] as num?) ?? 0).toDouble();

  // ── Text ─────────────────────────────────────────────────────────────
  String get text => _data['text'] as String? ?? 'Text';
  double get fontSize => ((_data['fontSize'] as num?) ?? 14).toDouble();
  Color get textColor =>
      colorFromJson(_data['textColor'] ?? const Color(0xFF1A1A2E).toARGB32());
  FontWeight get fontWeight =>
      fontWeightFromJson(_data['fontWeight'] as String?);
  TextAlign get textAlign => textAlignFromJson(_data['textAlign'] as String?);

  // ── Button ───────────────────────────────────────────────────────────
  String get buttonLabel => _data['buttonLabel'] as String? ?? 'Button';
  Color get buttonColor =>
      colorFromJson(_data['buttonColor'] ?? const Color(0xFF6C63FF).toARGB32());
  Color get buttonTextColor =>
      colorFromJson(_data['buttonTextColor'] ?? Colors.white.toARGB32());
  String? get navigateTo => _data['navigateTo'] as String?;

  // ── Image ────────────────────────────────────────────────────────────
  String get imageUrl =>
      _data['imageUrl'] as String? ?? 'https://picsum.photos/200';
  BoxFit get imageFit {
    final v = _data['imageFit'] as String?;
    return BoxFit.values.firstWhere(
      (e) => e.name == v,
      orElse: () => BoxFit.cover,
    );
  }

  // ── Icon ─────────────────────────────────────────────────────────────
  int get iconCodePoint =>
      (_data['iconCodePoint'] as int?) ?? Icons.star.codePoint;
  double get iconSize => ((_data['iconSize'] as num?) ?? 24).toDouble();
  Color get iconColor =>
      colorFromJson(_data['iconColor'] ?? const Color(0xFF6C63FF).toARGB32());

  // ── Layout (Row/Column) ───────────────────────────────────────────────
  MainAxisAlignment get mainAxisAlignment =>
      mainAxisAlignmentFromJson(_data['mainAxisAlignment'] as String?);
  CrossAxisAlignment get crossAxisAlignment =>
      crossAxisAlignmentFromJson(_data['crossAxisAlignment'] as String?);
  double get spacing => ((_data['spacing'] as num?) ?? 0).toDouble();

  // ── TextField ────────────────────────────────────────────────────────
  String get hintText => _data['hintText'] as String? ?? 'Digite aqui...';
  String get labelText => _data['labelText'] as String? ?? '';

  // ── Scaffold ─────────────────────────────────────────────────────────
  String get appBarTitle => _data['appBarTitle'] as String? ?? 'Página';
  bool get showAppBar => _data['showAppBar'] as bool? ?? true;
  Color get appBarColor =>
      colorFromJson(_data['appBarColor'] ?? const Color(0xFF6C63FF).toARGB32());

  Map<String, dynamic> toJson() => Map.from(_data);

  factory WidgetProps.fromJson(Map<String, dynamic> json) =>
      WidgetProps(Map.from(json));

  /// Retorna props padrão para cada tipo de widget.
  factory WidgetProps.defaultsFor(WidgetType type) {
    switch (type) {
      case WidgetType.text:
        return WidgetProps({
          'text': 'Texto',
          'fontSize': 16.0,
          'textColor': const Color(0xFF1A1A2E).toARGB32(),
          'fontWeight': FontWeight.normal.toString(),
          'textAlign': TextAlign.left.name,
        });
      case WidgetType.button:
        return WidgetProps({
          'buttonLabel': 'Botão',
          'buttonColor': const Color(0xFF6C63FF).toARGB32(),
          'buttonTextColor': Colors.white.toARGB32(),
          'borderRadius': 8.0,
          'width': 160.0,
          'height': 48.0,
        });
      case WidgetType.container:
        return WidgetProps({
          'width': 200.0,
          'height': 120.0,
          'backgroundColor': const Color(0xFFE8E8F0).toARGB32(),
          'borderRadius': 8.0,
          'padding': {'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0},
        });
      case WidgetType.image:
        return WidgetProps({
          'imageUrl': 'https://picsum.photos/300/200',
          'width': 200.0,
          'height': 150.0,
          'borderRadius': 8.0,
          'imageFit': BoxFit.cover.name,
        });
      case WidgetType.icon:
        return WidgetProps({
          'iconCodePoint': Icons.star.codePoint,
          'iconSize': 32.0,
          'iconColor': const Color(0xFF6C63FF).toARGB32(),
        });
      case WidgetType.row:
        return WidgetProps({
          'mainAxisAlignment': MainAxisAlignment.start.name,
          'crossAxisAlignment': CrossAxisAlignment.center.name,
          'spacing': 8.0,
          'padding': {'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0},
        });
      case WidgetType.column:
        return WidgetProps({
          'mainAxisAlignment': MainAxisAlignment.start.name,
          'crossAxisAlignment': CrossAxisAlignment.start.name,
          'spacing': 8.0,
          'padding': {'left': 8.0, 'top': 8.0, 'right': 8.0, 'bottom': 8.0},
        });
      case WidgetType.textField:
        return WidgetProps({
          'hintText': 'Digite aqui...',
          'labelText': 'Campo',
          'width': 240.0,
        });
      case WidgetType.card:
        return WidgetProps({
          'width': 200.0,
          'backgroundColor': Colors.white.toARGB32(),
          'borderRadius': 12.0,
          'padding': {'left': 16.0, 'top': 16.0, 'right': 16.0, 'bottom': 16.0},
        });
      case WidgetType.scaffold:
        return WidgetProps({
          'appBarTitle': 'Página',
          'showAppBar': true,
          'appBarColor': const Color(0xFF6C63FF).toARGB32(),
          'backgroundColor': Colors.white.toARGB32(),
        });
      default:
        return WidgetProps({});
    }
  }
}
