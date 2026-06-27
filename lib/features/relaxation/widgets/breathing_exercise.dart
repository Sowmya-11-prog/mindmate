import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A simple guided breathing circle: inhale (expand) / hold / exhale (shrink).
/// Swap the timings or add haptic feedback later for a more polished feel.
class BreathingExercise extends StatefulWidget {
  const BreathingExercise({super.key});

  @override
  State<BreathingExercise> createState() => _BreathingExerciseState();
}

class _BreathingExerciseState extends State<BreathingExercise>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  String _phase = 'Inhale';

  static const _inhale = Duration(seconds: 4);
  static const _hold = Duration(seconds: 4);
  static const _exhale = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _inhale)
      ..addStatusListener(_onStatusChanged)
      ..forward();
  }

  void _onStatusChanged(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      setState(() => _phase = 'Hold');
      await Future.delayed(_hold);
      if (!mounted) return;
      setState(() => _phase = 'Exhale');
      _controller.duration = _exhale;
      _controller.reverse();
    } else if (status == AnimationStatus.dismissed) {
      setState(() => _phase = 'Inhale');
      _controller.duration = _inhale;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 0.6 + (_controller.value * 0.6);
            return Container(
              width: 220 * scale,
              height: 220 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(_phase, style: Theme.of(context).textTheme.titleLarge),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Follow the circle. Breathe naturally — there\'s no rush.'),
      ],
    );
  }
}
