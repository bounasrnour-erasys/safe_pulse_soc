import 'package:flutter/material.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 40),
              const SizedBox(height: 12),
              const Text('Ready to log out?'),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.check), label: const Text('Confirm')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
