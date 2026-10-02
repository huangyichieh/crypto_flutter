import 'dart:async';

import 'package:crypto_analysis_flutter/auth/controller/auth_controller.dart';

class FakeAuthController extends AuthController {
  FakeAuthController({this.loginCompleter}) : super(listenToAuthChanges: false);

  final Completer<String?>? loginCompleter;

  @override
  Future<String?> emailLogin({
    required String email,
    required String password,
  }) async {
    if (loginCompleter != null) await loginCompleter!.future;
    userEmail.value = email;
    loggedIn.value = true;
    return null;
  }

  @override
  Future<String?> sendPasswordResetEmail(String email) async => null;

  @override
  Future<void> logout() async {
    userEmail.value = '';
    loggedIn.value = false;
  }
}
