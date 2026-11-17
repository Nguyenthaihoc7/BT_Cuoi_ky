import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'services/history_service.dart';

/// Cung cấp các service dùng chung cho toàn bộ cây widget.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.history,
    required super.child,
  });

  final AuthService auth;
  final HistoryService history;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope không tồn tại trong cây widget.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return auth != oldWidget.auth || history != oldWidget.history;
  }
}
