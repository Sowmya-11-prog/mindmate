import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/breathing_exercise.dart';

class RelaxationScreen extends StatefulWidget {
  const RelaxationScreen({super.key});

  @override
  State<RelaxationScreen> createState() => _RelaxationScreenState();
}

class _RelaxationScreenState extends State<RelaxationScreen> {
  final AudioPlayer _player = AudioPlayer();
  String? _playingTrack;

  // Add your own royalty-free ambient tracks under assets/sounds/
  // and list them in pubspec.yaml's assets section.
final List<Map<String, String>> _tracks = const [
  {'name': 'Rain', 'asset': 'assets/sounds/rain.mp3'},
  {'name': 'Ocean Waves', 'asset': 'assets/sounds/ocean.mp3'},
  {'name': 'Forest Ambience', 'asset': 'assets/sounds/forest.mp3'},
];

  Future<void> _toggleTrack(String asset) async {
    if (_playingTrack == asset) {
      await _player.stop();
      setState(() => _playingTrack = null);
    } else {
      await _player.setAsset(asset);
      await _player.setLoopMode(LoopMode.one);
      _player.play();
      setState(() => _playingTrack = asset);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relax')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Guided breathing', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Center(child: BreathingExercise()),
          const SizedBox(height: 32),
          Text('Calming sounds', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ..._tracks.map((track) {
            final isPlaying = _playingTrack == track['asset'];
            return Card(
              child: ListTile(
                leading: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                title: Text(track['name']!),
                onTap: () => _toggleTrack(track['asset']!),
              ),
            );
          }),
        ],
      ),
    );
  }
}
