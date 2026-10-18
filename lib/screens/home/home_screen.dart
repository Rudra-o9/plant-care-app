import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/section_header.dart';
import '../../widgets/plant_card.dart';
import '../../widgets/reminder_card.dart';
import '../../services/auth_service.dart';
import '../../services/plant_service.dart';
import '../../services/reminder_service.dart';
import '../../services/dashboard_stats.dart';
import '../plants/plant_details_screen.dart';
import '../../utils/page_transitions.dart';

/// Main Dashboard Home Screen with responsive layout and clean greeting header.
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToIdentify;
  final VoidCallback onNavigateToMyPlants;
  final VoidCallback onNavigateToReminders;

  const HomeScreen({
    super.key,
    required this.onNavigateToIdentify,
    required this.onNavigateToMyPlants,
    required this.onNavigateToReminders,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final plantService = PlantService();
    final reminderService = ReminderService();

    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header User Profile Greeting (photo removed per specification)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome 👋', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      user?.name ?? 'Alex Rivera',
                      style: AppTextStyles.displayMedium.copyWith(fontSize: 24),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Care Summary Card with responsive columns
                ListenableBuilder(
                  listenable: Listenable.merge([plantService, reminderService]),
                  builder: (context, _) {
                    final stats = DashboardStats.calculate(
                      plants: plantService.allPlants,
                      reminders: reminderService.reminders,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryStat(
                              '${stats.totalPlants}',
                              'Total Plants',
                              Icons.eco_rounded,
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: _buildSummaryStat(
                              '${stats.tasksToday}',
                              'Tasks Today',
                              Icons.water_drop_rounded,
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 1,
                            color: Colors.white24,
                          ),
                          Expanded(
                            child: _buildSummaryStat(
                              '${stats.careStreakDays}d',
                              'Care Streak',
                              Icons.local_fire_department_rounded,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Main CTA Banner: "Identify a Plant"
                GestureDetector(
                  onTap: onNavigateToIdentify,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withAlpha(76),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Identify a Plant 📷',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Snap a photo to get instant diagnosis & care guide',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withAlpha(230),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Care Section
                SectionHeader(
                  title: "Today's Care 💧",
                  actionText: 'See All',
                  onActionTap: onNavigateToReminders,
                ),
                ListenableBuilder(
                  listenable: reminderService,
                  builder: (context, _) {
                    final todayList = reminderService.todayReminders;
                    if (todayList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'All plant care tasks completed for today!',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: todayList.take(2).map((reminder) {
                        return ReminderCard(
                          reminder: reminder,
                          onToggleComplete: (val) {
                            reminderService.toggleComplete(reminder.id);
                          },
                          onDelete: () {
                            reminderService.deleteReminder(reminder.id);
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // My Plants Section
                SectionHeader(
                  title: 'My Collection 🌿',
                  actionText: 'View All',
                  onActionTap: onNavigateToMyPlants,
                ),
                ListenableBuilder(
                  listenable: plantService,
                  builder: (context, _) {
                    final plantList = plantService.allPlants;
                    return SizedBox(
                      height: 195,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: plantList.length,
                        itemBuilder: (context, index) {
                          final plant = plantList[index];
                          return PlantCard(
                            plant: plant,
                            isCompact: true,
                            onTap: () {
                              Navigator.of(context).push(
                                AppPageRoute.slideUp(
                                  PlantDetailsScreen(plant: plant),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accentMint, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
