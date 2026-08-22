import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/colors.dart';

class SiftBgPainter extends CustomPainter {
  final double animationValue;
  SiftBgPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    final phase = animationValue * 2 * math.pi;

    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * (0.2 + 0.1 * math.sin(phase))),
      200,
      paint..color = AppColors.primary,
    );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * (0.8 + 0.1 * math.cos(phase))),
      250,
      paint..color = AppColors.secondary,
    );
  }

  @override
  bool shouldRepaint(covariant SiftBgPainter oldDelegate) => true;
}