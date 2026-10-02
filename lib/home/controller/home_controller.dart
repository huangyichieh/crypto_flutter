import 'package:get/get.dart';

class HomeController extends GetxController {
  final pageIndex = 0.obs;

  final pageNames = const ['Information', 'Bot', 'Setting'];

  String get pageName => pageNames[pageIndex.value];

  void selectPage(int index) {
    pageIndex.value = index;
  }
}
