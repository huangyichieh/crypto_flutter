import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class AppLoadingPage extends StatefulWidget {
  const AppLoadingPage({super.key});

  @override
  State<AppLoadingPage> createState() => _AppLoadingPageState();
}

class _AppLoadingPageState extends State<AppLoadingPage> {
  late final Future<dynamic> _task;

  @override
  void initState() {
    super.initState();
    _task = (Get.arguments as Map<String, dynamic>)['task'] as Future<dynamic>;
    _completeTask();
  }

  Future<void> _completeTask() async {
    dynamic result;
    try {
      result = await _task;
    } catch (_) {
      result = null;
    }
    if (mounted) Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color.fromRGBO(11, 18, 32, 0.72),
    child: Center(
      child: SpinKitDoubleBounce(size: 72, color: Color(0xFF38BDF8)),
    ),
  );
}
