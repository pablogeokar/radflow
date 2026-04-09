/// Provider principal do projeto RAD.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page_model.dart';
import '../models/project_model.dart';
import '../models/widget_model.dart';
import '../models/widget_props.dart';

class ProjectNotifier extends StateNotifier<ProjectModel> {
  ProjectNotifier() : super(_buildDemoProject());

  // ── Widgets ───────────────────────────────────────────────────────────

  void addWidget(WidgetModel widget, String parentId) {
    final parent = state.widgetById(parentId);
    if (parent == null) return;
    final updatedParent = parent.copyWith(
      childrenIds: [...parent.childrenIds, widget.id],
    );
    final updatedWidget = widget.copyWith(parentId: parentId);
    final widgets = Map<String, WidgetModel>.from(state.widgets)
      ..[parentId] = updatedParent
      ..[widget.id] = updatedWidget;
    state = state.copyWith(widgets: widgets);
  }

  void removeWidget(String widgetId) {
    final widget = state.widgetById(widgetId);
    if (widget == null) return;
    final toRemove = <String>{};
    void collect(String id) {
      toRemove.add(id);
      final w = state.widgetById(id);
      if (w != null) {
        for (final c in w.childrenIds) collect(c);
      }
    }

    collect(widgetId);
    final widgets = Map<String, WidgetModel>.from(state.widgets);
    if (widget.parentId != null) {
      final parent = widgets[widget.parentId!];
      if (parent != null) {
        widgets[widget.parentId!] = parent.copyWith(
          childrenIds: parent.childrenIds
              .where((id) => id != widgetId)
              .toList(),
        );
      }
    }
    for (final id in toRemove) widgets.remove(id);
    state = state.copyWith(widgets: widgets);
  }

  void updateProps(String widgetId, WidgetProps props) {
    final widget = state.widgetById(widgetId);
    if (widget == null) return;
    final widgets = Map<String, WidgetModel>.from(state.widgets)
      ..[widgetId] = widget.copyWith(props: props);
    state = state.copyWith(widgets: widgets);
  }

  void reparentWidget(String widgetId, String newParentId) {
    final widget = state.widgetById(widgetId);
    final newParent = state.widgetById(newParentId);
    if (widget == null || newParent == null || widgetId == newParentId) return;
    final widgets = Map<String, WidgetModel>.from(state.widgets);
    if (widget.parentId != null) {
      final old = widgets[widget.parentId!];
      if (old != null) {
        widgets[widget.parentId!] = old.copyWith(
          childrenIds: old.childrenIds.where((id) => id != widgetId).toList(),
        );
      }
    }
    widgets[newParentId] = newParent.copyWith(
      childrenIds: [...newParent.childrenIds, widgetId],
    );
    widgets[widgetId] = widget.copyWith(parentId: newParentId);
    state = state.copyWith(widgets: widgets);
  }

  // ── Páginas ───────────────────────────────────────────────────────────

  void addPage(String name) {
    final (page, scaffold) = PageModel.create(name);
    final widgets = Map<String, WidgetModel>.from(state.widgets)
      ..[scaffold.id] = scaffold;
    state = state.copyWith(pages: [...state.pages, page], widgets: widgets);
  }

  void renamePage(String pageId, String newName) {
    final pages = state.pages
        .map((p) => p.id == pageId ? p.copyWith(name: newName) : p)
        .toList();
    state = state.copyWith(pages: pages);
  }

  void removePage(String pageId) {
    if (state.pages.length <= 1) return;
    final page = state.pageById(pageId);
    if (page == null) return;
    final toRemove = <String>{};
    void collect(String id) {
      toRemove.add(id);
      final w = state.widgetById(id);
      if (w != null) {
        for (final c in w.childrenIds) collect(c);
      }
    }

    collect(page.rootWidgetId);
    final widgets = Map<String, WidgetModel>.from(state.widgets);
    for (final id in toRemove) widgets.remove(id);
    state = state.copyWith(
      pages: state.pages.where((p) => p.id != pageId).toList(),
      widgets: widgets,
    );
  }

  String exportJson() => state.toJson();
  void importJson(String json) => state = ProjectModel.fromJson(json);
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectModel>(
  (ref) => ProjectNotifier(),
);

// ── Projeto de demonstração ───────────────────────────────────────────────

ProjectModel _buildDemoProject() {
  final (homePage, homeScaffold) = PageModel.create('Home');
  final (loginPage, loginScaffold) = PageModel.create('Login');

  // ── Home ─────────────────────────────────────────────────────────────
  final col = WidgetModel.create(WidgetType.column);
  final titleW = WidgetModel(
    id: 'w_title',
    type: WidgetType.text,
    props: WidgetProps({
      'text': 'Bem-vindo ao RadFlow!',
      'fontSize': 24.0,
      'textColor': Colors.black87.toARGB32(),
      'fontWeight': FontWeight.bold.toString(),
    }),
    parentId: col.id,
  );
  final subtitleW = WidgetModel(
    id: 'w_subtitle',
    type: WidgetType.text,
    props: WidgetProps({
      'text': 'Construa apps visualmente.',
      'fontSize': 14.0,
      'textColor': Colors.grey.toARGB32(),
    }),
    parentId: col.id,
  );
  final btnW = WidgetModel(
    id: 'w_btn',
    type: WidgetType.button,
    props: WidgetProps({
      'buttonLabel': 'Ir para Login',
      'buttonColor': const Color(0xFF6C63FF).toARGB32(),
      'buttonTextColor': Colors.white.toARGB32(),
      'borderRadius': 8.0,
      'width': 200.0,
      'height': 48.0,
      'navigateTo': loginPage.id,
    }),
    parentId: col.id,
  );
  final imgW = WidgetModel(
    id: 'w_img',
    type: WidgetType.image,
    props: WidgetProps({
      'imageUrl': 'https://picsum.photos/300/180',
      'width': 300.0,
      'height': 180.0,
      'borderRadius': 12.0,
      'imageFit': 'cover',
    }),
    parentId: col.id,
  );

  final colFinal = col.copyWith(
    childrenIds: [titleW.id, subtitleW.id, btnW.id, imgW.id],
    parentId: homeScaffold.id,
    props: WidgetProps({
      'mainAxisAlignment': 'start',
      'crossAxisAlignment': 'center',
      'spacing': 16.0,
      'padding': {'left': 24.0, 'top': 32.0, 'right': 24.0, 'bottom': 24.0},
    }),
  );
  final homeFinal = homeScaffold.copyWith(
    childrenIds: [colFinal.id],
    props: WidgetProps({
      'appBarTitle': 'Home',
      'showAppBar': true,
      'appBarColor': const Color(0xFF6C63FF).toARGB32(),
      'backgroundColor': Colors.white.toARGB32(),
    }),
  );

  // ── Login ─────────────────────────────────────────────────────────────
  final loginCol = WidgetModel.create(WidgetType.column);
  final loginTitle = WidgetModel(
    id: 'w_login_title',
    type: WidgetType.text,
    props: WidgetProps({
      'text': 'Entrar',
      'fontSize': 28.0,
      'fontWeight': FontWeight.bold.toString(),
      'textColor': Colors.black87.toARGB32(),
    }),
    parentId: loginCol.id,
  );
  final emailF = WidgetModel(
    id: 'w_email',
    type: WidgetType.textField,
    props: WidgetProps({
      'hintText': 'seu@email.com',
      'labelText': 'E-mail',
      'width': 280.0,
    }),
    parentId: loginCol.id,
  );
  final passF = WidgetModel(
    id: 'w_pass',
    type: WidgetType.textField,
    props: WidgetProps({
      'hintText': '••••••••',
      'labelText': 'Senha',
      'width': 280.0,
    }),
    parentId: loginCol.id,
  );
  final loginBtn = WidgetModel(
    id: 'w_login_btn',
    type: WidgetType.button,
    props: WidgetProps({
      'buttonLabel': 'Entrar',
      'buttonColor': const Color(0xFF6C63FF).toARGB32(),
      'buttonTextColor': Colors.white.toARGB32(),
      'borderRadius': 8.0,
      'width': 280.0,
      'height': 48.0,
    }),
    parentId: loginCol.id,
  );

  final loginColFinal = loginCol.copyWith(
    childrenIds: [loginTitle.id, emailF.id, passF.id, loginBtn.id],
    parentId: loginScaffold.id,
    props: WidgetProps({
      'mainAxisAlignment': 'center',
      'crossAxisAlignment': 'center',
      'spacing': 16.0,
      'padding': {'left': 32.0, 'top': 48.0, 'right': 32.0, 'bottom': 32.0},
    }),
  );
  final loginFinal = loginScaffold.copyWith(
    childrenIds: [loginColFinal.id],
    props: WidgetProps({
      'appBarTitle': 'Login',
      'showAppBar': true,
      'appBarColor': const Color(0xFF6C63FF).toARGB32(),
      'backgroundColor': Colors.white.toARGB32(),
    }),
  );

  return ProjectModel(
    name: 'Meu App',
    pages: [homePage, loginPage],
    widgets: {
      homeFinal.id: homeFinal,
      colFinal.id: colFinal,
      titleW.id: titleW,
      subtitleW.id: subtitleW,
      btnW.id: btnW,
      imgW.id: imgW,
      loginFinal.id: loginFinal,
      loginColFinal.id: loginColFinal,
      loginTitle.id: loginTitle,
      emailF.id: emailF,
      passF.id: passF,
      loginBtn.id: loginBtn,
    },
  );
}
