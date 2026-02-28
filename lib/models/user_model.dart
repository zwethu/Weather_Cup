import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String gender;

  @HiveField(2)
  double weight; // in kg

  @HiveField(3)
  double height; // in cm

  @HiveField(4)
  String wakeTime; // e.g., "06:30"

  @HiveField(5)
  String sleepTime; // e.g., "23:30"

  @HiveField(6)
  String country;

  @HiveField(7)
  String city;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool onboardingCompleted;

  UserModel({
    required this.name,
    required this.gender,
    required this.weight,
    required this.height,
    required this.wakeTime,
    required this.sleepTime,
    required this.country,
    required this.city,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.onboardingCompleted = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Calculate recommended daily water intake in ml
  /// Based on weight: 30-35ml per kg of body weight
  int get recommendedDailyIntake {
    // Base calculation: 33ml per kg
    return (weight * 33).round();
  }

  /// Copy with updated fields
  UserModel copyWith({
    String? name,
    String? gender,
    double? weight,
    double? height,
    String? wakeTime,
    String? sleepTime,
    String? country,
    String? city,
    bool? onboardingCompleted,
  }) {
    return UserModel(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      country: country ?? this.country,
      city: city ?? this.city,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, gender: $gender, weight: $weight, height: $height, '
        'wakeTime: $wakeTime, sleepTime: $sleepTime, country: $country, city: $city, '
        'onboardingCompleted: $onboardingCompleted)';
  }
}

