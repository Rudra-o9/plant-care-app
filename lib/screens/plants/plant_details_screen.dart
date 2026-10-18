import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../models/plant_model.dart';
import '../../models/reminder_model.dart';
import '../../services/plant_service.dart';
import '../../services/reminder_service.dart';
import '../../widgets/plant_image.dart';
import 'plant_journal_screen.dart';

/// Detailed view for a single plant in the user's collection.
class PlantDetailsScreen extends StatefulWidget {
  final PlantModel plant;

  const PlantDetailsScreen({super.key, required this.plant});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  late PlantModel _plant;
  final _plantService = PlantService();
  final _reminderService = ReminderService();

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  void _markWatered() {
    _plantService.markWatered(_plant.id);
    setState(() {
      _plant = _plant.copyWith(lastWatered: DateTime.now());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked ${_plant.name} as watered today! 💧'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _addReminder() {
    final newReminder = ReminderModel(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      plantId: _plant.id,
      plantName: _plant.name,
      plantImageUrl: _plant.imageUrl,
      taskType: TaskType.watering,
      scheduledTime: DateTime.now().add(
        Duration(days: _plant.wateringFrequencyDays),
      ),
      repeatFrequency: 'Every ${_plant.wateringFrequencyDays} days',
    );

    _reminderService.addReminder(newReminder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${_plant.name}! ⏰'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _deletePlant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete plant?'),
        content: Text(
          'Delete ${_plant.name} and all of its reminders? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _reminderService.deleteForPlant(_plant.id);
      await _plantService.deletePlant(_plant.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete this plant. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero Banner Header
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withAlpha(217),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(217),
                  child: IconButton(
                    tooltip: 'Delete plant',
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    onPressed: _deletePlant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(217),
                  child: IconButton(
                    icon: Icon(
                      _plant.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _plant.isFavorite
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                    onPressed: () {
                      _plantService.toggleFavorite(_plant.id);
                      setState(() {
                        _plant = _plant.copyWith(
                          isFavorite: !_plant.isFavorite,
                        );
                      });
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PlantImage(source: _plant.imageUrl),
            ),
          ),

          // Content Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _plant.name,
                              style: AppTextStyles.displayMedium.copyWith(
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _plant.scientificName,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentMint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_plant.careLevel} Care',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quick Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Water Today 💧',
                          onPressed: _markWatered,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Set Reminder',
                          type: ButtonType.secondary,
                          icon: Icons.notifications_active_rounded,
                          onPressed: _addReminder,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Description
                  Text(
                    'About this plant',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(_plant.description, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 28),

                  Text(
                    'Plant Journal 📔',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _plant.journalEntries.isEmpty
                        ? 'Add dated notes and progress photos to track this plant.'
                        : '${_plant.journalEntries.length} saved journal update${_plant.journalEntries.length == 1 ? '' : 's'}.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Open journal'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlantJournalScreen(plant: _plant),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Care Guide Section
                  Text(
                    'Care Guide 🌿',
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  _buildCareRow(
                    Icons.water_drop_outlined,
                    'Watering Frequency',
                    'Every ${_plant.wateringFrequencyDays} days (Last watered ${_formatDaysAgo(_plant.lastWatered)})',
                  ),
                  _buildCareRow(
                    Icons.wb_sunny_outlined,
                    'Sunlight',
                    _plant.sunlight,
                  ),
                  _buildCareRow(
                    Icons.thermostat_outlined,
                    'Temperature',
                    _plant.temperature,
                  ),
                  _buildCareRow(
                    Icons.grass_outlined,
                    'Soil Mix',
                    _plant.soilType,
                  ),
                  const SizedBox(height: 24),

                  // Custom Notes Section
                  if (_plant.customNotes.isNotEmpty) ...[
                    Text(
                      'Personal Notes 📝',
                      style: AppTextStyles.headlineLarge.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        _plant.customNotes,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.accentMint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDaysAgo(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }
}
