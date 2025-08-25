import 'package:flutter/material.dart';
import 'user_detail_page.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(12, (i) => 'analyst_$i@safepulse.local');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final email = items[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(email),
                  subtitle: const Text('Role: Analyst • Status: Active'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserDetailPage(email: email),
                      ),
                    );
                  },
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
