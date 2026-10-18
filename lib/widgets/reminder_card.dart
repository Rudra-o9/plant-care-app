import 'package:flutter/material.dart';

import '../models/reminder_model.dart';
import '../theme/app_text_styles.dart';
import 'plant_image.dart';

/// Reusable Card component for plant care reminders with responsive constraints.
class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final ValueChanged<bool?> onToggleComplete;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = reminder.isCompleted;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? scheme.surfaceContainerHighest : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? Theme.of(context).dividerColor
              : scheme.secondary.withAlpha(76),
        ),
      ),
      child: Row(
        children: [
          // Checkbox toggle
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: isDone,
              activeColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: onToggleComplete,
            ),
          ),
          const SizedBox(width: 8),

          // Plant Thumbnail Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: PlantImage(
                source: reminder.plantImageUrl,
                errorWidget: Container(
                  color: scheme.secondaryContainer,
                  child: Icon(
                    Icons.spa_rounded,
                    color: scheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reminder.taskType.iconEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${reminder.taskType.displayName} ${reminder.plantName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${reminder.repeatFrequency} • ${_formatTime(reminder.scheduledTime)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isDone
                        ? scheme.onSurfaceVariant
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Delete Action
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: scheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
