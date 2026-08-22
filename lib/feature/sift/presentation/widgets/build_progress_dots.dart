import 'package:flutter/material.dart';
import 'package:mindly/core/theme/colors.dart';

Widget buildProgressDots({required int total, required int current}) {
  final displayCount = total > 10 ? 10 : total;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(displayCount, (index) {
      final isActive = index == (current % displayCount);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white24,
          borderRadius: BorderRadius.circular(4),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ] : null,
        ),
      );
    }),
  );
}