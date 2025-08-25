import 'package:flutter/material.dart';
import 'user_detail_page.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = List.generate(12, (i) => 'analyst_$i@safepulse.local');
    final items = all
        .where((e) => e.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Users', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search users by email or name',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                itemCount: items.length,
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
          ),
        ],
      ),
    );
  }
}
