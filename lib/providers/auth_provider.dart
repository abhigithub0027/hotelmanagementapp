import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // We try to catch exceptions in case Firebase is not initialized
    try {
      _user = _authService.currentUser; // Synchronously load the current user
      _authService.authStateChanges.listen((User? user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      print("Firebase not initialized yet.");
    }
  }

  Future<bool> login(String email, String password) async {
    print('=== DEBUG: AuthProvider.login called ===');
    _setLoading(true);
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      print('=== DEBUG: AuthProvider.login error caught: $e ===');
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    print('=== DEBUG: AuthProvider.register called ===');
    _setLoading(true);
    try {
      await _authService.registerWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      print('=== DEBUG: AuthProvider.register error caught: $e ===');
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }
}
