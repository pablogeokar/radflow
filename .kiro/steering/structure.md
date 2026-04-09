# Project Structure

```
lib/
├── main.dart                        # App entry point, MaterialApp + ProviderScope
│
├── core/
│   ├── models/
│   │   ├── project_model.dart       # Root model: name, pages[], widgets map
│   │   ├── page_model.dart          # Page: id, name, rootWidgetId (always Scaffold)
│   │   ├── widget_model.dart        # Widget node: id, type, props, childrenIds, parentId
│   │   └── widget_props.dart        # WidgetProps (dynamic map + typed getters), WidgetType enum
│   │
│   └── providers/
│       ├── project_provider.dart    # ProjectNotifier + projectProvider (StateNotifierProvider)
│       └── selection_provider.dart  # SelectionNotifier + selectionProvider; DevicePreset enum
│
├── codegen/
│   └── dart_generator.dart          # DartGenerator: ProjectModel → Dart source string
│
└── ui/
    ├── screens/
    │   └── studio_screen.dart       # Root screen: toolbar + 3-column layout
    │
    ├── panels/
    │   ├── canvas_panel.dart        # Center: device frame + canvas
    │   ├── component_panel.dart     # Left: widget palette + page list
    │   └── properties_panel.dart    # Right: selected widget property editors
    │
    └── widgets/
        ├── canvas_widget.dart       # Renders the widget tree on the canvas
        └── studio_toolbar.dart      # Top bar: project name, device picker, export
```

## Key Conventions

- **Widget tree is a flat map** — `ProjectModel.widgets` is `Map<String, WidgetModel>`. Parent/child relationships are maintained via `childrenIds` and `parentId` on each node.
- **Every page root is a Scaffold** — `PageModel.rootWidgetId` always points to a `WidgetType.scaffold` widget.
- **Props are a typed dynamic map** — `WidgetProps` wraps `Map<String, dynamic>` and exposes typed getters. Use `props.set(key, value)` to produce a new immutable instance.
- **Colors are stored as ARGB int** — serialize with `color.toARGB32()`, deserialize with `Color(int)`.
- **IDs are UUID v4 strings** — generated via the `uuid` package.
- **All models are immutable** — always use `copyWith` to produce updated instances; never mutate in place.
- **Code comments and UI strings in pt-BR** — follow this convention in all new files.
- **`for` loop bodies must use braces** — `flutter_lints` flags single-statement `for` bodies; always wrap in `{}`.
