import 'package:flutter/material.dart';

/// Renders a fixed-width numeric readout using drawn seven-segment digits,
/// matching the blocky LCD counter look (e.g. old Nokia Snake's
/// SCORE / HI-SCORE readouts) instead of relying on a system font.
class LcdDigits extends StatelessWidget {
  final int value;
  final int digitCount;
  final double digitWidth;
  final double digitHeight;
  final Color color;
  final double gap;

  const LcdDigits({
    super.key,
    required this.value,
    this.digitCount = 4,
    this.digitWidth = 22,
    this.digitHeight = 36,
    required this.color,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    final text = value.clamp(0, _maxForDigits()).toString().padLeft(
          digitCount,
          '0',
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < text.length; i++) ...[
          if (i != 0) SizedBox(width: gap),
          CustomPaint(
            size: Size(digitWidth, digitHeight),
            painter: _SevenSegmentPainter(
              digit: int.parse(text[i]),
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  int _maxForDigits() {
    var m = 1;
    for (var i = 0; i < digitCount; i++) {
      m *= 10;
    }
    return m - 1;
  }
}

/// Segment map per digit, in order: top, topLeft, topRight, middle,
/// bottomLeft, bottomRight, bottom.
const List<List<bool>> _segments = [
  [true, true, true, false, true, true, true], // 0
  [false, false, true, false, false, true, false], // 1
  [true, false, true, true, true, false, true], // 2
  [true, false, true, true, false, true, true], // 3
  [false, true, true, true, false, true, false], // 4
  [true, true, false, true, false, true, true], // 5
  [true, true, false, true, true, true, true], // 6
  [true, false, true, false, false, true, false], // 7
  [true, true, true, true, true, true, true], // 8
  [true, true, true, true, false, true, true], // 9
];

class _SevenSegmentPainter extends CustomPainter {
  final int digit;
  final Color color;

  _SevenSegmentPainter({required this.digit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final segs = _segments[digit.clamp(0, 9)];
    final thickness = size.width * 0.22;
    final paint = Paint()..color = color;

    RRect seg(Rect r) =>
        RRect.fromRectAndRadius(r, Radius.circular(thickness * 0.35));

    final w = size.width;
    final h = size.height;
    final halfH = h / 2;

    // top
    if (segs[0]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(thickness * 0.3, 0, w - thickness * 0.6, thickness)),
        paint,
      );
    }
    // topLeft
    if (segs[1]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(0, thickness * 0.3, thickness, halfH - thickness * 0.45)),
        paint,
      );
    }
    // topRight
    if (segs[2]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(
          w - thickness,
          thickness * 0.3,
          thickness,
          halfH - thickness * 0.45,
        )),
        paint,
      );
    }
    // middle
    if (segs[3]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(
          thickness * 0.3,
          halfH - thickness / 2,
          w - thickness * 0.6,
          thickness,
        )),
        paint,
      );
    }
    // bottomLeft
    if (segs[4]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(
          0,
          halfH + thickness * 0.15,
          thickness,
          halfH - thickness * 0.45,
        )),
        paint,
      );
    }
    // bottomRight
    if (segs[5]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(
          w - thickness,
          halfH + thickness * 0.15,
          thickness,
          halfH - thickness * 0.45,
        )),
        paint,
      );
    }
    // bottom
    if (segs[6]) {
      canvas.drawRRect(
        seg(Rect.fromLTWH(
          thickness * 0.3,
          h - thickness,
          w - thickness * 0.6,
          thickness,
        )),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SevenSegmentPainter oldDelegate) =>
      oldDelegate.digit != digit || oldDelegate.color != color;
}
