/// Provider de seleção: widget e página ativos.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final String? selectedWidgetId;
  final String activePageId;
  final DevicePreset devicePreset;

  const SelectionState({
    this.selectedWidgetId,
    required this.activePageId,
    this.devicePreset = DevicePreset.phone,
  });

  SelectionState copyWith({
    String? selectedWidgetId,
    String? activePageId,
    DevicePreset? devicePreset,
    bool clearWidget = false,
  }) => SelectionState(
    selectedWidgetId: clearWidget
        ? null
        : (selectedWidgetId ?? this.selectedWidgetId),
    activePageId: activePageId ?? this.activePageId,
    devicePreset: devicePreset ?? this.devicePreset,
  );
}

enum DevicePreset {
  phone(390, 844, 'iPhone 14'),
  tablet(820, 1180, 'iPad'),
  desktop(1280, 800, 'Desktop');

  final double width;
  final double height;
  final String label;

  const DevicePreset(this.width, this.height, this.label);
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier(String initialPageId)
    : super(SelectionState(activePageId: initialPageId));

  void selectWidget(String? id) =>
      state = state.copyWith(selectedWidgetId: id, clearWidget: id == null);

  void setActivePage(String pageId) =>
      state = state.copyWith(activePageId: pageId, clearWidget: true);

  void setDevice(DevicePreset preset) =>
      state = state.copyWith(devicePreset: preset);
}

final selectionProvider =
    StateNotifierProvider<SelectionNotifier, SelectionState>((ref) {
      // Inicializa com a primeira página do projeto
      // O ID real é injetado na tela principal
      return SelectionNotifier('__init__');
    });
