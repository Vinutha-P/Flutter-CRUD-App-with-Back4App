import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final style = _styleFor(type);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: style.backgroundColor.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(style.icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _ToastStyle _styleFor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastStyle(
          backgroundColor: Color(0xFF1E9E61),
          icon: Icons.check_circle_rounded,
        );
      case ToastType.error:
        return const _ToastStyle(
          backgroundColor: Color(0xFFE5484D),
          icon: Icons.error_rounded,
        );
      case ToastType.info:
        return const _ToastStyle(
          backgroundColor: Color(0xFF4E66F8),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _ToastStyle {
  const _ToastStyle({
    required this.backgroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final IconData icon;
}
