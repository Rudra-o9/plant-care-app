import 'package:flutter/material.dart';

/// Modern custom bottom navigation dock with floating Identify action and responsive item layout.
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withAlpha(28),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(scheme, 0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(scheme, 1, Icons.grass_rounded, Icons.grass_outlined, 'My Plants'),

              // Prominent Center Identify Button
              _buildCenterIdentifyButton(scheme),

              _buildNavItem(scheme, 3, Icons.notifications_rounded, Icons.notifications_outlined, 'Reminders'),
              _buildNavItem(scheme, 4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(ColorScheme scheme, int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterIdentifyButton(ColorScheme scheme) {
    final isSelected = currentIndex == 2;
    return GestureDetector(
      onTap: () => onTap(2),
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Container(
          width: 54,
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withAlpha(102),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            color: isSelected ? scheme.secondary : scheme.onPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}
