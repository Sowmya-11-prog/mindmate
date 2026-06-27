import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/journal_entry.dart';
import '../../auth/providers/auth_provider.dart';

final journalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.watch(journalRepositoryProvider).watchUserEntries(user.uid);
});

final journalControllerProvider = Provider((ref) => JournalController(ref));

class JournalController {
  final Ref ref;
  JournalController(this.ref);

  Future<void> addEntry({required String title, required String content}) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;
    final now = DateTime.now();
    await ref.read(journalRepositoryProvider).addEntry(JournalEntry(
          id: const Uuid().v4(),
          userId: user.uid,
          title: title,
          content: content,
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(journalRepositoryProvider).deleteEntry(id);
  }

  Future<void> seedIfNeeded() async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final flagKey = 'journal_seeded_${user.uid}';
    if (prefs.getBool(flagKey) == true) return;

    final repo = ref.read(journalRepositoryProvider);
    final existing = await repo.watchUserEntries(user.uid).first;
    if (existing.isNotEmpty) {
      await prefs.setBool(flagKey, true);
      return;
    }

    final now = DateTime.now();
    final samples = [
      JournalEntry(
        id: const Uuid().v4(),
        userId: user.uid,
        title: 'Welcome to your journal',
        content:
            'This is your private space to write down anything on your mind — '
            'a tough moment, something you\'re grateful for, or just how today went. '
            'Tap the + button anytime to add a new entry.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      JournalEntry(
        id: const Uuid().v4(),
        userId: user.uid,
        title: 'A small win',
        content:
            'Try writing about one small thing that went okay today, even '
            'if the rest of the day was hard. Small wins count.',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      JournalEntry(
        id: const Uuid().v4(),
        userId: user.uid,
        title: 'How are you, really?',
        content:
            'Not the polite answer — the real one. What\'s actually going on '
            'for you right now? There\'s no wrong way to answer that here.',
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final entry in samples) {
      await repo.addEntry(entry);
    }
    await prefs.setBool(flagKey, true);
  }
}