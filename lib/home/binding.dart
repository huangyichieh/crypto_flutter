import 'package:get/get.dart';

import '../currency/controller/currency_graph_controller.dart';
import 'controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CurrencyGraphController());
    Get.lazyPut(() => HomeController());
  }
}
