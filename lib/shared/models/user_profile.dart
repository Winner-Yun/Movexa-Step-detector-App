class UserProfile {
  final String id;
  final String name;
  final String bio;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.name,
    required this.bio,
    required this.age,
    required this.weight,
    required this.height,
    this.avatarUrl,
  });

  // Creates a copy of the profile with updated fields
  UserProfile copyWith({
    String? name,
    String? bio,
    int? age,
    double? weight,
    double? height,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  // Convert to JSON/Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      avatarUrl: map['avatarUrl'],
    );
  }
}
