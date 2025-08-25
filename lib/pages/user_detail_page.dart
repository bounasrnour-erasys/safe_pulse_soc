import 'package:flutter/material.dart';

enum _QuickRange { today, last30, custom }

class UserDetailPage extends StatefulWidget {
  final String email;
  const UserDetailPage({super.key, required this.email});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
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

  // Simple deterministic sample data generator based on email hash
  Map<String, int> _sampleMetrics(String email) {
    final codeSum = email.codeUnits.fold<int>(0, (p, c) => p + c);
    final base = (codeSum % 20) + 1; // 1..20
    int suspected = (base + 3) % 25; // 0..24
    int attempted = (base + 7) % 20; // 0..19
    int anomalous = (base + 5) % 12; // 0..11
    int definite = (base + 2) % 6; // 0..5

    // Scale a bit for last30 vs today
    final mult = _quick == _QuickRange.today
        ? 1.0
        : _quick == _QuickRange.last30
            ? 3.2
            : 2.4;

    int scale(num v) => v == 0 ? 0 : (v * mult).round();

    suspected = scale(suspected);
    attempted = scale(attempted);
    anomalous = scale(anomalous);
    definite = scale(definite);

    final totalEvents = [suspected, attempted, anomalous, definite].fold<int>(0, (p, c) => p + c);
    // "No breach" for a user means periods without issues; show as a complementary figure
    final noBreach = (100 - (totalEvents % 100)).clamp(0, 9999);

    return {
      'suspected': suspected,
      'attempted': attempted,
      'anomalous': anomalous,
      'definite': definite,
      'nobreach': noBreach,
    };
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _sampleMetrics(widget.email);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Overview'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          int columns = 1;
          if (width >= 1100) {
            columns = 3;
          } else if (width >= 700) {
            columns = 2;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(widget.email.isNotEmpty ? widget.email[0].toUpperCase() : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.email, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          const Text('Role: Analyst • Status: Active', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 8,
                      children: [
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
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics grid (no Total Users here)
                GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MetricTile(
                      title: 'Suspected Breaches',
                      subtitle: 'Typing pattern < 90%',
                      value: metrics['suspected'].toString(),
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFFFA500),
                    ),
                    _MetricTile(
                      title: 'Attempted Breaches',
                      subtitle: 'Locked user attempted MFA',
                      value: metrics['attempted'].toString(),
                      icon: Icons.policy_rounded,
                      color: const Color(0xFFFFA500),
                    ),
                    _MetricTile(
                      title: 'Anomalous Breach',
                      subtitle: 'Window switching / IP change',
                      value: metrics['anomalous'].toString(),
                      icon: Icons.change_circle_outlined,
                      color: const Color(0xFFFFA500),
                    ),
                    _MetricTile(
                      title: 'Definite Breach',
                      subtitle: 'Locked user failed MFA',
                      value: metrics['definite'].toString(),
                      icon: Icons.dangerous_rounded,
                      color: const Color(0xFFFF4D4F),
                    ),
                    _MetricTile(
                      title: 'No Breach',
                      subtitle: 'Time without breach',
                      value: metrics['nobreach'].toString(),
                      icon: Icons.verified_rounded,
                      color: const Color(0xFF22C55E),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Placeholder for per-user recent activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        _ListPlaceholder(items: [
                          MapEntry('MFA attempt from new IP', 'Today 10:32'),
                          MapEntry('Typing cadence anomaly', 'Yesterday 16:09'),
                          MapEntry('Window switching detected', '2 days ago 09:54'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ListPlaceholder extends StatelessWidget {
  final List<MapEntry<String, String>> items;
  const _ListPlaceholder({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final it in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                const Icon(Icons.fiber_manual_record, size: 10, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(child: Text(it.key)),
                Text(it.value, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
      ],
    );
  }
}
