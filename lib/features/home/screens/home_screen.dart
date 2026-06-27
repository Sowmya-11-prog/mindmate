import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../mood_tracker/screens/mood_tracker_screen.dart';
import '../../relaxation/screens/relaxation_screen.dart';
import '../../journal/screens/journal_screen.dart';
import '../../journal/providers/journal_provider.dart';
import '../../entertainment/screens/entertainment_screen.dart';
import '../../insights/screens/insights_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  final _screens = const [
    MoodTrackerScreen(),
    RelaxationScreen(),
    JournalScreen(),
    EntertainmentScreen(),
    InsightsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(journalControllerProvider).seedIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _index != 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _index = 0),
              )
            : null,
        title: const Text('MindMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & Support',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mood), label: 'Mood'),
          NavigationDestination(icon: Icon(Icons.self_improvement), label: 'Relax'),
          NavigationDestination(icon: Icon(Icons.book_outlined), label: 'Journal'),
          NavigationDestination(icon: Icon(Icons.celebration_outlined), label: 'Lift'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}