import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../../mood_tracker/providers/mood_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../../core/theme/app_theme.dart';

int _computeStreak(List<DateTime> dates) {
  if (dates.isEmpty) return 0;
  final days = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
    ..sort((a, b) => b.compareTo(a));

  var streak = 0;
  var cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);

  for (final day in days) {
    final diff = cursor.difference(day).inDays;
    if (diff == 0 || diff == 1) {
      streak++;
      cursor = day;
    } else {
      break;
    }
  }
  return streak;
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editing = false;
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  Future<void> _saveName() async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null || _nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await user.updateDisplayName(_nameCtrl.text.trim());
    await ref.read(firebaseServiceProvider).createUserProfile(
      user.uid,
      {'displayName': _nameCtrl.text.trim()},
    );
    if (mounted) setState(() {
      _saving = false;
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).asData?.value;
    final moods = ref.watch(moodHistoryProvider);
    final journalEntries = ref.watch(journalEntriesProvider);

    final initials = (user?.displayName?.isNotEmpty == true
            ? user!.displayName![0]
            : user?.email?[0] ?? '?')
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: _editing
                ? SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _nameCtrl,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: 'Your name'),
                      autofocus: true,
                    ),
                  )
                : Text(
                    user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Add your name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: _saving
                  ? null
                  : () {
                      if (_editing) {
                        _saveName();
                      } else {
                        _nameCtrl.text = user?.displayName ?? '';
                        setState(() => _editing = true);
                      }
                    },
              icon: Icon(_editing ? Icons.check : Icons.edit_outlined, size: 18),
              label: Text(_editing ? 'Save' : 'Edit name'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          if (user?.metadata.creationTime != null)
            Center(
              child: Text(
                'Joined ${DateFormat('MMM yyyy').format(user!.metadata.creationTime!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: moods.when(
                  data: (entries) => _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Day streak',
                    value: '${_computeStreak(entries.map((e) => e.createdAt).toList())}',
                  ),
                  loading: () => const _StatCard(icon: Icons.local_fire_department, label: 'Day streak', value: '–'),
                  error: (_, __) => const _StatCard(icon: Icons.local_fire_department, label: 'Day streak', value: '–'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: moods.when(
                  data: (entries) => _StatCard(
                    icon: Icons.mood,
                    label: 'Check-ins',
                    value: '${entries.length}',
                  ),
                  loading: () => const _StatCard(icon: Icons.mood, label: 'Check-ins', value: '–'),
                  error: (_, __) => const _StatCard(icon: Icons.mood, label: 'Check-ins', value: '–'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: journalEntries.when(
                  data: (entries) => _StatCard(
                    icon: Icons.book_outlined,
                    label: 'Journal entries',
                    value: '${entries.length}',
                  ),
                  loading: () => const _StatCard(icon: Icons.book_outlined, label: 'Journal entries', value: '–'),
                  error: (_, __) => const _StatCard(icon: Icons.book_outlined, label: 'Journal entries', value: '–'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}