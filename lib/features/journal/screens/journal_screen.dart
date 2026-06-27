import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  void _showNewEntrySheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'What\'s on your mind?'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (contentCtrl.text.trim().isEmpty) return;
                await ref.read(journalControllerProvider).addEntry(
                      title: titleCtrl.text.trim().isEmpty
                          ? 'Untitled'
                          : titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewEntrySheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: entries.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Your journal is empty. Tap + to write.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final entry = list[i];
              return Card(
                child: ListTile(
                  title: Text(entry.title),
                  subtitle: Text(
                    entry.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        ref.read(journalControllerProvider).deleteEntry(entry.id),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load journal: $e')),
      ),
    );
  }
}
