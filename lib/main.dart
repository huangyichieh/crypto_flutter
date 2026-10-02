import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get/get.dart';

import 'auth/auth_middleware.dart';
import 'auth/controller/auth_controller.dart';
import 'firebase_options.dart';
import 'home/binding.dart';
import 'home/view.dart';
import 'login/binding.dart';
import 'login/view.dart';
import 'loading/view.dart';
import 'main_theme.dart';

class HidePathUrlStrategy extends HashUrlStrategy {
  HidePathUrlStrategy(this.basePath, [super.platformLocation]);

  final String basePath;

  @override
  String prepareExternalUrl(String internalUrl) => basePath;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setUrlStrategy(HidePathUrlStrategy(Uri.base.toString()));
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crypto Tracker',
      initialRoute: Get.find<AuthController>().loggedIn.value?
        '/home': '/login',
      theme: pcTheme,
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          binding: HomeBinding(),
          middlewares: [AuthMiddleware()],
        ),
        GetPage(
          name: '/loading',
          page: () => const AppLoadingPage(),
          transitionDuration: Duration.zero,
          opaque: false,
        ),
      ],
    );
  }
}
