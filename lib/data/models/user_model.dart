class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime joinedAt;
  final int currentStreak; // consecutive days of mood check-ins

  AppUser({
    required this.uid,
    required this.email,
    required this.joinedAt,
    this.displayName,
    this.currentStreak = 0,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      joinedAt: DateTime.parse(map['joinedAt'] as String),
      currentStreak: map['currentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'joinedAt': joinedAt.toIso8601String(),
      'currentStreak': currentStreak,
    };
  }
}
