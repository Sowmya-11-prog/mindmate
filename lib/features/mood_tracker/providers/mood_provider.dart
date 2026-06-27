import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/mood_entry.dart';
import '../../auth/providers/auth_provider.dart';

/// Streams the current user's mood history, ordered newest first.
final moodHistoryProvider = StreamProvider<List<MoodEntry>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return const Stream.empty();
  final repo = ref.watch(moodRepositoryProvider);
  return repo.watchUserMoods(user.uid);
});

/// Handles writing a new mood entry.
final moodControllerProvider = Provider((ref) {
  return MoodController(ref);
});

class MoodController {
  final Ref ref;
  MoodController(this.ref);

  Future<void> logMood({
    required String emotion,
    required int intensity,
    String? note,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;
    final repo = ref.read(moodRepositoryProvider);
    await repo.addMoodEntry(MoodEntry(
      id: const Uuid().v4(),
      userId: user.uid,
      emotion: emotion,
      intensity: intensity,
      note: note,
      createdAt: DateTime.now(),
    ));
  }
}
