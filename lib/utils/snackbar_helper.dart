import 'package:flutter/material.dart';

/// SnackBar 显示辅助类
class SnackbarHelper {
  /// 显示错误提示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: duration,
      ),
    );
  }

  /// 显示信息提示
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  /// 显示带操作的提示
  static void showAction(
    BuildContext context,
    String message,
    String actionLabel,
    VoidCallback onActionPressed, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: actionLabel,
          onPressed: onActionPressed,
          textColor: Colors.white,
        ),
        duration: duration,
      ),
    );
  }
}
