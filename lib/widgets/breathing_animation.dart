import 'package:flutter/material.dart';

class BreathingAnimation extends StatefulWidget {
  final String phase; // "inhale", "hold", "exhale"
  final double minSize;
  final double maxSize;
  final Duration duration;

  const BreathingAnimation({
    super.key,
    required this.phase,
    this.minSize = 150.0,
    this.maxSize = 250.0,
    required this.duration,
  });

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _updateAnimation();

    if (widget.phase == "hold") {
      _controller.value = 1.0; // Stay at maximum size during hold
    } else {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BreathingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase) {
      _updateAnimation();
      _controller.reset();

      if (widget.phase == "hold") {
        _controller.value = 1.0; // Stay at maximum size during hold
      } else {
        _controller.forward();
      }
    }
  }

  void _updateAnimation() {
    // For inhale, grow from min to max
    // For exhale, shrink from max to min
    // For hold, stay at max size
    if (widget.phase == "inhale") {
      _animation = Tween<double>(
        begin: widget.minSize,
        end: widget.maxSize,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    } else if (widget.phase == "exhale") {
      _animation = Tween<double>(
        begin: widget.maxSize,
        end: widget.minSize,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    } else {
      // Hold phase
      _animation = Tween<double>(
        begin: widget.maxSize,
        end: widget.maxSize,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 3,
            ),
          ),
        );
      },
    );
  }
}
