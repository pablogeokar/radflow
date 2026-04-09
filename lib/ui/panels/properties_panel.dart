/// Painel direito: propriedades do widget selecionado.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/widget_props.dart';
import '../../core/providers/project_provider.dart';
import '../../core/providers/selection_provider.dart';

class PropertiesPanel extends ConsumerWidget {
  const PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final selection = ref.watch(selectionProvider);
    final widgetId = selection.selectedWidgetId;

    if (widgetId == null) {
      return Container(
        width: 260,
        color: const Color(0xFF181825),
        child: const Center(
          child: Text(
            'Selecione um widget\npara editar suas propriedades',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6C7086), fontSize: 12),
          ),
        ),
      );
    }

    final widget = project.widgetById(widgetId);
    if (widget == null) return const SizedBox(width: 260);

    return Container(
      width: 260,
      color: const Color(0xFF181825),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1E1E2E),
            child: Row(
              children: [
                Icon(
                  widget.type.icon,
                  size: 16,
                  color: const Color(0xFF6C63FF),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.type.label,
                  style: const TextStyle(
                    color: Color(0xFFCDD6F4),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Propriedades
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: _buildProps(
                context,
                ref,
                widget.type,
                widget.props,
                widgetId,
                project,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProps(
    BuildContext context,
    WidgetRef ref,
    WidgetType type,
    WidgetProps props,
    String widgetId,
    dynamic project,
  ) {
    void update(WidgetProps newProps) =>
        ref.read(projectProvider.notifier).updateProps(widgetId, newProps);

    final widgets = <Widget>[];

    // ── Propriedades comuns de tamanho ────────────────────────────────
    if (type != WidgetType.scaffold &&
        type != WidgetType.column &&
        type != WidgetType.row) {
      widgets.add(
        _Section('Tamanho', [
          _NumberField(
            label: 'Largura',
            value: props.width,
            hint: 'auto',
            onChanged: (v) => update(props.set('width', v)),
          ),
          _NumberField(
            label: 'Altura',
            value: props.height,
            hint: 'auto',
            onChanged: (v) => update(props.set('height', v)),
          ),
        ]),
      );
    }

    // ── Por tipo ──────────────────────────────────────────────────────
    switch (type) {
      case WidgetType.text:
        widgets.addAll([
          _Section('Texto', [
            _TextField2(
              label: 'Conteúdo',
              value: props.text,
              onChanged: (v) => update(props.set('text', v)),
            ),
            _NumberField(
              label: 'Tamanho da fonte',
              value: props.fontSize,
              onChanged: (v) => update(props.set('fontSize', v)),
            ),
            _ColorField(
              label: 'Cor do texto',
              value: props.textColor,
              onChanged: (v) => update(props.set('textColor', v.toARGB32())),
            ),
            _DropdownField(
              label: 'Alinhamento',
              value: props.textAlign.name,
              options: TextAlign.values.map((e) => e.name).toList(),
              onChanged: (v) => update(props.set('textAlign', v)),
            ),
            _DropdownField(
              label: 'Peso',
              value: props.fontWeight.toString(),
              options: [
                FontWeight.normal.toString(),
                FontWeight.bold.toString(),
                FontWeight.w300.toString(),
                FontWeight.w500.toString(),
                FontWeight.w600.toString(),
              ],
              onChanged: (v) => update(props.set('fontWeight', v)),
            ),
          ]),
        ]);

      case WidgetType.button:
        widgets.addAll([
          _Section('Botão', [
            _TextField2(
              label: 'Texto',
              value: props.buttonLabel,
              onChanged: (v) => update(props.set('buttonLabel', v)),
            ),
            _ColorField(
              label: 'Cor do botão',
              value: props.buttonColor,
              onChanged: (v) => update(props.set('buttonColor', v.toARGB32())),
            ),
            _ColorField(
              label: 'Cor do texto',
              value: props.buttonTextColor,
              onChanged: (v) =>
                  update(props.set('buttonTextColor', v.toARGB32())),
            ),
            _NumberField(
              label: 'Borda arredondada',
              value: props.borderRadius,
              onChanged: (v) => update(props.set('borderRadius', v)),
            ),
            _DropdownField(
              label: 'Navegar para',
              value: props.navigateTo ?? '',
              options: ['', ...project.pages.map((p) => p.id as String)],
              optionLabels: {
                '': '(nenhuma)',
                for (final p in project.pages) p.id as String: p.name as String,
              },
              onChanged: (v) => update(
                v.isEmpty
                    ? props.remove('navigateTo')
                    : props.set('navigateTo', v),
              ),
            ),
          ]),
        ]);

      case WidgetType.container:
      case WidgetType.card:
        widgets.addAll([
          _Section('Aparência', [
            _ColorField(
              label: 'Cor de fundo',
              value: props.backgroundColor,
              onChanged: (v) =>
                  update(props.set('backgroundColor', v.toARGB32())),
            ),
            _NumberField(
              label: 'Borda arredondada',
              value: props.borderRadius,
              onChanged: (v) => update(props.set('borderRadius', v)),
            ),
          ]),
          _Section('Padding', [
            _PaddingField(
              value: props.padding,
              onChanged: (v) => update(
                props.set('padding', {
                  'left': v.left,
                  'top': v.top,
                  'right': v.right,
                  'bottom': v.bottom,
                }),
              ),
            ),
          ]),
        ]);

      case WidgetType.image:
        widgets.addAll([
          _Section('Imagem', [
            _TextField2(
              label: 'URL',
              value: props.imageUrl,
              onChanged: (v) => update(props.set('imageUrl', v)),
            ),
            _NumberField(
              label: 'Borda arredondada',
              value: props.borderRadius,
              onChanged: (v) => update(props.set('borderRadius', v)),
            ),
            _DropdownField(
              label: 'Ajuste',
              value: props.imageFit.name,
              options: BoxFit.values.map((e) => e.name).toList(),
              onChanged: (v) => update(props.set('imageFit', v)),
            ),
          ]),
        ]);

      case WidgetType.icon:
        widgets.addAll([
          _Section('Ícone', [
            _NumberField(
              label: 'Tamanho',
              value: props.iconSize,
              onChanged: (v) => update(props.set('iconSize', v)),
            ),
            _ColorField(
              label: 'Cor',
              value: props.iconColor,
              onChanged: (v) => update(props.set('iconColor', v.toARGB32())),
            ),
          ]),
        ]);

      case WidgetType.column:
      case WidgetType.row:
        widgets.addAll([
          _Section('Layout', [
            _DropdownField(
              label: 'Eixo principal',
              value: props.mainAxisAlignment.name,
              options: MainAxisAlignment.values.map((e) => e.name).toList(),
              onChanged: (v) => update(props.set('mainAxisAlignment', v)),
            ),
            _DropdownField(
              label: 'Eixo cruzado',
              value: props.crossAxisAlignment.name,
              options: CrossAxisAlignment.values.map((e) => e.name).toList(),
              onChanged: (v) => update(props.set('crossAxisAlignment', v)),
            ),
            _NumberField(
              label: 'Espaçamento',
              value: props.spacing,
              onChanged: (v) => update(props.set('spacing', v)),
            ),
          ]),
          _Section('Padding', [
            _PaddingField(
              value: props.padding,
              onChanged: (v) => update(
                props.set('padding', {
                  'left': v.left,
                  'top': v.top,
                  'right': v.right,
                  'bottom': v.bottom,
                }),
              ),
            ),
          ]),
        ]);

      case WidgetType.textField:
        widgets.addAll([
          _Section('Campo de texto', [
            _TextField2(
              label: 'Label',
              value: props.labelText,
              onChanged: (v) => update(props.set('labelText', v)),
            ),
            _TextField2(
              label: 'Placeholder',
              value: props.hintText,
              onChanged: (v) => update(props.set('hintText', v)),
            ),
          ]),
        ]);

      case WidgetType.scaffold:
        widgets.addAll([
          _Section('App Bar', [
            _SwitchField(
              label: 'Mostrar App Bar',
              value: props.showAppBar,
              onChanged: (v) => update(props.set('showAppBar', v)),
            ),
            _TextField2(
              label: 'Título',
              value: props.appBarTitle,
              onChanged: (v) => update(props.set('appBarTitle', v)),
            ),
            _ColorField(
              label: 'Cor da App Bar',
              value: props.appBarColor,
              onChanged: (v) => update(props.set('appBarColor', v.toARGB32())),
            ),
          ]),
          _Section('Fundo', [
            _ColorField(
              label: 'Cor de fundo',
              value: props.backgroundColor,
              onChanged: (v) =>
                  update(props.set('backgroundColor', v.toARGB32())),
            ),
          ]),
        ]);

      default:
        break;
    }

    return widgets;
  }
}

// ── Componentes de formulário ─────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF6C7086),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 4),
      ],
    );
  }
}

class _TextField2 extends StatefulWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;
  const _TextField2({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TextField2> createState() => _TextField2State();
}

class _TextField2State extends State<_TextField2> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextField2 old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _ctrl.text != widget.value) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _ctrl,
            onSubmitted: widget.onChanged,
            onTapOutside: (_) => widget.onChanged(_ctrl.text),
            style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 12),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF313244)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF313244)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final String label;
  final double? value;
  final String hint;
  final void Function(double?) onChanged;
  const _NumberField({
    required this.label,
    required this.value,
    this.hint = '',
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value != null ? widget.value.toString() : '',
    );
  }

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    final newText = widget.value != null ? widget.value.toString() : '';
    if (_ctrl.text != newText) _ctrl.text = newText;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_ctrl.text);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onSubmitted: (_) => _submit(),
              onTapOutside: (_) => _submit(),
              style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 12),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF45475A),
                  fontSize: 11,
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF313244)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF313244)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  final String label;
  final Color value;
  final void Function(Color) onChanged;
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  static const _presets = [
    Colors.white,
    Colors.black87,
    Color(0xFF6C63FF),
    Color(0xFF4CAF50),
    Color(0xFFF44336),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Colors.transparent,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presets.map((c) {
              final isSelected = value.toARGB32() == c.toARGB32();
              return GestureDetector(
                onTap: () => onChanged(c),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: c == Colors.transparent ? null : c,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF313244),
                        width: isSelected ? 2 : 1,
                      ),
                      image: c == Colors.transparent
                          ? const DecorationImage(
                              image: NetworkImage(
                                'https://www.transparenttextures.com/patterns/checkered-pattern.png',
                              ),
                              repeat: ImageRepeat.repeat,
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final Map<String, String>? optionLabels;
  final void Function(String) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.optionLabels,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value) ? value : options.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
            ),
          ),
          SizedBox(
            width: 120,
            child: DropdownButtonFormField<String>(
              value: safeValue,
              isDense: true,
              dropdownColor: const Color(0xFF1E1E2E),
              style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 11),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF313244)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF313244)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
              ),
              items: options
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        optionLabels?[o] ?? o,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6C63FF),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _PaddingField extends StatelessWidget {
  final EdgeInsets value;
  final void Function(EdgeInsets) onChanged;
  const _PaddingField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaddingRow(
          'Top',
          value.top,
          (v) => onChanged(value.copyWith(top: v ?? 0)),
        ),
        _PaddingRow(
          'Bottom',
          value.bottom,
          (v) => onChanged(value.copyWith(bottom: v ?? 0)),
        ),
        _PaddingRow(
          'Left',
          value.left,
          (v) => onChanged(value.copyWith(left: v ?? 0)),
        ),
        _PaddingRow(
          'Right',
          value.right,
          (v) => onChanged(value.copyWith(right: v ?? 0)),
        ),
      ],
    );
  }
}

class _PaddingRow extends StatefulWidget {
  final String label;
  final double value;
  final void Function(double?) onChanged;
  const _PaddingRow(this.label, this.value, this.onChanged);

  @override
  State<_PaddingRow> createState() => _PaddingRowState();
}

class _PaddingRowState extends State<_PaddingRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_PaddingRow old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              widget.label,
              style: const TextStyle(color: Color(0xFF6C7086), fontSize: 11),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onSubmitted: (v) => widget.onChanged(double.tryParse(v)),
              onTapOutside: (_) =>
                  widget.onChanged(double.tryParse(_ctrl.text)),
              style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 12),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF313244)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF313244)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
