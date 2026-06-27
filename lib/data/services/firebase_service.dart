import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Thin wrapper around Firebase Auth + Firestore so the rest of the app
/// never talks to the Firebase SDK directly. Makes it easy to swap/mock
/// in tests or switch providers later.
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) {
    return _firestore.collection(AppConstants.usersCollection).doc(uid).set(data);
  }

  CollectionReference<Map<String, dynamic>> get moodEntries =>
      _firestore.collection(AppConstants.moodEntriesCollection);

  CollectionReference<Map<String, dynamic>> get journalEntries =>
      _firestore.collection(AppConstants.journalEntriesCollection);
}
