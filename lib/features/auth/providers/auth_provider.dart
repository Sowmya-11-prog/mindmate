import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/repositories/mood_repository.dart';
import '../../../data/repositories/journal_repository.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository(ref.watch(firebaseServiceProvider));
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(firebaseServiceProvider));
});

/// Emits the current Firebase auth user, or null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges;
});

/// Convenience provider: true once we know the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).asData?.value != null;
});
