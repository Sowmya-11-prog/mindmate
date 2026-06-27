import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../mood_tracker/providers/mood_provider.dart';

const _emotionColors = {
  'Happy':    Color(0xFFFFF176),
  'Calm':     Color(0xFFA8D5BA),
  'Anxious':  Color(0xFFFFCC80),
  'Stressed': Color(0xFFEF9A9A),
  'Sad':      Color(0xFF90CAF9),
  'Angry':    Color(0xFFEF5350),
  'Tired':    Color(0xFFCE93D8),
  'Excited':  Color(0xFFFFAB40),
};

const _emotionEmojis = {
  'Happy': '😊', 'Calm': '😌', 'Anxious': '😰', 'Stressed': '😤',
  'Sad': '😢', 'Angry': '😠', 'Tired': '😴', 'Excited': '🤩',
};

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = ref.watch(moodHistoryProvider);

    return Scaffold(
      body: moods.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text('Log a few moods to see your insights here.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          // --- compute stats ---
          final recent = entries.reversed.toList();
          final spots = <FlSpot>[
            for (int i = 0; i < recent.length; i++)
              FlSpot(i.toDouble(), recent[i].intensity.toDouble()),
          ];

          // emotion frequency
          final freq = <String, int>{};
          for (final e in entries) {
            freq[e.emotion] = (freq[e.emotion] ?? 0) + 1;
          }
          final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final topEmotion = sorted.first.key;
          final avgIntensity = entries.map((e) => e.intensity).reduce((a, b) => a + b) / entries.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary cards row
              Row(
                children: [
                  _SummaryCard(
                    emoji: '📝',
                    label: 'Check-ins',
                    value: '${entries.length}',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    emoji: _emotionEmojis[topEmotion] ?? '🙂',
                    label: 'Most felt',
                    value: topEmotion,
                    color: _emotionColors[topEmotion] ?? AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  _SummaryCard(
                    emoji: '⚡',
                    label: 'Avg intensity',
                    value: avgIntensity.toStringAsFixed(1),
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Line chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mood intensity over time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Last ${entries.length} check-ins',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 5,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
                              color: Colors.grey.withValues(alpha: 0.15),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) => Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, bar, index) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emotion breakdown
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emotion breakdown',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    ...sorted.map((entry) {
                      final pct = entry.value / entries.length;
                      final color = _emotionColors[entry.key] ?? AppColors.primary;
                      final emoji = _emotionEmojis[entry.key] ?? '🙂';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text('${entry.value}x · ${(pct * 100).round()}%',
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 8,
                                      backgroundColor: color.withValues(alpha: 0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent entries timeline
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent timeline',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...entries.take(5).map((e) {
                      final color = _emotionColors[e.emotion] ?? AppColors.primary;
                      final emoji = _emotionEmojis[e.emotion] ?? '🙂';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: color.withValues(alpha: 0.25),
                              child: Text(emoji, style: const TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.emotion, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(DateFormat('MMM d • h:mm a').format(e.createdAt),
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${e.intensity}/5',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load insights: $e')),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}