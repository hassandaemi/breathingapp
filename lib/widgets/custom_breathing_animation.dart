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
    // Determine animation style based on the technique name and app preferences
    // For now we're using a simple approach based on technique name
    final bool useSquare = technique.name == "Box Breathing";
    final bool useLinear = technique.name == "Alternate Nostril Breathing";

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double progress = controller.value; // 0.0 to 1.0
        Color progressColor = const Color(0xFF4682B4); // Default progress color

        // Determine visual progress based on phase with improved curves
        if (currentPhaseKey == "get_ready") {
          progress = 0.0; // Start contracted
        } else if (isCompleted) {
          progress = 1.0; // Show completed state (full)
          progressColor = Colors.green; // Change color on completion
        } else if (currentPhaseKey == "inhale") {
          // Inhale: grow from 0.0 to 1.0 with ease-in curve for natural breathing
          final curve = Curves.easeIn;
          progress = curve.transform(controller.value);
        } else if (currentPhaseKey.contains("hold") ||
            currentPhaseKey == "hold1") {
          // Hold after inhale: stay expanded
          progress = 1.0;
        } else if (currentPhaseKey == "exhale") {
          // Exhale: shrink from 1.0 to 0.0 with ease-out curve for natural breathing
          final curve = Curves.easeOut;
          progress = 1.0 - curve.transform(controller.value);
        } else if (currentPhaseKey == "hold2") {
          // Hold after exhale (used in Box Breathing): stay contracted
          progress = 0.0;
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
                : (useLinear
                    ? LinearBreathingPainter(
                        progress: progress,
                        color: progressColor,
                        isCompleted: isCompleted)
                    : CirclePainter(
                        progress: progress,
                        color: progressColor,
                        isCompleted: isCompleted)),
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
    final minRadius =
        maxRadius * 0.5; // Smaller minimum size for better visual effect
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
    final minSize = maxSize * 0.5; // Smaller minimum for better visual effect
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

// --- Linear Painter --- (For Alternate Nostril Breathing)
class LinearBreathingPainter extends CustomPainter {
  final double progress; // 0.0 (contracted) to 1.0 (expanded)
  final Color color;
  final bool isCompleted;

  LinearBreathingPainter(
      {required this.progress, required this.color, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxWidth = size.width * 0.9;
    final minWidth = size.width * 0.2;
    final height = size.height * 0.3;

    // Calculate current width based on progress
    final currentWidth = minWidth + (maxWidth - minWidth) * progress;

    // Background (for reference)
    final backgroundPaint = Paint()
      ..color = AppTheme.primaryColor.withAlpha((0.1 * 255).toInt())
      ..style = PaintingStyle.fill;
    final bgRect =
        Rect.fromCenter(center: center, width: maxWidth, height: height);
    final bgRRect =
        RRect.fromRectAndRadius(bgRect, Radius.circular(height / 2));
    canvas.drawRRect(bgRRect, backgroundPaint);

    // Animated bar
    final barRect =
        Rect.fromCenter(center: center, width: currentWidth, height: height);
    final barRRect =
        RRect.fromRectAndRadius(barRect, Radius.circular(height / 2));

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(barRRect, foregroundPaint);

    // Checkmark on completion
    if (isCompleted) {
      _drawCheckmark(canvas, center, height * 0.8);
    }
  }

  @override
  bool shouldRepaint(covariant LinearBreathingPainter oldDelegate) {
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
