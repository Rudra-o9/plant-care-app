/// User model representing the authenticated plant owner.
class UserModel {
  final String id;
  final String name;
  final String? surname;
  final String email;
  final String? mobileNumber;
  final String? avatarUrl;
  final int totalPlants;
  final int careStreakDays;
  final int plantsNeedingAttention;

  const UserModel({
    required this.id,
    required this.name,
    this.surname,
    required this.email,
    this.mobileNumber,
    this.avatarUrl,
    this.totalPlants = 0,
    this.careStreakDays = 0,
    this.plantsNeedingAttention = 0,
  });

  /// Returns user's full display name
  String get fullName => surname != null && surname!.isNotEmpty ? '$name $surname' : name;

  UserModel copyWith({
    String? id,
    String? name,
    String? surname,
    String? email,
    String? mobileNumber,
    String? avatarUrl,
    int? totalPlants,
    int? careStreakDays,
    int? plantsNeedingAttention,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPlants: totalPlants ?? this.totalPlants,
      careStreakDays: careStreakDays ?? this.careStreakDays,
      plantsNeedingAttention: plantsNeedingAttention ?? this.plantsNeedingAttention,
    );
  }
}
