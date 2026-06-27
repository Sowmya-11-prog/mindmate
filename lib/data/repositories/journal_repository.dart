import '../models/journal_entry.dart';
import '../services/firebase_service.dart';

class JournalRepository {
  final FirebaseService _service;

  JournalRepository(this._service);

  Future<void> addEntry(JournalEntry entry) async {
    await _service.journalEntries.doc(entry.id).set(entry.toMap());
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await _service.journalEntries.doc(entry.id).update(entry.toMap());
  }

  Stream<List<JournalEntry>> watchUserEntries(String userId) {
    return _service.journalEntries
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => JournalEntry.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteEntry(String id) async {
    await _service.journalEntries.doc(id).delete();
  }
}
