import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/login_controller.dart';

class ForgetPasswordDialog extends StatefulWidget {
  const ForgetPasswordDialog({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgetPasswordDialog> createState() => _ForgetPasswordDialogState();
}

class _ForgetPasswordDialogState extends State<ForgetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Get.back(result: _emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Reset password'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _emailController,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
        ),
        validator: LoginController.validateEmail,
      ),
    ),
    actions: [
      TextButton(onPressed: Get.back, child: const Text('Cancel')),
      FilledButton(onPressed: _submit, child: const Text('Send link')),
    ],
  );
}

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  Future<void> _login() async {
    if (!controller.formKey.currentState!.validate()) return;
    final loginTask = controller.login();
    final result = await Get.toNamed<dynamic>(
      '/loading',
      arguments: {'task': loginTask},
    );
    final message = result as String?;
    if (message == null) {
      Get.offAllNamed('/home');
    } else {
      await _showMessage('Login failed', message);
    }
  }

  Future<void> _forgotPassword() async {
    final email = await Get.dialog<String>(
      ForgetPasswordDialog(
        initialEmail: controller.emailController.text.trim(),
      ),
    );
    if (email == null) return;
    final resetTask = controller.resetPassword(email);
    final result = await Get.toNamed<dynamic>(
      '/loading',
      arguments: {'task': resetTask},
    );
    final message = result as String?;
    await _showMessage(
      message == null ? 'Email sent' : 'Unable to reset password',
      message ?? 'A password reset link was sent to $email.',
    );
  }

  Future<void> _showMessage(String title, String message) => Get.dialog<void>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Obx(
        () => Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.currency_bitcoin,
                              size: 88,
                              color: Color(0xFF38BDF8),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Crypto Tracker',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to continue',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 28),
                            TextFormField(
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: LoginController.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: controller.passwordController,
                              obscureText: controller.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: controller.obscurePassword.value
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                  icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: LoginController.validatePassword,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _login,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text('Sign in'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
