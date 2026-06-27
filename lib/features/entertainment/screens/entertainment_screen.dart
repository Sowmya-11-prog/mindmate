import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/bubble_pop_game.dart';

class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  final _quotes = const [
    'You don\'t have to control your thoughts. You just have to stop letting them control you.',
    'Small steps every day add up to big change.',
    'This feeling is temporary. You\'ve gotten through hard days before.',
  ];

  final _jokes = const [
    'Why did the scarecrow win an award? He was outstanding in his field.',
    'I told my therapist about my fear of the metric system. She said not to worry, it\'s just a phase.',
    'Why don\'t skeletons fight each other? They don\'t have the guts.',
  ];

  int _quoteIndex = 0;
  int _jokeIndex = 0;

  void _nextQuote() => setState(() => _quoteIndex = Random().nextInt(_quotes.length));
  void _nextJoke() => setState(() => _jokeIndex = Random().nextInt(_jokes.length));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.format_quote, size: 32),
                  const SizedBox(height: 8),
                  Text(_quotes[_quoteIndex], textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _nextQuote, child: const Text('Another one')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.emoji_emotions_outlined, size: 32),
                  const SizedBox(height: 8),
                  Text(_jokes[_jokeIndex], textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _nextJoke, child: const Text('Tell another')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Mini relaxing game', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const BubblePopGame(),
        ],
      ),
    );
  }
}