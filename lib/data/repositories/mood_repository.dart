import '../models/mood_entry.dart';
import '../services/firebase_service.dart';

/// Handles all data operations for mood entries.
/// Screens/providers should go through this class rather than
/// touching Firestore directly — keeps data access swappable & testable.
class MoodRepository {
  final FirebaseService _service;

  MoodRepository(this._service);

  Future<void> addMoodEntry(MoodEntry entry) async {
    await _service.moodEntries.doc(entry.id).set(entry.toMap());
  }

  Stream<List<MoodEntry>> watchUserMoods(String userId) {
    return _service.moodEntries
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MoodEntry.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<MoodEntry>> getMoodsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _service.moodEntries
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .orderBy('createdAt')
        .get();
    return snap.docs.map((doc) => MoodEntry.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> deleteMoodEntry(String id) async {
    await _service.moodEntries.doc(id).delete();
  }
}
