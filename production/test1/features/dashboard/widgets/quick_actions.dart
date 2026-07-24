import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const _actions = [
    _QAction(label: 'Send', icon: Icons.send_rounded,
        gradient: AppColors.primaryGradient, route: '/transfer/send'),
    _QAction(label: 'Request', icon: Icons.request_page_rounded,
        gradient: AppColors.accentGradient, route: '/transfer/request'),
    _QAction(label: 'Pay Bills', icon: Icons.receipt_rounded,
        gradient: AppColors.goldGradient, route: '/bills'),
    _QAction(label: 'Scan QR', icon: Icons.qr_code_scanner_rounded,
        gradient: AppColors.roseGradient, route: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _actions.map((a) => _QActionButton(action: a)).toList(),
      ),
    );
  }
}

class _QAction {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final String? route;
  const _QAction({required this.label, required this.icon,
      required this.gradient, this.route});
}

class _QActionButton extends StatefulWidget {
  final _QAction action;
  const _QActionButton({super.key, required this.action});

  @override
  State<_QActionButton> createState() => _QActionButtonState();
}

class _QActionButtonState extends State<_QActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) { HapticFeedback.selectionClick(); _ctrl.forward(); },
        onTapUp: (_) {
          _ctrl.reverse();
          if (widget.action.route != null) context.push(widget.action.route!);
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Column(
          children: [
            Container(
              width: 58, height: 58,
              decoration: BoxDecoration(
                gradient: widget.action.gradient,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                boxShadow: [
                  BoxShadow(
                    color: widget.action.gradient.colors.first.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(widget.action.icon, color: Colors.white, size: AppSizes.iconLG),
            ),
            const SizedBox(height: 8),
            Text(widget.action.label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
