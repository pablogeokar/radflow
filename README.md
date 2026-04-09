# RadFlow Studio

IDE low-code visual para criação de interfaces Flutter. Arraste componentes para o canvas, edite propriedades em tempo real e exporte código Dart pronto para rodar.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10%2B-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D4?logo=windows)

---

## Visão Geral

RadFlow Studio é uma aplicação Flutter Desktop (Windows) que funciona como um editor visual de UI. O usuário monta telas arrastando widgets de uma paleta, configura suas propriedades num painel lateral e, ao final, exporta o projeto como código Dart/Flutter funcional ou como JSON para persistência.

```
┌─────────────────────────────────────────────────────────────┐
│  Toolbar  (páginas · exportar Dart · salvar JSON)           │
├──────────────┬──────────────────────────┬───────────────────┤
│  Componentes │                          │   Propriedades    │
│  ──────────  │      Canvas / Preview    │   ─────────────   │
│  Paleta de   │   (device frame + zoom)  │  Editor de props  │
│  widgets     │                          │  do widget        │
│  ──────────  │                          │  selecionado      │
│  Árvore de   │                          │                   │
│  camadas     │                          │                   │
└──────────────┴──────────────────────────┴───────────────────┘
```

---

## Funcionalidades

- **Paleta de componentes** — arraste widgets para o canvas (Layout e Básicos)
- **Canvas interativo** — preview em tempo real com zoom (`InteractiveViewer`)
- **Device presets** — alterne entre iPhone 14 (390×844), iPad (820×1180) e Desktop (1280×800)
- **Árvore de camadas** — visualize e selecione widgets pela hierarquia
- **Painel de propriedades** — edite texto, cores, tamanhos, padding, alinhamento, navegação e mais
- **Navegação entre páginas** — botões podem navegar para outras páginas no preview
- **Exportar Dart** — gera código Flutter completo e copiável
- **Salvar JSON** — serializa o projeto para a área de transferência
- **Projeto demo** — carrega automaticamente um projeto de exemplo (Home + Login)

---

## Widgets Suportados

| Categoria | Widgets |
|-----------|---------|
| Layout    | `Column`, `Row`, `Stack`, `Container`, `Card`, `ListView` |
| Básicos   | `Text`, `Button` (ElevatedButton), `TextField`, `Image`, `Icon` |
| Estrutura | `Scaffold` (raiz de cada página, não arrastável) |

---

## Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.x` com suporte a desktop habilitado
- Dart SDK `^3.10.7`
- Windows 10/11 (64-bit)

Verifique se o desktop está habilitado:

```bash
flutter config --enable-windows-desktop
flutter doctor
```

---

## Instalação e Execução

```bash
# Clone o repositório
git clone <url-do-repo>
cd radflow

# Instale as dependências
flutter pub get

# Execute no Windows
flutter run -d windows
```

---

## Comandos Úteis

```bash
# Rodar no Windows
flutter run -d windows

# Build de produção
flutter build windows

# Gerar código Riverpod (após adicionar anotações @riverpod)
dart run build_runner build --delete-conflicting-outputs

# Modo watch para geração de código
dart run build_runner watch --delete-conflicting-outputs

# Análise estática
flutter analyze

# Testes
flutter test
```

---

## Estrutura do Projeto

```
lib/
├── main.dart                        # Entry point — MaterialApp + ProviderScope
│
├── core/
│   ├── models/
│   │   ├── project_model.dart       # Modelo raiz: nome, páginas, mapa de widgets
│   │   ├── page_model.dart          # Página: id, nome, rootWidgetId (Scaffold)
│   │   ├── widget_model.dart        # Nó da árvore: id, tipo, props, filhos, pai
│   │   └── widget_props.dart        # WidgetProps (mapa dinâmico + getters tipados)
│   │                                # WidgetType enum + extensões label/icon/isLayout
│   └── providers/
│       ├── project_provider.dart    # ProjectNotifier — CRUD de widgets e páginas
│       └── selection_provider.dart  # SelectionNotifier — widget ativo, página ativa,
│                                    # DevicePreset
├── codegen/
│   └── dart_generator.dart          # DartGenerator: ProjectModel → código Dart
│
└── ui/
    ├── screens/
    │   └── studio_screen.dart       # Tela raiz — toolbar + layout 3 colunas
    ├── panels/
    │   ├── canvas_panel.dart        # Canvas central + device frame + drop target
    │   ├── component_panel.dart     # Painel esquerdo: paleta + árvore de camadas
    │   └── properties_panel.dart    # Painel direito: formulário de propriedades
    └── widgets/
        ├── canvas_widget.dart       # Renderiza WidgetModel como widget Flutter real
        └── studio_toolbar.dart      # Toolbar: páginas, exportar Dart, salvar JSON
```

---

## Arquitetura

### Gerenciamento de Estado

O projeto usa **Riverpod** com `StateNotifierProvider`:

| Provider | Tipo | Responsabilidade |
|----------|------|-----------------|
| `projectProvider` | `StateNotifierProvider<ProjectNotifier, ProjectModel>` | Estado completo do projeto (widgets + páginas) |
| `selectionProvider` | `StateNotifierProvider<SelectionNotifier, SelectionState>` | Widget selecionado, página ativa, device preset |

Todo estado é **imutável** — mutações produzem novas instâncias via `copyWith`.

### Modelo de Dados

```
ProjectModel
├── name: String
├── pages: List<PageModel>
│   └── PageModel { id, name, rootWidgetId }
└── widgets: Map<String, WidgetModel>       ← mapa plano indexado por ID
    └── WidgetModel { id, type, props, childrenIds, parentId }
        └── WidgetProps { Map<String, dynamic> + getters tipados }
```

A árvore de widgets é armazenada como **mapa plano** (`Map<String, WidgetModel>`). Relações pai/filho são mantidas por `childrenIds` (lista ordenada) e `parentId` em cada nó. Toda página tem um `Scaffold` como raiz obrigatória.

### Serialização

- **Cores** são armazenadas como `int` ARGB — `color.toARGB32()` / `Color(int)`
- **IDs** são UUID v4 gerados pelo pacote `uuid`
- **Projeto** serializa para JSON via `ProjectModel.toJson()` / `ProjectModel.fromJson()`

### Geração de Código

`DartGenerator` percorre a árvore recursivamente e produz um arquivo `.dart` completo com:
- `main()` + `MyApp`
- Uma `StatelessWidget` por página
- Widgets aninhados com indentação correta
- Navegação entre páginas via `Navigator.push`

---

## Convenções

- Comentários e strings de UI em **português brasileiro (pt-BR)**
- Todos os modelos são imutáveis — use `copyWith` para atualizar
- Corpos de `for` sempre com chaves `{}` (exigido pelo `flutter_lints`)
- Widgets privados de UI prefixados com `_` (ex: `_DeviceBar`, `_LayerNode`)

---

## Dependências

| Pacote | Versão | Uso |
|--------|--------|-----|
| `flutter_riverpod` | `^2.6.1` | Gerenciamento de estado |
| `riverpod_annotation` | `^2.6.1` | Anotações para code-gen |
| `uuid` | `^4.5.1` | Geração de IDs únicos |
| `collection` | `^1.19.1` | Utilitários de coleção |
| `riverpod_generator` *(dev)* | `^2.6.1` | Geração de providers |
| `build_runner` *(dev)* | `^2.4.13` | Runner de code-gen |
| `flutter_lints` *(dev)* | `^6.0.0` | Regras de lint |
