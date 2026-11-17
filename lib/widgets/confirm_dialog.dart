import 'package:flutter/material.dart';

/// Hộp thoại xác nhận trước khi xóa/đăng xuất.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Xóa',
  String cancelLabel = 'Hủy',
  IconData icon = Icons.warning_amber_rounded,
  bool destructive = true,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: Icon(
          icon,
          color: destructive ? scheme.error : scheme.primary,
          size: 30,
        ),
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? scheme.error : scheme.primary,
              foregroundColor: destructive ? scheme.onError : scheme.onPrimary,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
