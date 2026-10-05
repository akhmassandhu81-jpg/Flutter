import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/providers/home_provider.dart';

/// Reusable bottom navigation bar used by every main shell tab.
/// Reads / writes [bottomNavIndexProvider] — never duplicated per screen.
class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({super.key});

  static const _items = [
    _NavItem(icon: Icons.home_outlined,         activeIcon: Icons.home_rounded,          label: 'Home'),
    _NavItem(icon: Icons.menu_book_outlined,    activeIcon: Icons.menu_book_rounded,     label: 'Subjects'),
    _NavItem(icon: Icons.bar_chart_outlined,    activeIcon: Icons.bar_chart_rounded,     label: 'Progress'),
    _NavItem(icon: Icons.bookmark_border,       activeIcon: Icons.bookmark_rounded,      label: 'Bookmarks'),
    _NavItem(icon: Icons.person_outline_rounded,activeIcon: Icons.person_rounded,        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.borderColor, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item    = _items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: _NavTile(
                  item:     item,
                  selected: selected,
                  onTap: () =>
                      ref.read(bottomNavIndexProvider.notifier).state = i,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Single nav tile ────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool     selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accentBlue : AppColors.textTertiary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              selected ? item.activeIcon : item.icon,
              key: ValueKey(selected),
              color: color,
              size: 23,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
