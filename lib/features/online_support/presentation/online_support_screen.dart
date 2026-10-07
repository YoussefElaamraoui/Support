import 'package:flutter/material.dart';

class OnlineSupportScreen extends StatelessWidget {
  const OnlineSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resources = [
      'Telehealth Services',
      'Caregiver Forums',
      'Educational Webinars',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Access digital resources from anywhere.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: resources.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(resources[index]),
                      subtitle: const Text('Tap to open resource'),
                      trailing: const Icon(Icons.open_in_new_outlined),
                      onTap: () {},
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
