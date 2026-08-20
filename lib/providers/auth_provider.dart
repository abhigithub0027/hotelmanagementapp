import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticated => _auth.currentUser != null;

  String? _token;
  String? get token => _token;
  User? get user => _auth.currentUser;

  bool isLoading = false;
  String? error;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _token = credential.user?.uid;
      _isLoggedIn = credential.user != null;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null && _token!.isNotEmpty) {
        await prefs.setString('token', _token!);
      }

      return _isLoggedIn;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Login failed';
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _token = credential.user?.uid;
      _isLoggedIn = credential.user != null;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null && _token!.isNotEmpty) {
        await prefs.setString('token', _token!);
      }

      return _isLoggedIn;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Registration failed';
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _token = token;
    _isLoggedIn = _auth.currentUser != null || (token != null && token.isNotEmpty);

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    _token = null;
    _isLoggedIn = false;
    await _auth.signOut();

    notifyListeners();
  }
}