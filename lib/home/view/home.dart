import 'package:crypto_analysis_flutter/currency/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../currency/controller/currency_graph_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyGraphController>();
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crypto Tracker'),
            Text(
              'Market cycles with Binance REST data',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh data',
            onPressed: controller.refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 900 ? 28.0 : 14.0;
            return SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Section(title: 'Graph', child: CurrencyGraph()),
                      const SizedBox(height: 20),
                      const _Section(
                        title: 'TOP USDT Markets',
                        child: CurrencyMarketTable(),
                      ),
                      const SizedBox(height: 20),
                      const _Section(
                        title: 'Compare Favorites',
                        child: CurrencyCompareView(),
                      ),
                      const SizedBox(height: 20),
                      const _Section(
                        title: 'Fixed Deposit Rates',
                        child: _EarnNotice(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _EarnNotice extends StatelessWidget {
  const _EarnNotice();

  @override
  Widget build(BuildContext context) => const Text(
    'Binance Simple Earn is a signed account endpoint. For Android and web, '
    'API secrets must stay on a trusted backend; connect that backend here '
    'to enable locked-product APR data safely.',
  );
}
