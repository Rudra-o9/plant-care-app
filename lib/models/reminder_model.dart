enum TaskType { watering, fertilizing, misting, repotting, pruning }

extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.watering:
        return 'Watering';
      case TaskType.fertilizing:
        return 'Fertilizing';
      case TaskType.misting:
        return 'Misting';
      case TaskType.repotting:
        return 'Repotting';
      case TaskType.pruning:
        return 'Pruning';
    }
  }

  String get iconEmoji {
    switch (this) {
      case TaskType.watering:
        return '💧';
      case TaskType.fertilizing:
        return '🌱';
      case TaskType.misting:
        return '☁️';
      case TaskType.repotting:
        return '🪴';
      case TaskType.pruning:
        return '✂️';
    }
  }
}

/// Model representing a single scheduled plant care reminder.
class ReminderModel {
  final String id;
  final String plantId;
  final String plantName;
  final String plantImageUrl;
  final TaskType taskType;
  final DateTime scheduledTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final String repeatFrequency; // e.g. "Every 7 days", "Every month"

  const ReminderModel({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.plantImageUrl,
    required this.taskType,
    required this.scheduledTime,
    this.isCompleted = false,
    this.completedAt,
    required this.repeatFrequency,
  });

  ReminderModel copyWith({
    String? id,
    String? plantId,
    String? plantName,
    String? plantImageUrl,
    TaskType? taskType,
    DateTime? scheduledTime,
    bool? isCompleted,
    DateTime? completedAt,
    String? repeatFrequency,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      plantImageUrl: plantImageUrl ?? this.plantImageUrl,
      taskType: taskType ?? this.taskType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
    );
  }
}
