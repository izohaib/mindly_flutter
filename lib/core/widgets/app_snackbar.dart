import 'package:flutter/material.dart';
import '../router/app_router.dart';
import '../theme/colors.dart';

enum AppSnackbarType { success, error, info }

class AppSnackbar {
  static void show(
       {
        required String message,
        AppSnackbarType type = AppSnackbarType.info,
        Duration duration = const Duration(seconds: 6),
        VoidCallback? onUndo,
      }) {


    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        content: _SnackbarContent(
          message: message,
          type: type,
          duration: duration,
          onUndo: onUndo,
        ),
      ),
    );
  }
}

class _SnackbarContent extends StatefulWidget {
  final String message;
  final AppSnackbarType type;
  final Duration duration;
  final VoidCallback? onUndo;

  const _SnackbarContent({
    required this.message,
    required this.type,
    required this.duration,
    this.onUndo,
  });

  @override
  State<_SnackbarContent> createState() => _SnackbarContentState();
}

class _SnackbarContentState extends State<_SnackbarContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.type) {
      case AppSnackbarType.success:
        return AppColors.primary;
      case AppSnackbarType.error:
        return const Color(0xFFE05252);
      case AppSnackbarType.info:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppSnackbarType.success:
        return Icons.check_circle_outline;
      case AppSnackbarType.error:
        return Icons.error_outline;
      case AppSnackbarType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                Icon(_icon, color: _accentColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.onUndo != null)
                  TextButton(
                    onPressed: () {
                      widget.onUndo!.call();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'UNDO',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: 1 - _controller.value,
                minHeight: 3,
                backgroundColor: AppColors.outline.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
              );
            },
          ),
        ],
      ),
    );
  }
}