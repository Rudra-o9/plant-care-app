import '../models/plant_model.dart';
import '../models/reminder_model.dart';

/// Live dashboard values derived from the signed-in user's saved data.
class DashboardStats {
  final int totalPlants;
  final int tasksToday;
  final int careStreakDays;

  const DashboardStats({
    required this.totalPlants,
    required this.tasksToday,
    required this.careStreakDays,
  });

  factory DashboardStats.calculate({
    required List<PlantModel> plants,
    required List<ReminderModel> reminders,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final activityDays = <String>{
      for (final plant in plants) ...plant.careActivityDates,
      for (final reminder in reminders)
        if (reminder.isCompleted)
          _dateKey(reminder.completedAt ?? reminder.scheduledTime),
    };
    final today = _day(current);
    final tasksToday = reminders.where((reminder) {
      return !reminder.isCompleted && _sameDay(reminder.scheduledTime, today);
    }).length;

    // A streak may carry over from yesterday until today's care is due.
    var day = activityDays.contains(_dateKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (activityDays.contains(_dateKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return DashboardStats(
      totalPlants: plants.length,
      tasksToday: tasksToday,
      careStreakDays: streak,
    );
  }
}

DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
