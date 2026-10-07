import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const settings = [
      'Account Details',
      'Notification Preferences',
      'Privacy Settings',
      'Help & Support',
      'Log Out',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 8),
            const Text('Alex Miller', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Lead Caregiver'),
            const SizedBox(height: 6),
            Chip(
              avatar: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary),
              label: const Text('ID Verified'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: settings.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(settings[index]),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
