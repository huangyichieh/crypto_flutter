import 'dart:async';

import 'package:crypto_analysis_flutter/auth/controller/auth_controller.dart';
import 'package:crypto_analysis_flutter/login/binding.dart';
import 'package:crypto_analysis_flutter/login/view.dart';
import 'package:crypto_analysis_flutter/loading/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/fake_auth_controller.dart';

void main() {
  testWidgets('successful login replaces the login route with home', (
    tester,
  ) async {
    final loginCompleter = Completer<String?>();
    Get.put<AuthController>(FakeAuthController(loginCompleter: loginCompleter));
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/login',
        getPages: [
          GetPage(
            name: '/login',
            page: () => const LoginPage(),
            binding: LoginBinding(),
          ),
          GetPage(
            name: '/home',
            page: () => const Scaffold(body: Text('Authenticated home')),
          ),
          GetPage(
            name: '/loading',
            page: () => const AppLoadingPage(),
            transitionDuration: Duration.zero,
            opaque: false,
          ),
        ],
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'user@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.byType(AppLoadingPage), findsOneWidget);

    loginCompleter.complete(null);
    await tester.pumpAndSettle();

    expect(find.text('Authenticated home'), findsOneWidget);
    expect(Get.find<AuthController>().loggedIn.value, isTrue);
  });
}
