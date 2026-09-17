import 'package:crypto_analysis_flutter/currency/controller/currency_graph_controller.dart';
import 'package:crypto_analysis_flutter/home/view/home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('dashboard renders its main sections', (tester) async {
    Get.put(CurrencyGraphController());
    await tester.pumpWidget(const GetMaterialApp(home: HomePage()));

    expect(find.text('Crypto Tracker'), findsOneWidget);
    expect(find.text('Graph'), findsOneWidget);
    expect(find.text('TOP USDT Markets'), findsOneWidget);
    expect(find.text('Compare Favorites'), findsOneWidget);
    expect(find.text('Fixed Deposit Rates'), findsOneWidget);

    Get.reset();
  });
}
