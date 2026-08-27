import 'package:step_detector/core/model/base_model.dart';
class UserProfile implements BaseModel {
  final String id;
  final String email;
  final String name;
  final String bio;
  final int age;
  final double weight;
  final double height;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.bio,
    required this.age,
    required this.weight,
    required this.height,
    this.avatarUrl,
  });

  UserProfile copyWith({
    String? email,
    String? name,
    String? bio,
    int? age,
    double? weight,
    double? height,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
      'age': age,
      'weight': weight,
      'height': height,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      avatarUrl: map['avatarUrl'],
    );
  }
}

