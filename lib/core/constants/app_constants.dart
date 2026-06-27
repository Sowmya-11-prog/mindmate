/// Centralized constants for the MindMate app.
class AppConstants {
  AppConstants._();

  static const String appName = 'MindMate';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String moodEntriesCollection = 'mood_entries';
  static const String journalEntriesCollection = 'journal_entries';

  // Hive box names (offline cache)
  static const String moodBox = 'mood_box';
  static const String journalBox = 'journal_box';
  static const String settingsBox = 'settings_box';

  // Emotion categories used across mood tracker & insights
  static const List<String> emotions = [
    'Happy',
    'Calm',
    'Anxious',
    'Stressed',
    'Sad',
    'Angry',
    'Tired',
    'Excited',
  ];

  /// IMPORTANT: Crisis support resources.
  /// Verify and localize these for your target region before release.
  /// These are India-focused as a starting point — confirm numbers are
  /// current and add region-specific resources for other countries.
  static const List<Map<String, String>> crisisResources = [
    {
      'name': 'KIRAN Mental Health Helpline (India, 24x7, toll-free)',
      'phone': '1800-599-0019',
    },
    {
      'name': 'Tele-MANAS (Govt. of India tele-mental health service)',
      'phone': '14416',
      'url': 'https://telemanas.mohfw.gov.in/',
    },
  ];
}
