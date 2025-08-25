import 'package:flutter/material.dart';

enum _QuickRange { today, last30, custom }

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  _QuickRange _quick = _QuickRange.today;
  DateTimeRange? _range;

  String get _rangeLabel {
    if (_quick == _QuickRange.today) return 'Today';
    if (_quick == _QuickRange.last30) return 'Last 30 days';
    if (_range != null) {
      final s = _range!.start.toLocal().toString().split(' ').first;
      final e = _range!.end.toLocal().toString().split(' ').first;
      return '$s → $e';
    }
    return 'Custom range';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 1);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      helpText: 'Select date range',
    );
    if (picked != null) {
      setState(() {
        _quick = _QuickRange.custom;
        _range = picked;
      });
    }
  }

  // --- simple sample data (replace with API later) ---
  int get _periodLength {
    switch (_quick) {
      case _QuickRange.today:
        return 7; // last 7 points (e.g., hours or days)
      case _QuickRange.last30:
        return 30;
      case _QuickRange.custom:
        if (_range == null) return 14;
        final days = _range!.end.difference(_range!.start).inDays.abs() + 1;
        return days.clamp(7, 60).toInt();
    }
  }

  List<int> _series(int n, {int seed = 7, int mod = 20}) {
    int x = seed;
    final out = <int>[];
    for (int i = 0; i < n; i++) {
      x = (x * 1103515245 + 12345) & 0x7fffffff; // LCG
      out.add(3 + (x % mod));
    }
    return out;
  }

  Map<String, int> _severityTotals() {
    final s = _series(_periodLength, seed: 11, mod: 25);
    final a = _series(_periodLength, seed: 13, mod: 18);
    final an = _series(_periodLength, seed: 17, mod: 12);
    final d = _series(_periodLength, seed: 19, mod: 6);
    int sum(List<int> l) => l.fold(0, (p, c) => p + c);
    return {
      'suspected': sum(s),
      'attempted': sum(a),
      'anomalous': sum(an),
      'definite': sum(d),
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _severityTotals();
    final totalIncidents = totals.values.fold<int>(0, (p, c) => p + c);
    final mttr = (1.2 + (totals['definite']! / 50)).toStringAsFixed(1);
    final alertsPerHr = (_periodLength > 0) ? (totalIncidents / (_periodLength * 24)).clamp(0, 9999).toStringAsFixed(1) : '0.0';

    final bars = _series(_periodLength, seed: 29, mod: 28);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + filters
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              ChoiceChip(
                label: const Text('Today'),
                selected: _quick == _QuickRange.today,
                onSelected: (_) => setState(() => _quick = _QuickRange.today),
              ),
              ChoiceChip(
                label: const Text('Last 30 days'),
                selected: _quick == _QuickRange.last30,
                onSelected: (_) => setState(() => _quick = _QuickRange.last30),
              ),
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range),
                label: Text(_rangeLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // KPIs
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _KpiCard(title: 'Total Incidents', value: '$totalIncidents'),
              _KpiCard(title: 'Definite Breaches', value: '${totals['definite']}'),
              _KpiCard(title: 'Attempted Breaches', value: '${totals['attempted']}'),
              _KpiCard(title: 'MTTR (hrs)', value: mttr),
              _KpiCard(title: 'Alerts / hr', value: alertsPerHr),
            ],
          ),

          const SizedBox(height: 16),
          // Breaches over time (bars)
          _ChartCard(
            title: 'Breaches over time',
            child: _MiniBarChart(values: bars, color: Theme.of(context).colorScheme.primary),
          ),

          const SizedBox(height: 16),
          // Severity mix (stack bar)
          _ChartCard(
            title: 'Severity mix',
            child: _StackSeverityBar(
              suspected: totals['suspected']!,
              attempted: totals['attempted']!,
              anomalous: totals['anomalous']!,
              definite: totals['definite']!,
            ),
          ),

          const SizedBox(height: 16),
          // Top anomaly sources (horizontal list with progress)
          _ChartCard(
            title: 'Top anomaly sources',
            child: _HList(items: const [
              MapEntry('Typing cadence', 72),
              MapEntry('Window switching', 54),
              MapEntry('Geo-IP variance', 36),
              MapEntry('Device posture', 21),
              MapEntry('MFA challenge', 18),
            ]),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
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

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final List<int> values;
  final Color color;
  const _MiniBarChart({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    final max = (values.isEmpty) ? 1 : values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < values.length; i++) ...[
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: (values[i] / max) * 140 + 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StackSeverityBar extends StatelessWidget {
  final int suspected;
  final int attempted;
  final int anomalous;
  final int definite;
  const _StackSeverityBar({
    required this.suspected,
    required this.attempted,
    required this.anomalous,
    required this.definite,
  });

  @override
  Widget build(BuildContext context) {
    final total = (suspected + attempted + anomalous + definite).clamp(1, 1 << 30);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white10,
          ),
          child: Row(
            children: [
              Expanded(flex: suspected, child: Container(decoration: BoxDecoration(color: const Color(0xFFFFA500), borderRadius: BorderRadius.circular(10)))),
              Expanded(flex: attempted, child: Container(color: const Color(0xFFFFC266))),
              Expanded(flex: anomalous, child: Container(color: const Color(0xFFFF8C00))),
              Expanded(flex: definite, child: Container(color: const Color(0xFFFF4D4F))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _legend(const Color(0xFFFFA500), 'Suspected: $suspected'),
            _legend(const Color(0xFFFFC266), 'Attempted: $attempted'),
            _legend(const Color(0xFFFF8C00), 'Anomalous: $anomalous'),
            _legend(const Color(0xFFFF4D4F), 'Definite: $definite'),
            Text('Total: $total', style: const TextStyle(color: Colors.white70)),
          ],
        )
      ],
    );
  }

  Widget _legend(Color c, String t) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _HList extends StatelessWidget {
  final List<MapEntry<String, int>> items;
  const _HList({required this.items});

  @override
  Widget build(BuildContext context) {
    final max = items.isEmpty ? 1 : items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(it.key),
                ),
                Expanded(
                  flex: 5,
                  child: LayoutBuilder(
                    builder: (context, c) => Stack(
                      children: [
                        Container(height: 10, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6))),
                        Container(
                          height: 10,
                          width: (c.maxWidth * (it.value / max)).clamp(0.0, c.maxWidth).toDouble(),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(6)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(width: 48, child: Text('${it.value}', textAlign: TextAlign.end, style: const TextStyle(color: Colors.white70))),
              ],
            ),
          ),
      ],
    );
  }
}
