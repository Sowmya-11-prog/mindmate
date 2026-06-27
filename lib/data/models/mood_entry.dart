import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single mood/emotion check-in logged by the user.
class MoodEntry {
  final String id;
  final String userId;
  final String emotion; // e.g. "Anxious", "Calm" — see AppConstants.emotions
  final int intensity; // 1 (mild) - 5 (intense)
  final String? note;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.emotion,
    required this.intensity,
    required this.createdAt,
    this.note,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map, String id) {
    return MoodEntry(
      id: id,
      userId: map['userId'] as String,
      emotion: map['emotion'] as String,
      intensity: map['intensity'] as int,
      note: map['note'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'emotion': emotion,
      'intensity': intensity,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
