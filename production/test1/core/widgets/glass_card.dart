import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool hasBorder;
  final bool hasShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.hasBorder = true,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSizes.paddingMD),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? (backgroundColor ?? AppColors.glassWhite) : null,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusLG),
          border: hasBorder
              ? Border.all(color: AppColors.borderLight.withValues(alpha: 0.3), width: 0.8)
              : null,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
