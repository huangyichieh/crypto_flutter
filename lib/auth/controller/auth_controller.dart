import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController({bool listenToAuthChanges = true})
    : _listenToAuthChanges = listenToAuthChanges;

  final bool _listenToAuthChanges;
  StreamSubscription<User?>? _authSubscription;
  final loggedIn = false.obs;
  final userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (!_listenToAuthChanges) return;
    _setUser(FirebaseAuth.instance.currentUser);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _setUser,
    );
  }

  Future<String?> emailLogin({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      print("LOGIN ERROR: ${error.code}");
      return _messageForCode(error.code);
    } catch (_) {
      return 'Unable to authenticate. Check your connection and try again.';
    }
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (error) {
      print("LOGIN ERROR: ${error.code}");
      return _messageForCode(error.code);
    } catch (_) {
      return 'Unable to send the reset email. Please try again.';
    }
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();

  void _setUser(User? user) {
    userEmail.value = user?.email ?? '';
    loggedIn.value = user != null;
  }

  String _messageForCode(String code) => switch (code) {
    'user-not-found' => 'Incorrect email or password.',
    'wrong-password' => 'Incorrect email or password.',
    'invalid-credential' => 'Incorrect email or password.',
    'invalid-email' => 'Enter a valid email.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    _ => 'Unable to authenticate. Check your connection and try again.',
  };

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
