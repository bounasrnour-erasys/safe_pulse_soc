import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _AnalyticsCard(title: 'MTTR (hrs)', value: '1.8'),
              _AnalyticsCard(title: 'False Positive Rate', value: '7.4%'),
              _AnalyticsCard(title: 'Mean Alerts / hr', value: '28'),
              _AnalyticsCard(title: 'Escalation Rate', value: '12%'),
            ],
          ),
          const SizedBox(height: 16),
          const _BigCard(title: 'Trends', description: 'Visualize long-term trends. Replace with real charts.'),
          const SizedBox(height: 16),
          const _BigCard(title: 'Detection Efficacy', description: 'Breakdown by rule set and signal source.'),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  const _AnalyticsCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final String title;
  final String description;
  const _BigCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary.withValues(alpha: 0.08), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: Colors.white70)),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.open_in_full), label: const Text('Expand')),
            )
          ],
        ),
      ),
    );
  }
}
