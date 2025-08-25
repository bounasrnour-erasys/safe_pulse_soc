import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // General
  String _timezone = 'UTC';

  // Alerting & Escalation
  bool _realtimeAlerts = true;
  bool _autoEscalation = false;
  final _onCallEmailCtrl = TextEditingController(text: 'oncall@safepulse.local');
  final _p1SlaCtrl = TextEditingController(text: '15');
  final _p2SlaCtrl = TextEditingController(text: '60');

  // Detection & Risk
  double _anomalySensitivity = 0.6; // 0..1
  final _alertsPerUserHourCtrl = TextEditingController(text: '50');

  // Integrations
  bool _emailNotifs = true;
  bool _slackNotifs = false;
  bool _webhookEnabled = false;
  final _slackWebhookCtrl = TextEditingController();
  final _webhookUrlCtrl = TextEditingController();

  // Data Management
  final _retentionDaysCtrl = TextEditingController(text: '30');
  bool _anonymizePII = true;

  // Security
  bool _mfaRequired = true;

  @override
  void dispose() {
    _onCallEmailCtrl.dispose();
    _p1SlaCtrl.dispose();
    _p2SlaCtrl.dispose();
    _alertsPerUserHourCtrl.dispose();
    _slackWebhookCtrl.dispose();
    _webhookUrlCtrl.dispose();
    _retentionDaysCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved (local only). Wire to backend to persist.')),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          // General
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('General', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _timezone,
                    decoration: const InputDecoration(labelText: 'Timezone'),
                    items: const [
                      DropdownMenuItem(value: 'UTC', child: Text('UTC')),
                      DropdownMenuItem(value: 'Europe/Paris', child: Text('Europe/Paris')),
                      DropdownMenuItem(value: 'Africa/Tunis', child: Text('Africa/Tunis')),
                      DropdownMenuItem(value: 'America/Los_Angeles', child: Text('America/Los_Angeles')),
                      DropdownMenuItem(value: 'Asia/Dubai', child: Text('Asia/Dubai')),
                    ],
                    onChanged: (v) => setState(() => _timezone = v ?? 'UTC'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Alerting & Escalation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alerting & Escalation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _realtimeAlerts,
                    onChanged: (v) => setState(() => _realtimeAlerts = v),
                    title: const Text('Enable real-time alerts'),
                    subtitle: const Text('Push notifications for critical incidents'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _autoEscalation,
                    onChanged: (v) => setState(() => _autoEscalation = v),
                    title: const Text('Auto-escalation'),
                    subtitle: const Text('Escalate P1 incidents to on-call'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _onCallEmailCtrl,
                    decoration: const InputDecoration(labelText: 'On-call email'),
                    validator: _required,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _p1SlaCtrl,
                          decoration: const InputDecoration(labelText: 'P1 SLA (minutes)'),
                          keyboardType: TextInputType.number,
                          validator: _positiveInt,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _p2SlaCtrl,
                          decoration: const InputDecoration(labelText: 'P2 SLA (minutes)'),
                          keyboardType: TextInputType.number,
                          validator: _positiveInt,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Detection & Risk
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detection & Risk', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Anomaly sensitivity: ${(100 * _anomalySensitivity).round()}%'),
                  Slider(
                    value: _anomalySensitivity,
                    onChanged: (v) => setState(() => _anomalySensitivity = v),
                  ),
                  TextFormField(
                    controller: _alertsPerUserHourCtrl,
                    decoration: const InputDecoration(labelText: 'Alert threshold per user per hour'),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Integrations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Integrations', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _emailNotifs,
                    onChanged: (v) => setState(() => _emailNotifs = v),
                    title: const Text('Email notifications'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    value: _slackNotifs,
                    onChanged: (v) => setState(() => _slackNotifs = v),
                    title: const Text('Slack notifications'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  TextFormField(
                    controller: _slackWebhookCtrl,
                    enabled: _slackNotifs,
                    decoration: const InputDecoration(labelText: 'Slack webhook URL'),
                    validator: (v) => _slackNotifs ? _required(v) : null,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _webhookEnabled,
                    onChanged: (v) => setState(() => _webhookEnabled = v),
                    title: const Text('Generic webhook'),
                    subtitle: const Text('POST incidents to your endpoint'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  TextFormField(
                    controller: _webhookUrlCtrl,
                    enabled: _webhookEnabled,
                    decoration: const InputDecoration(labelText: 'Webhook URL'),
                    validator: (v) => _webhookEnabled ? _required(v) : null,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Data management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data management', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _retentionDaysCtrl,
                    decoration: const InputDecoration(labelText: 'Retention (days)'),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _anonymizePII,
                    onChanged: (v) => setState(() => _anonymizePII = v),
                    title: const Text('Anonymize PII in logs'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export not implemented'))),
                      icon: const Icon(Icons.download),
                      label: const Text('Export settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Security
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _mfaRequired,
                    onChanged: (v) => setState(() => _mfaRequired = v),
                    title: const Text('Require MFA for sensitive actions'),
                    subtitle: const Text('E.g., deleting data, modifying integrations'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save changes'),
            ),
          ),
        ],
      ),
    );
  }
}
