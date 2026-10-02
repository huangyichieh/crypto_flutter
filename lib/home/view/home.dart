import 'package:crypto_analysis_flutter/currency/view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../../bot/view.dart';
import '../../currency/controller/currency_graph_controller.dart';
import '../../setting/view.dart';
import '../controller/home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CurrencyGraphController>();
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();
    final pages = [
      SafeArea(
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
                      _Section(
                        title: 'Graph',
                        onRefresh: controller.refreshGraph,
                        loading: controller.loading,
                        child: CurrencyGraph(),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'TOP USDT Markets',
                        onRefresh: controller.refreshMarkets,
                        loading: controller.marketLoading,
                        child: const CurrencyMarketTable(),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Compare Favorites',
                        onRefresh: controller.refreshComparison,
                        loading: controller.compareLoading,
                        child: const CurrencyCompareView(),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        title: 'Fixed Deposit Rates',
                        onRefresh: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Connect a trusted backend to refresh deposit rates.',
                              ),
                            ),
                          );
                        },
                        child: const _EarnNotice(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const BotPage(),
      const SettingPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(homeController.pageName)),
            const Text('Crypto Tracker', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Obx(
            () => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  authController.userEmail.value,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await authController.logout();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView.builder(
            itemCount: homeController.pageNames.length,
            itemBuilder: (context, index) => Obx(
              () => ListTile(
                leading: Icon(
                  [
                    Icons.info_outline,
                    Icons.smart_toy_outlined,
                    Icons.settings,
                  ][index],
                ),
                title: Text(homeController.pageNames[index]),
                selected: homeController.pageIndex.value == index,
                onTap: () {
                  homeController.selectPage(index);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
      body: Obx(() => pages[homeController.pageIndex.value]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.onRefresh,
    this.loading,
  });
  final String title;
  final Widget child;
  final Future<void> Function() onRefresh;
  final RxBool? loading;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (loading == null)
                IconButton(
                  tooltip: 'Refresh $title',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                )
              else
                Obx(
                  () => IconButton(
                    tooltip: 'Refresh $title',
                    onPressed: loading!.value ? null : onRefresh,
                    icon: loading!.value
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ),
            ],
          ),
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
