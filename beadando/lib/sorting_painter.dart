import 'dart:math';
import 'package:flutter/material.dart';
import 'sort_provider.dart';

class SortingPainter extends CustomPainter {
  final AlgoInstance inst;
  final VisualType type;
  final Color baseColor;

  SortingPainter(this.inst, this.type, this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final int n = inst.data.length;
    if (n == 0) return;
    
    final double barW = w / n;
    const int maxVal = 350;

    for (int i = 0; i < n; i++) {
      final Paint p = Paint()..style = PaintingStyle.fill;

      // Színkezelés állapot alapján
      if (i == inst.active1 || i == inst.active2) {
        p.color = Colors.redAccent;
      } else if (inst.isComplete) {
        p.color = Colors.greenAccent;
      } else {
        p.color = baseColor.withOpacity(0.7);
      }

      if (type == VisualType.bars) {
        double barH = (inst.data[i] / maxVal) * h;
        canvas.drawRect(Rect.fromLTWH(i * barW, h - barH, barW - 1, barH), p);
      } else if (type == VisualType.dots) {
        double dy = h - (inst.data[i] / maxVal) * h;
        canvas.drawCircle(Offset(i * barW + barW / 2, dy), 3, p);
      } else if (type == VisualType.circle) {
        double angle = (2 * pi / n) * i;
        double radius = (inst.data[i] / maxVal) * (min(w, h) / 2);
        Offset center = Offset(w / 2, h / 2);
        Offset end = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
        p.strokeWidth = 2;
        canvas.drawLine(center, end, p);
      }
    }
  }

  @override
  bool shouldRepaint(SortingPainter old) => true;
}