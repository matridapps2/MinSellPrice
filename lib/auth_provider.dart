import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    _isLoggedIn = firebaseUser != null;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await checkLoginStatus();
  }

  Future<void> login() async {
    await checkLoginStatus();
  }
}
