import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a private journal entry.
/// Note: for real privacy, consider client-side encryption before
/// writing `content` to Firestore (e.g. using a key derived from the
/// user's auth credentials) since Firestore data is not end-to-end
/// encrypted by default.
class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map, String id) {
    return JournalEntry(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      tags: List<String>.from(map['tags'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
