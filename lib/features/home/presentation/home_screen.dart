import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.appDatabase, super.key});

  final AppDatabase appDatabase;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Welcome back, Alex Miller',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('How are you feeling today?', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MoodChip(label: 'Happy', icon: Icons.sentiment_very_satisfied),
                _MoodChip(label: 'Angry', icon: Icons.sentiment_very_dissatisfied),
                _MoodChip(label: 'Sleepy', icon: Icons.bedtime_outlined),
                _MoodChip(label: 'Bored', icon: Icons.sentiment_neutral),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('2h 15m Active Caregiving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.tonal(onPressed: () {}, child: const Text('Pause')),
                        const SizedBox(width: 8),
                        FilledButton(onPressed: () {}, child: const Text('Stop')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Sleep Duration',
                    value: '6h 45m avg',
                    chart: '▁▃▄▆▅▇▆',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    title: 'Stress Indicator',
                    value: 'High',
                    chart: '●',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Mood Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 7,
              childAspectRatio: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                28,
                (index) {
                  const moods = ['🙂', '😴', '😠', '😐'];
                  return Card(
                    margin: const EdgeInsets.all(2),
                    child: Center(child: Text(moods[index % moods.length])),
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

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(child: Icon(icon)),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.chart});

  final String title;
  final String value;
  final String chart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(chart, style: const TextStyle(letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}
