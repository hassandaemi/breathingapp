import 'package:flutter/material.dart';
import '../providers/app_state.dart'; // To access BreathingTechnique
import '../theme/app_theme.dart'; // For colors

class CustomBreathingAnimation extends StatelessWidget {
  final AnimationController controller;
  final BreathingTechnique technique;
  final String currentPhaseKey;
  final bool isCompleted;

  const CustomBreathingAnimation({
    super.key,
    required this.controller,
    required this.technique,
    required this.currentPhaseKey,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Determine animation type based on technique
    // Default to circle if not Box Breathing
    bool useSquare = technique.name == "Box Breathing";

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = controller.value; // 0.0 to 1.0
        Color progressColor = const Color(0xFF4682B4); // Default progress color

        // Determine visual progress based on phase (e.g., holds stay static)
        if (currentPhaseKey.contains('hold')) {
          // Hold after inhale: stay expanded (progress 1.0)
          // Hold after exhale (Box): stay contracted (progress 0.0)
          if (currentPhaseKey == 'hold1' || currentPhaseKey == 'hold') {
            // Assuming hold1 is after inhale
            progress = 1.0;
          } else if (currentPhaseKey == 'hold2') {
            // Assuming hold2 is after exhale (Box)
            progress = 0.0;
          }
        }
        if (isCompleted) {
          progress = 1.0; // Show completed state (full)
          progressColor = Colors.green; // Change color on completion
        }
        if (currentPhaseKey == "get_ready") {
          progress = 0.0; // Start contracted
        }

        return SizedBox(
          width: 250,
          height: 250,
          child: CustomPaint(
            painter: useSquare
                ? SquarePainter(
                    progress: progress,
                    color: progressColor,
                    isCompleted: isCompleted)
                : CirclePainter(
                    progress: progress,
                    color: progressColor,
                    isCompleted: isCompleted),
          ),
        );
      },
    );
  }
}

// --- Circle Painter --- (For most techniques)
class CirclePainter extends CustomPainter {
  final double progress; // 0.0 (contracted) to 1.0 (expanded)
  final Color color;
  final bool isCompleted;

  CirclePainter(
      {required this.progress, required this.color, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final minRadius = maxRadius * 0.6; // Example minimum size
    final currentRadius = minRadius + (maxRadius - minRadius) * progress;

    // Background (optional, can be handled by container)
    final backgroundPaint = Paint()
      ..color = AppTheme.primaryColor.withAlpha((0.1 * 255).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, backgroundPaint);

    // Animated Circle
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius, foregroundPaint);

    // Checkmark on completion
    if (isCompleted) {
      _drawCheckmark(canvas, center, maxRadius * 0.5);
    }
  }

  @override
  bool shouldRepaint(covariant CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isCompleted != isCompleted;
  }
}

// --- Square Painter --- (For Box Breathing)
class SquarePainter extends CustomPainter {
  final double progress; // 0.0 (contracted) to 1.0 (expanded)
  final Color color;
  final bool isCompleted;

  SquarePainter(
      {required this.progress, required this.color, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxSize = size.width;
    final minSize = maxSize * 0.6;
    final currentSize = minSize + (maxSize - minSize) * progress;
    final halfSize = currentSize / 2;

    final rect = Rect.fromCenter(
        center: center, width: currentSize, height: currentSize);
    final borderRadius =
        BorderRadius.circular(currentSize * 0.1); // Rounded corners
    final rrect = borderRadius.toRRect(rect);

    // Background (optional)
    final backgroundPaint = Paint()
      ..color = AppTheme.primaryColor.withAlpha((0.1 * 255).toInt())
      ..style = PaintingStyle.fill;
    final backgroundRRect = BorderRadius.circular(maxSize * 0.1).toRRect(
        Rect.fromCenter(center: center, width: maxSize, height: maxSize));
    canvas.drawRRect(backgroundRRect, backgroundPaint);

    // Animated Square
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, foregroundPaint);

    // Checkmark on completion
    if (isCompleted) {
      _drawCheckmark(canvas, center, halfSize * 0.8);
    }
  }

  @override
  bool shouldRepaint(covariant SquarePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isCompleted != isCompleted;
  }
}

// Helper function to draw checkmark
void _drawCheckmark(Canvas canvas, Offset center, double size) {
  final paint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = size * 0.15 // Adjust thickness relative to size
    ..strokeCap = StrokeCap.round;

  final path = Path();
  // Define checkmark points relative to center and size
  path.moveTo(center.dx - size * 0.4, center.dy + size * 0.0);
  path.lineTo(center.dx - size * 0.1, center.dy + size * 0.3);
  path.lineTo(center.dx + size * 0.4, center.dy - size * 0.3);

  canvas.drawPath(path, paint);
}
