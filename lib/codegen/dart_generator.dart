/// Gerador de código Dart a partir do ProjectModel.
library;

import '../core/models/project_model.dart';
import '../core/models/widget_model.dart';
import '../core/models/widget_props.dart';

class DartGenerator {
  final ProjectModel project;
  final _buf = StringBuffer();

  DartGenerator(this.project);

  String generate() {
    _buf.clear();
    _writeln("import 'package:flutter/material.dart';");
    _writeln('');
    _writeln('void main() => runApp(const MyApp());');
    _writeln('');
    _writeln('class MyApp extends StatelessWidget {');
    _writeln('  const MyApp({super.key});');
    _writeln('  @override');
    _writeln('  Widget build(BuildContext context) {');
    _writeln('    return MaterialApp(');
    _writeln("      title: '${project.name}',");
    _writeln(
      '      home: const ${_pageClassName(project.pages.first.name)}(),',
    );
    _writeln('    );');
    _writeln('  }');
    _writeln('}');
    _writeln('');

    for (final page in project.pages) {
      final root = project.widgetById(page.rootWidgetId);
      if (root == null) continue;
      _generatePageClass(page.name, root);
    }

    return _buf.toString();
  }

  void _generatePageClass(String pageName, WidgetModel scaffold) {
    final className = _pageClassName(pageName);
    _writeln('class $className extends StatelessWidget {');
    _writeln('  const $className({super.key});');
    _writeln('  @override');
    _writeln('  Widget build(BuildContext context) {');
    _writeln('    return ${_buildWidget(scaffold, 4)};');
    _writeln('  }');
    _writeln('}');
    _writeln('');
  }

  String _buildWidget(WidgetModel w, int indent) {
    final p = w.props;
    final pad = ' ' * indent;
    final children = project.childrenOf(w.id);

    switch (w.type) {
      case WidgetType.scaffold:
        final body = children.isNotEmpty
            ? _buildWidget(children.first, indent + 4)
            : 'const SizedBox()';
        final appBar = p.showAppBar
            ? '''AppBar(
$pad    title: const Text('${p.appBarTitle}'),
$pad    backgroundColor: const Color(${p.appBarColor.toARGB32()}),
$pad  )'''
            : 'null';
        return '''Scaffold(
$pad  appBar: $appBar,
$pad  backgroundColor: const Color(${p.backgroundColor.toARGB32()}),
$pad  body: $body,
$pad)''';

      case WidgetType.column:
        final childrenCode = children
            .map((c) => '${' ' * (indent + 4)}${_buildWidget(c, indent + 4)}')
            .join(',\n');
        return '''Padding(
$pad  padding: const EdgeInsets.fromLTRB(${p.padding.left}, ${p.padding.top}, ${p.padding.right}, ${p.padding.bottom}),
$pad  child: Column(
$pad    mainAxisAlignment: MainAxisAlignment.${p.mainAxisAlignment.name},
$pad    crossAxisAlignment: CrossAxisAlignment.${p.crossAxisAlignment.name},
$pad    children: [
$childrenCode,
$pad    ],
$pad  ),
$pad)''';

      case WidgetType.row:
        final childrenCode = children
            .map((c) => '${' ' * (indent + 4)}${_buildWidget(c, indent + 4)}')
            .join(',\n');
        return '''Padding(
$pad  padding: const EdgeInsets.fromLTRB(${p.padding.left}, ${p.padding.top}, ${p.padding.right}, ${p.padding.bottom}),
$pad  child: Row(
$pad    mainAxisAlignment: MainAxisAlignment.${p.mainAxisAlignment.name},
$pad    crossAxisAlignment: CrossAxisAlignment.${p.crossAxisAlignment.name},
$pad    children: [
$childrenCode,
$pad    ],
$pad  ),
$pad)''';

      case WidgetType.text:
        return '''Text(
$pad  '${p.text}',
$pad  style: const TextStyle(
$pad    fontSize: ${p.fontSize},
$pad    color: Color(${p.textColor.toARGB32()}),
$pad    fontWeight: ${p.fontWeight},
$pad  ),
$pad  textAlign: TextAlign.${p.textAlign.name},
$pad)''';

      case WidgetType.button:
        final nav = p.navigateTo != null
            ? '''() {
$pad    Navigator.push(context, MaterialPageRoute(builder: (_) => const ${_pageClassName(p.navigateTo!)}()));
$pad  }'''
            : '() {}';
        return '''SizedBox(
$pad  width: ${p.width ?? 'null'},
$pad  height: ${p.height ?? 'null'},
$pad  child: ElevatedButton(
$pad    onPressed: $nav,
$pad    style: ElevatedButton.styleFrom(
$pad      backgroundColor: const Color(${p.buttonColor.toARGB32()}),
$pad      foregroundColor: const Color(${p.buttonTextColor.toARGB32()}),
$pad      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${p.borderRadius})),
$pad    ),
$pad    child: Text('${p.buttonLabel}'),
$pad  ),
$pad)''';

      case WidgetType.textField:
        return '''SizedBox(
$pad  width: ${p.width ?? 280},
$pad  child: TextField(
$pad    decoration: const InputDecoration(
$pad      hintText: '${p.hintText}',
$pad      labelText: '${p.labelText}',
$pad      border: OutlineInputBorder(),
$pad    ),
$pad  ),
$pad)''';

      case WidgetType.image:
        return '''ClipRRect(
$pad  borderRadius: BorderRadius.circular(${p.borderRadius}),
$pad  child: Image.network(
$pad    '${p.imageUrl}',
$pad    width: ${p.width ?? 'null'},
$pad    height: ${p.height ?? 'null'},
$pad    fit: BoxFit.${p.imageFit.name},
$pad  ),
$pad)''';

      case WidgetType.icon:
        return '''Icon(
$pad  IconData(${p.iconCodePoint}, fontFamily: 'MaterialIcons'),
$pad  size: ${p.iconSize},
$pad  color: const Color(${p.iconColor.toARGB32()}),
$pad)''';

      case WidgetType.container:
        final child = children.isNotEmpty
            ? _buildWidget(children.first, indent + 4)
            : 'null';
        return '''Container(
$pad  width: ${p.width ?? 'null'},
$pad  height: ${p.height ?? 'null'},
$pad  padding: const EdgeInsets.fromLTRB(${p.padding.left}, ${p.padding.top}, ${p.padding.right}, ${p.padding.bottom}),
$pad  decoration: BoxDecoration(
$pad    color: const Color(${p.backgroundColor.toARGB32()}),
$pad    borderRadius: BorderRadius.circular(${p.borderRadius}),
$pad  ),
$pad  child: $child,
$pad)''';

      case WidgetType.card:
        final child = children.isNotEmpty
            ? _buildWidget(children.first, indent + 4)
            : 'null';
        return '''Card(
$pad  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${p.borderRadius})),
$pad  child: Padding(
$pad    padding: const EdgeInsets.fromLTRB(${p.padding.left}, ${p.padding.top}, ${p.padding.right}, ${p.padding.bottom}),
$pad    child: $child,
$pad  ),
$pad)''';

      default:
        return 'const SizedBox()';
    }
  }

  String _pageClassName(String name) =>
      '${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}Page';

  void _writeln(String line) => _buf.writeln(line);
}
