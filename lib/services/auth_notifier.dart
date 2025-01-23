import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthNotifier() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  void signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
