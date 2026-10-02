import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    return auth.loggedIn.value ? null : const RouteSettings(name: '/login');
  }
}
