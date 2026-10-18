import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_stats.dart';
import '../../services/plant_service.dart';
import '../../services/reminder_service.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/page_transitions.dart';

/// User Profile dashboard screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;
    final plantService = PlantService();
    final reminderService = ReminderService();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context)
                  .push(AppPageRoute.slideUp(const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    user?.name ?? 'Alex Rivera',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'alex.rivera@example.com',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      plantService,
                      reminderService,
                    ]),
                    builder: (context, _) {
                      final stats = DashboardStats.calculate(
                        plants: plantService.allPlants,
                        reminders: reminderService.reminders,
                      );
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatColumn(
                              context,
                              '${stats.totalPlants}',
                              'Plants',
                            ),
                          ),
                          Expanded(
                            child: _buildStatColumn(
                              context,
                              '${stats.careStreakDays} Days',
                              'Streak',
                            ),
                          ),
                          Expanded(
                            child: _buildStatColumn(
                              context,
                              'Care',
                              'Plant owner',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Options List
            _buildMenuTile(
              context: context,
              icon: Icons.settings_rounded,
              title: 'App Settings',
              onTap: () {
                Navigator.of(context)
                    .push(AppPageRoute.slideUp(const SettingsScreen()));
              },
            ),
            _buildMenuTile(
              context: context,
              icon: Icons.help_outline_rounded,
              title: 'Help & Care Advice',
              onTap: () => _showInfo(
                context,
                'Help & Care Advice',
                'Use Identify Plant to take or choose a clear photo. Select one of the top two matches, then add it to My Plants. Each saved plant includes watering, sunlight, temperature and soil guidance.',
              ),
            ),
            _buildMenuTile(
              context: context,
              icon: Icons.info_outline_rounded,
              title: 'About Plant Care',
              onTap: () => _showInfo(
                context,
                'About Plant Care',
                'Plant Care helps you identify plants, keep care notes and schedule watering reminders. Plant identification is powered by Pl@ntNet.',
              ),
            ),
            const SizedBox(height: 16),

            // Logout Tile
            _buildMenuTile(
              context: context,
              icon: Icons.logout_rounded,
              title: 'Logout',
              titleColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                authService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  AppPageRoute.fadeIn(const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? AppColors.primary),
          title: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: titleColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
