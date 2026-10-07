import 'package:flutter/material.dart';

class PhysicalSupportScreen extends StatelessWidget {
  const PhysicalSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      'In-home Care Services',
      'Respite Centers',
      'Medical Supply Stores',
      'Physical Therapy',
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBar(
              leading: const Icon(Icons.search),
              hintText: 'Search services',
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(label: 'All Services', selected: true),
                  _CategoryChip(label: 'In-Home Care'),
                  _CategoryChip(label: 'Medical Supply'),
                  _CategoryChip(label: 'Therapy'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: services.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final title = services[index];
                  return Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: const Text('Nearby and available today'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.location_on_outlined)),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.map_outlined)),
                        ],
                      ),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {},
      ),
    );
  }
}
