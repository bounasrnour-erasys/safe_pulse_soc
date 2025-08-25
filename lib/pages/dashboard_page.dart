import 'package:flutter/material.dart';

enum _QuickRange { today, last30, custom }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _quick = _QuickRange.custom;
        _range = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 1;
        if (width >= 1300) {
          columns = 4;
        } else if (width >= 1000) {
          columns = 3;
        } else if (width >= 800) {
          columns = 2;
        }
        // Make KPI tiles reasonable height on small screens
        final double tileAspect =
            (columns >= 4) ? 3.6 : (columns == 3) ? 3.2 : (columns == 2) ? 2.6 : 3.8;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Erasys Security Operations Center (Overview)',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(width: 24),
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
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: tileAspect,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _InfoTile(
                    title: 'Suspected Breaches',
                    subtitle: 'Users with typing pattern < 90%',
                    value: '24',
                    icon: Icons.warning_amber_rounded,
                    color: Color(0xFFFFA500),
                  ),
                  _InfoTile(
                    title: 'Attempted Breaches',
                    subtitle: 'Locked users attempted MFA',
                    value: '17',
                    icon: Icons.policy_rounded,
                    color: Color(0xFFFFA500),
                  ),
                  _InfoTile(
                    title: 'Anomalous Breach',
                    subtitle: 'Window switching or IP change',
                    value: '9',
                    icon: Icons.change_circle_outlined,
                    color: Color(0xFFFFA500),
                  ),
                  _InfoTile(
                    title: 'Definite Breach',
                    subtitle: 'Locked users failed MFA',
                    value: '3',
                    icon: Icons.dangerous_rounded,
                    color: Color(0xFFFF4D4F),
                  ),
                  _InfoTile(
                    title: 'No Breach',
                    subtitle: 'Users without breach',
                    value: '842',
                    icon: Icons.verified_rounded,
                    color: Color(0xFF22C55E),
                  ),
                  _InfoTile(
                    title: 'Total Users',
                    subtitle: 'Users in organization using SafePulse',
                    value: '895',
                    icon: Icons.group_rounded,
                    color: Color(0xFF00D1FF),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (width < 900)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ChartCard(
                      title: 'Recent Incidents',
                      child: _IncidentsList(items: const [
                        MapEntry('P1 • Definite breach detected', 'Just now'),
                        MapEntry('P2 • MFA failed for locked user', '5m ago'),
                        MapEntry('P3 • Window switching detected', '28m ago'),
                        MapEntry('P2 • Typing pattern anomaly', '1h ago'),
                        MapEntry('P3 • Geo-IP variance > 300km', '2h ago'),
                        MapEntry('P4 • Device posture warning', '4h ago'),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    _ChartCard(
                      title: 'Active Alerts',
                      child: _ListPlaceholder(items: const [
                        MapEntry('P1 • Critical', '3'),
                        MapEntry('P2 • High', '7'),
                        MapEntry('P3 • Medium', '12'),
                        MapEntry('P4 • Low', '20'),
                      ]),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ChartCard(
                        title: 'Recent Incidents',
                        child: _IncidentsList(items: const [
                          MapEntry('P1 • Definite breach detected', 'Just now'),
                          MapEntry('P2 • MFA failed for locked user', '5m ago'),
                          MapEntry('P3 • Window switching detected', '28m ago'),
                          MapEntry('P2 • Typing pattern anomaly', '1h ago'),
                          MapEntry('P3 • Geo-IP variance > 300km', '2h ago'),
                          MapEntry('P4 • Device posture warning', '4h ago'),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _ChartCard(
                        title: 'Active Alerts',
                        child: _ListPlaceholder(items: const [
                          MapEntry('P1 • Critical', '3'),
                          MapEntry('P2 • High', '7'),
                          MapEntry('P3 • Medium', '12'),
                          MapEntry('P4 • Low', '20'),
                        ]),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'Quick actions',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh), label: const Text('Refresh data')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.rule), label: const Text('Open triage queue')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.person_search), label: const Text('Investigate user')),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download), label: const Text('Export summary')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ChartCard(
                title: 'System health',
                child: _StatusList(items: const [
                  MapEntry('Ingestion pipeline', true),
                  MapEntry('Authentication service', true),
                  MapEntry('Rules engine', true),
                  MapEntry('SIEM connector', false),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IncidentsList extends StatelessWidget {
  final List<MapEntry<String, String>> items;
  const _IncidentsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bolt_rounded, size: 18, color: Colors.white70),
            title: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(e.value, style: const TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }
}

class _StatusList extends StatelessWidget {
  final List<MapEntry<String, bool>> items;
  const _StatusList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final it in items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              it.value ? Icons.check_circle_rounded : Icons.error_rounded,
              color: it.value ? const Color(0xFF22C55E) : const Color(0xFFFF4D4F),
              size: 18,
            ),
            title: Text(it.key, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(
              it.value ? 'Operational' : 'Degraded',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoTile({required this.title, required this.subtitle, required this.value, required this.icon, required this.color});

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
// removed unused _BarPlaceholder (replaced by incidents/alerts lists)

class _ListPlaceholder extends StatelessWidget {
  final List<MapEntry<String, String>> items;
  const _ListPlaceholder({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fiber_manual_record, size: 12, color: Colors.white54),
            title: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(e.value, style: const TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }
}
