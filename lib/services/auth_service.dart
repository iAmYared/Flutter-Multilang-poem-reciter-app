import 'package:firebase_auth/firebase_auth.dart';
import 'package:peom_reciter_app/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Sign up method
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        await _firestoreService.saveUser(user.uid, user.email!);
      }
      return user;
    } catch (e) {
      print('Sign-up failed: $e');
      return null;
    }
  }

  // Sign in method
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Sign-in failed: $e');
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Current user method
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
