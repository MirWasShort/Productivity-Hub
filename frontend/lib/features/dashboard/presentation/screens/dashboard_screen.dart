import 'package:flutter/material.dart';

/// Placeholder — the real dashboard lands with the analytics feature.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        key: const Key('dashboard_placeholder'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            const Text('Le statistiche arrivano presto'),
          ],
        ),
      ),
    );
  }
}
