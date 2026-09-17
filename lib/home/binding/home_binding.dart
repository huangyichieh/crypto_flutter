import 'package:get/get.dart';

import '../../currency/controller/currency_graph_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CurrencyGraphController());
  }
}
