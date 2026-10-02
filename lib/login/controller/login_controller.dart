import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';

class LoginController extends GetxController {
  LoginController({AuthController? auth})
    : auth = auth ?? Get.find<AuthController>();

  final AuthController auth;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  Future<String?> login() => auth.emailLogin(
    email: emailController.text,
    password: passwordController.text,
  );

  Future<String?> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email);

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
