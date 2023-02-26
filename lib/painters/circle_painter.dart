import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final double i, j;

  CirclePainter(this.i, this.j);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint framePaint = Paint()
      ..color = const Color(0xFF3364E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(const Offset(26, 26), 24, framePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
