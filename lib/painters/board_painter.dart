import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint boardPaint = Paint()..color = const Color(0xFF3C72FF);

    Path boardPath = Path()..addRect(const Rect.fromLTRB(18, 0, 424, 351));

    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 7; j++) {
        boardPath = Path.combine(
          PathOperation.difference,
          boardPath,
          Path()
            ..addOval(
              Rect.fromCircle(
                center: Offset(
                  61 + j * 53,
                  43 + i * 53,
                ),
                radius: 23,
              ),
            )
            ..close(),
        );
      }
    }
    canvas.drawPath(boardPath, boardPaint);

    final Paint boardFramePaint = Paint()
      ..color = const Color(0xFF3364E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final Path boardFramePath = Path()
      ..addRect(const Rect.fromLTRB(20, 2, 422, 349));

    canvas.drawPath(
      boardFramePath,
      boardFramePaint,
    );

    final Paint bottomPlatePaint = Paint()..color = const Color(0xFF3364E1);

    final Path bottomPlatePath = Path()
      ..addRect(const Rect.fromLTRB(0, 341, 442, 357));

    canvas.drawPath(bottomPlatePath, bottomPlatePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
