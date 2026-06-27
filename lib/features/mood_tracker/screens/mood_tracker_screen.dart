import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/mood_provider.dart';

// Emoji + gradient per emotion
const _emotionMeta = {
  'Happy':   {'emoji': '😊', 'color': Color(0xFFFFF176)},
  'Calm':    {'emoji': '😌', 'color': Color(0xFFA8D5BA)},
  'Anxious': {'emoji': '😰', 'color': Color(0xFFFFCC80)},
  'Stressed':{'emoji': '😤', 'color': Color(0xFFEF9A9A)},
  'Sad':     {'emoji': '😢', 'color': Color(0xFF90CAF9)},
  'Angry':   {'emoji': '😠', 'color': Color(0xFFEF5350)},
  'Tired':   {'emoji': '😴', 'color': Color(0xFFCE93D8)},
  'Excited': {'emoji': '🤩', 'color': Color(0xFFFFAB40)},
};

const _intensityLabels = ['', 'Very mild', 'Mild', 'Moderate', 'Strong', 'Intense'];

class MoodTrackerScreen extends ConsumerStatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  ConsumerState<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends ConsumerState<MoodTrackerScreen> {
  String? _selectedEmotion;
  double _intensity = 3;
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_selectedEmotion == null) return;
    setState(() => _saving = true);
    await ref.read(moodControllerProvider).logMood(
          emotion: _selectedEmotion!,
          intensity: _intensity.round(),
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );
    if (mounted) {
      setState(() {
        _saving = false;
        _selectedEmotion = null;
        _intensity = 3;
        _noteCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Mood logged. Thanks for checking in 🌿'),
          ]),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodHistory = ref.watch(moodHistoryProvider);
    final selectedColor = _selectedEmotion != null
        ? (_emotionMeta[_selectedEmotion]!['color'] as Color)
        : AppColors.primary;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Header gradient card
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [selectedColor.withValues(alpha: 0.8), selectedColor.withValues(alpha: 0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How are you feeling?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                // Emotion grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: AppConstants.emotions.map((emotion) {
                    final meta = _emotionMeta[emotion]!;
                    final selected = emotion == _selectedEmotion;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmotion = emotion),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(meta['emoji'] as String, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 4),
                            Text(
                              emotion,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Intensity + note + save
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedEmotion != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Intensity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: selectedColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _intensityLabels[_intensity.round()],
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _intensity,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: selectedColor,
                    label: _intensityLabels[_intensity.round()],
                    onChanged: (v) => setState(() => _intensity = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind? (optional)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Log Mood', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Text('Recent check-ins', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                moodHistory.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            const Text('🌱', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text('No check-ins yet — tap an emotion above!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: entries.take(10).map((e) {
                        final meta = _emotionMeta[e.emotion] ?? {'emoji': '🙂', 'color': AppColors.primary};
                        final color = meta['color'] as Color;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.3),
                              child: Text(meta['emoji'] as String, style: const TextStyle(fontSize: 20)),
                            ),
                            title: Text(e.emotion, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: e.note != null ? Text(e.note!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('MMM d').format(e.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${e.intensity}/5',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Could not load history: $e'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }
}