import 'package:flutter/material.dart';

class BotPage extends StatelessWidget {
  const BotPage({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_outlined, size: 72),
          SizedBox(height: 16),
          Text('Bot'),
        ],
      ),
    ),
  );
}
