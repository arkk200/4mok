import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/painters/board_painter.dart';
import 'package:frontend/painters/circle_painter.dart';

class Board extends StatefulWidget {
  final Function(int) setPos;
  final Function() initProperty;
  final int? setMokPosY;

  const Board({
    super.key,
    required this.setPos,
    required this.setMokPosY,
    required this.initProperty,
  });

  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  bool placed = false;
  Color curColor = Colors.yellow;
  List<List<Color>> colorBoard = [for (var _ in Iterable.generate(7)) []];
  final int radius = 26, gap = 53, top = 43, left = 61;

  void handlePlaceMok() {
    debugPrint("handle place mok");
    setState(() {
      placed = true;
    });
    Timer(
      Duration(
        milliseconds: 500 - colorBoard[widget.setMokPosY!].length * 100,
      ),
      () {
        setState(() {
          placed = false;
          colorBoard[widget.setMokPosY!].add(curColor);
          widget.initProperty();
          curColor = curColor == Colors.yellow ? Colors.orange : Colors.yellow;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < 7; i++)
          for (int j = 0; colorBoard[i].length > j; j++)
            Positioned(
              top: top - radius.toDouble() + (5 - j) * gap,
              left: left - radius.toDouble() + i * gap,
              child: Container(
                width: radius.toDouble() * 2,
                height: radius.toDouble() * 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.toDouble()),
                  color: colorBoard[i][j],
                ),
              ),
            ),
        if (widget.setMokPosY != null)
          AnimatedPositioned(
            top: placed
                ? top -
                    radius.toDouble() +
                    (5 - colorBoard[widget.setMokPosY!].length) * gap
                : top - radius.toDouble(),
            left: left - radius.toDouble() + widget.setMokPosY! * gap,
            duration: Duration(
                milliseconds: placed
                    ? 500 - colorBoard[widget.setMokPosY!].length * 100
                    : 0),
            child: Container(
              width: radius.toDouble() * 2,
              height: radius.toDouble() * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius.toDouble()),
                color: curColor,
              ),
            ),
          ),
        CustomPaint(
          painter: BoardPainter(),
          size: const Size(442, 357),
        ),
        for (double i = 0; i < 6; i++)
          for (double j = 0; j < 7; j++)
            Positioned(
              top: top - radius.toDouble() + i * gap,
              left: left - radius.toDouble() + j * gap,
              child: InkWell(
                child: CustomPaint(
                  painter: CirclePainter(i, j),
                  size: Size(radius.toDouble() * 2, radius.toDouble() * 2),
                ),
                onTap: () {
                  if (placed || colorBoard[j.round()].length == 6) return;
                  widget.setPos(j.round());
                },
              ),
            ),
      ],
    );
  }
}
