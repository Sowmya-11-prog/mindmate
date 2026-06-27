import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/theme/app_theme.dart';

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _Bubble {
  final String id;
  double x;
  double y;
  final double size;
  final Color color;

  _Bubble({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

class _BubblePopGameState extends State<BubblePopGame>
    with SingleTickerProviderStateMixin {
  final List<_Bubble> _bubbles = [];
  final Random _rng = Random();
  late final Ticker _ticker;
  int _popped = 0;

  final _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_bubbles.length < 8) _spawnBubble();
    });
  }

  void _spawnBubble() {
    setState(() {
      _bubbles.add(_Bubble(
        id: UniqueKey().toString(),
        x: _rng.nextDouble(),
        y: 1.0,
        size: 36 + _rng.nextDouble() * 28,
        color: _colors[_rng.nextInt(_colors.length)],
      ));
    });
  }

  void _onTick(Duration elapsed) {
    setState(() {
      for (final b in _bubbles) {
        b.y -= 0.0035;
      }
      _bubbles.removeWhere((b) => b.y < -0.1);
    });
  }

  void _pop(_Bubble bubble) {
    setState(() {
      _bubbles.remove(bubble);
      _popped++;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text('Popped: $_popped',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(height: 8),
        Container(
          height: 360,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _bubbles.map((b) {
                  return Positioned(
                    left: b.x * (constraints.maxWidth - b.size),
                    top: b.y * (constraints.maxHeight - b.size),
                    child: GestureDetector(
                      onTap: () => _pop(b),
                      child: Container(
                        width: b.size,
                        height: b.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: b.color.withValues(alpha: 0.6),
                          boxShadow: [
                            BoxShadow(
                              color: b.color.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text(
            'Tap the bubbles as they float up. No score to chase — just pop.'),
      ],
    );
  }
}