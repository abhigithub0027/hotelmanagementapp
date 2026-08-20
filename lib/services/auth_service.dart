import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('=== DEBUG: Attempting to sign in with $email ===');
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('=== DEBUG: Sign in successful for ${result.user?.uid} ===');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('=== DEBUG: FirebaseAuthException in signIn: ${e.code} | ${e.message} ===');
      throw Exception(e.message ?? 'Authentication failed');
    } catch (e) {
      print('=== DEBUG: Unknown exception in signIn: $e ===');
      rethrow;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      print('=== DEBUG: Attempting to register with $email ===');
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      print('=== DEBUG: Registration successful for ${result.user?.uid} ===');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('=== DEBUG: FirebaseAuthException in register: ${e.code} | ${e.message} ===');
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      print('=== DEBUG: Unknown exception in register: $e ===');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
