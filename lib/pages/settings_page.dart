import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Enable real-time alerts'),
                  subtitle: const Text('Push notifications for critical incidents'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: false,
                  onChanged: (_) {},
                  title: const Text('Auto-escalation'),
                  subtitle: const Text('Escalate P1 incidents to on-call'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Retention (days)'),
                  subtitle: const Text('Log retention policy'),
                  trailing: SizedBox(
                    width: 80,
                    child: TextFormField(
                      initialValue: '30',
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
