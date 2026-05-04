import 'package:flutter/material.dart';

class RingWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const RingWidget({
    Key? key,
    this.size = 100.0,
    this.strokeWidth = 10.0,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RingPainter(strokeWidth: strokeWidth, color: color),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  RingPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final double radius = (size.width - strokeWidth) / 2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

