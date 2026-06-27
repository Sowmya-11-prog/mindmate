# MindMate

A Flutter wellbeing companion app: mood tracking, relaxation tools, journaling,
light entertainment, insights, and always-accessible crisis support resources.

## Project Structure

```
lib/
├── core/            # theme, constants, shared widgets
├── data/
│   ├── models/      # MoodEntry, JournalEntry, AppUser
│   ├── repositories/# Firestore data access (one per feature)
│   └── services/    # FirebaseService, NotificationService
├── features/
│   ├── auth/        # login/signup + auth state provider
│   ├── mood_tracker/
│   ├── relaxation/   # breathing exercise + ambient sounds
│   ├── journal/
│   ├── entertainment/
│   ├── insights/     # mood trend charts
│   ├── crisis_support/
│   └── home/         # bottom-nav shell tying features together
├── routing/
└── main.dart
```

State management: **Riverpod**. Backend: **Firebase** (Auth + Firestore).

## Setup Steps

1. **Install Flutter SDK** (3.22+) if you haven't already:
   https://docs.flutter.dev/get-started/install

2. **Create the project locally** (this skeleton has the `lib/` code and
   `pubspec.yaml` already — you still need the native `android/`, `ios/`, etc.
   scaffolding that `flutter create` generates):
   ```bash
   flutter create --org com.yourcompany mindmate_tmp
   # then copy android/, ios/, web/, etc. folders from mindmate_tmp
   # into this project, replacing lib/ and pubspec.yaml with the ones provided
   ```
   (Or: copy this `lib/` and `pubspec.yaml` into a fresh `flutter create mindmate`.)

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Set up Firebase**:
   - Create a project at https://console.firebase.google.com
   - Enable **Authentication** (Email/Password provider)
   - Create a **Firestore** database (start in test mode for development,
     then lock down with proper security rules before launch)
   - Install the FlutterFire CLI and run:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
     This generates `lib/firebase_options.dart`. Then uncomment the
     `options: DefaultFirebaseOptions.currentPlatform` line in `main.dart`.

5. **Firestore security rules** (minimum starting point — tighten before
   production):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /mood_entries/{entryId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
         allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
       }
       match /journal_entries/{entryId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
         allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
       }
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

6. **Add sound assets** for the relaxation screen under `assets/sounds/`
   (royalty-free rain/ocean/forest tracks), and confirm the `assets:` section
   in `pubspec.yaml` matches.

7. **Run it**:
   ```bash
   flutter run
   ```

## Important: Crisis Support Resources

`lib/core/constants/app_constants.dart` ships with India-focused helpline
numbers (KIRAN, Tele-MANAS) as a starting point — **verify these are current
and add resources for every region you launch in.** The "Need help?" button
is reachable from any screen by design; keep it that way.

## Next Steps / Ideas for Later Versions

- AI chat companion (LLM-backed) — intentionally left out of v1 per your plan
- Push notifications for daily check-in reminders (service is stubbed in
  `notification_service.dart`)
- Emotion-frequency breakdown charts in Insights
- Offline-first sync using the Hive boxes already wired into `pubspec.yaml`
- A simple relaxing mini-game on the Entertainment screen
- App Store / Play Store mental-health app content guidelines — review before
  submitting, as both platforms have extra requirements for this category
