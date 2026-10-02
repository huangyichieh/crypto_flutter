import 'package:crypto_analysis_flutter/auth/controller/auth_controller.dart';
import 'package:crypto_analysis_flutter/currency/controller/currency_graph_controller.dart';
import 'package:crypto_analysis_flutter/currency/model/currency_stats.dart';
import 'package:crypto_analysis_flutter/home/view.dart';
import 'package:crypto_analysis_flutter/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'support/fake_auth_controller.dart';

void main() {
  testWidgets('dashboard renders its main sections', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Get.put<AuthController>(FakeAuthController());
    Get.put(CurrencyGraphController());
    Get.put(HomeController());
    await tester.pumpWidget(const GetMaterialApp(home: HomePage()));

    expect(find.text('Crypto Tracker'), findsOneWidget);
    expect(find.text('Graph'), findsOneWidget);
    expect(find.text('TOP USDT Markets'), findsOneWidget);
    expect(find.text('Compare Favorites'), findsOneWidget);
    expect(find.text('Fixed Deposit Rates'), findsOneWidget);
    expect(find.byTooltip('Refresh Graph'), findsOneWidget);
    expect(find.byTooltip('Refresh TOP USDT Markets'), findsOneWidget);
    expect(find.byTooltip('Refresh Compare Favorites'), findsOneWidget);
    expect(find.byTooltip('Refresh Fixed Deposit Rates'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);

    final controller = Get.find<CurrencyGraphController>();
    expect(find.text('Range'), findsNWidgets(2));
    expect(find.text('Candle'), findsNWidgets(2));
    controller.setCompareInterval(CurrencyGraphInterval.interval_1w);
    expect(controller.compareInterval.value, CurrencyGraphInterval.interval_1w);
    expect(controller.interval.value, CurrencyGraphInterval.interval_1d);
    controller.setCompareCandle(CurrencyGraphCandle.candles_8h);
    expect(controller.compareCandle.value, CurrencyGraphCandle.candles_8h);
    expect(controller.candle.value, CurrencyGraphCandle.candles_15m);
    final countField = find.byType(TextField).last;
    final applyButton = find.text('Apply');

    await tester.enterText(countField, '12');
    expect(controller.topCount.value, 30);
    expect(find.text('Current: 30'), findsOneWidget);

    await tester.tap(applyButton);
    await tester.pump();
    expect(controller.topCount.value, 12);
    expect(find.text('Current: 12'), findsOneWidget);

    await tester.enterText(countField, '101');
    await tester.tap(applyButton);
    await tester.pump();
    expect(controller.topCount.value, 12);
    expect(find.text('Enter a number from 1 to 100.'), findsOneWidget);

    await tester.enterText(countField, '');
    await tester.tap(applyButton);
    await tester.pump();
    expect(controller.topCount.value, 12);
    expect(find.text('Enter a number from 1 to 100.'), findsOneWidget);

    expect(find.text('Information'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    final homeController = Get.find<HomeController>();
    homeController.selectPage(1);
    await tester.pump();
    expect(homeController.pageName, 'Bot');
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);

    homeController.selectPage(2);
    await tester.pump();
    expect(homeController.pageName, 'Setting');
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    Get.reset();
  });
}
