import 'package:flutter/material.dart';
import 'dart:math';

class PercentageRing extends StatelessWidget {
  final double percentage;

  PercentageRing({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(100, 100),
          painter: BackgroundRingPainter(),
        ),
        CustomPaint(
          size: Size(100, 100),
          painter: RingPainter(percentage: percentage),
        ),
        Center(
          child: Column(
            children: [
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black, // Adjust the color as needed
                ),
              ),
              Text(
                'reps',
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.black, // Adjust the color as needed
                ),
              ),
              Text(
                'completed',
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.black, // Adjust the color as needed
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BackgroundRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 10.0;
    double radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.5) // Adjust the opacity and color as needed
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RingPainter extends CustomPainter {
  final double percentage;

  RingPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 10.0;
    double radius = min(size.width / 2, size.height / 2) - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint paint = Paint()
      ..color = _calculateColor()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  Color _calculateColor() {
    int redValue = (255 - (percentage * 255).toInt()).clamp(0, 255);
    int greenValue = (percentage * 255).toInt().clamp(0, 255);

    return Color.fromARGB(255, redValue, greenValue, 0);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
