import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final Color? iconColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    if (!canPop && onPressed == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Geri',
      icon: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.violet.withValues(alpha: 0.18), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppTheme.violet.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_rounded,
            color: iconColor ?? AppTheme.textPrimary,
            size: 20,
          ),
        ),
      ),
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}
