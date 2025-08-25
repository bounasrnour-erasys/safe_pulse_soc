import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
        } else if (width >= 650) {
          columns = 2;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Security Operations Center', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_alert),
                    label: const Text('New Alert'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _InfoTile(title: 'Incidents (24h)', value: '37', icon: Icons.shield_moon, color: Color(0xFF00D1FF)),
                  _InfoTile(title: 'Active Alerts', value: '12', icon: Icons.warning_amber_rounded, color: Color(0xFFFFA500)),
                  _InfoTile(title: 'Systems Monitored', value: '128', icon: Icons.devices_other, color: Color(0xFF7C4DFF)),
                  _InfoTile(title: 'Uptime', value: '99.98%', icon: Icons.trending_up, color: Color(0xFF22C55E)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _ChartCard(
                      title: 'Alerts by Severity',
                      child: _BarPlaceholder(colors: [
                        const Color(0xFFFF4D4F),
                        const Color(0xFFFFA500),
                        const Color(0xFF22C55E),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _ChartCard(
                      title: 'Top Sources',
                      child: _ListPlaceholder(items: const [
                        MapEntry('Firewall', '37'),
                        MapEntry('Endpoint', '22'),
                        MapEntry('Cloud WAF', '14'),
                        MapEntry('SIEM', '9'),
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoTile({required this.title, required this.value, required this.icon, required this.color});

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
                  Text(title, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
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

class _BarPlaceholder extends StatelessWidget {
  final List<Color> colors;
  const _BarPlaceholder({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(12, (i) {
          final color = colors[i % colors.length];
          final height = 40.0 + (i * 12) % 140;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                height: height,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
              ),
            ),
          );
        }),
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
        for (final e in items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.fiber_manual_record, size: 12, color: Colors.white54),
            title: Text(e.key),
            trailing: Text(e.value, style: const TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }
}
