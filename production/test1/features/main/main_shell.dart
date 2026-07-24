import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    _NavTab(icon: Icons.home_rounded,           label: 'Home'),
    _NavTab(icon: Icons.receipt_long_rounded,    label: 'History'),
    _NavTab(icon: Icons.credit_card_rounded,     label: 'Cards'),
    _NavTab(icon: Icons.bar_chart_rounded,       label: 'Analytics'),
    _NavTab(icon: Icons.person_rounded,          label: 'Profile'),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _NeoBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        tabs: _tabs,
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}

class _NeoBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavTab> tabs;

  const _NeoBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.bottomNavHeight + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final selected = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: selected
                    ? BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        tab.icon,
                        size: AppSizes.iconLG,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
                      child: Text(tab.label),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
