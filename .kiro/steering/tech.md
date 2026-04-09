# Tech Stack

## Framework & Language
- **Flutter** (desktop, targeting Windows) — Dart SDK `^3.10.7`
- **flutter_riverpod** `^2.6.1` — state management
- **riverpod_annotation** + **riverpod_generator** — code-gen for providers
- **uuid** `^4.5.1` — widget/page ID generation
- **collection** `^1.19.1` — utility collections

## Dev Dependencies
- **build_runner** `^2.4.13` — runs code generation
- **flutter_lints** `^6.0.0` — lint rules (`analysis_options.yaml`)

## State Management Pattern
- `StateNotifierProvider` for mutable state (`ProjectNotifier`, `SelectionNotifier`)
- All state is immutable; mutations return new instances via `copyWith`
- Providers are consumed with `ref.watch` / `ref.read` in `ConsumerWidget`

## Common Commands

```bash
# Run on Windows desktop
flutter run -d windows

# Generate Riverpod provider code (after adding @riverpod annotations)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Analyze / lint
flutter analyze

# Run tests
flutter test
```
