import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home/binding.dart';
import 'home/view.dart';
import 'main_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Crypto Tracker',
      initialRoute: '/',
      theme: pcTheme,
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomePage(),
          binding: HomeBinding(),
        ),
      ],
    );
  }
}
