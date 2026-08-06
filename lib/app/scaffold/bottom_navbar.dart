import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:mindly/core/theme/colors.dart';

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem({required this.icon, required this.selectedIcon, required this.label});
}

class BottomNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Feed'),
    _NavItem(icon: Icons.folder_outlined, selectedIcon: Icons.folder_rounded, label: 'Shelves'),
    _NavItem(icon: Icons.search_outlined, selectedIcon: Icons.search_rounded, label: 'Sift'),
  ];

  late final List<int> _spinTicks = List.filled(_items.length, 0);

  void _handleTap(int index) {
    if (widget.currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _spinTicks[index]++);
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = widget.currentIndex;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.background.withValues(alpha: 0.35),
              blurRadius: 100,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.75),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tabWidth = constraints.maxWidth / _items.length;
                  return Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                        left: tabWidth * selectedIndex + tabWidth * 0.12,
                        top: 8,
                        width: tabWidth * 0.76,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primaryDeep,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(_items.length, (index) {
                          final item = _items[index];
                          final isSelected = index == selectedIndex;
                          return Expanded(
                            child: InkWell(
                              onTap: () => _handleTap(index),
                              customBorder: const StadiumBorder(),
                              child: SizedBox(
                                height: 68,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      key: ValueKey(_spinTicks[index]),
                                      tween: Tween(begin: 0, end: isSelected ? 1 : 0),
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 6.28319,
                                          child: Transform.scale(
                                            scale: 1 + (0.18 * (isSelected ? value : 0)),
                                            child: Icon(
                                              isSelected ? item.selectedIcon : item.icon,
                                              color: isSelected
                                                  ? AppColors.onPrimary
                                                  : AppColors.onPrimary.withOpacity(0.7),
                                              size: 22,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // AnimatedSize(
                                    //   duration: const Duration(milliseconds: 280),
                                    //   curve: Curves.easeOutCubic,
                                    //   child: isSelected
                                    //       ? Padding(
                                    //     padding: const EdgeInsets.only(left: 6),
                                    //     child: Text(
                                    //       item.label,
                                    //       style: theme.textTheme.labelMedium?.copyWith(
                                    //         color: theme.colorScheme.onPrimary,
                                    //         fontWeight: FontWeight.w600,
                                    //       ),
                                    //     ),
                                    //   )
                                    //       : const SizedBox.shrink(),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}