// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class CustomSingleBorderWidget extends StatelessWidget {
//   const CustomSingleBorderWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       height: 1,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: [
//               Colors.white.withOpacity(0.1),   // Left - very light
//               Colors.white.withOpacity(0.6),   // Left-center - medium
//               Colors.white.withOpacity(0.8),   // Center - bright
//               Colors.white.withOpacity(0.6),   // Right-center - medium
//               Colors.white.withOpacity(0.1),   // Right - very light
//             ],
//             stops: [0.0, 0.25, 0.5, 0.75, 1.0],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';

enum BorderPosition { top, bottom, left, right }

class CustomSingleBorderWidget extends StatelessWidget {
  final BorderPosition position;
  final BorderRadius? borderRadius;
  final double borderWidth;

  const CustomSingleBorderWidget({
    super.key,
    required this.position,
    this.borderRadius,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IgnorePointer(
      child: CustomPaint(
        painter: GradientBorderPainter(
          position: position,
          borderRadius: borderRadius ?? BorderRadius.zero,
          borderWidth: borderWidth,
          isDark: isDark,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class GradientBorderPainter extends CustomPainter {
  final BorderPosition position;
  final BorderRadius borderRadius;
  final double borderWidth;
  final bool isDark;

  GradientBorderPainter({
    required this.position,
    required this.borderRadius,
    required this.borderWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final gradient = isDark
        ? LinearGradient(
            colors: [
              AppColors.white.withOpacity(0.1),
              AppColors.white.withOpacity(0.6),
              AppColors.white.withOpacity(0.8),
              AppColors.white.withOpacity(0.6),
              AppColors.white.withOpacity(0.1),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          )
        : LinearGradient(
            colors: [
              AppColorsLight.splaceSecondary1.withOpacity(0.1),
              AppColorsLight.splaceSecondary1.withOpacity(0.6),
              AppColorsLight.splaceSecondary1.withOpacity(0.8),
              AppColorsLight.splaceSecondary1.withOpacity(0.6),
              AppColorsLight.splaceSecondary1.withOpacity(0.1),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          );

    final Path path = Path();
    final RRect rrect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    // Create the full rounded rectangle path
    Path fullPath = Path()..addRRect(rrect);

    switch (position) {
      case BorderPosition.top:
        paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, borderWidth));
        // Extract only the top edge with curves
        Path topPath = Path();

        // Start from left side with curve
        if (rrect.tlRadiusX > 0) {
          topPath.moveTo(rrect.left, rrect.top + rrect.tlRadiusY);
          topPath.arcToPoint(
            Offset(rrect.left + rrect.tlRadiusX, rrect.top),
            radius: Radius.circular(rrect.tlRadiusX),
          );
        } else {
          topPath.moveTo(rrect.left, rrect.top);
        }

        // Draw the straight line
        topPath.lineTo(rrect.right - rrect.trRadiusX, rrect.top);

        // Add right top corner if has radius
        if (rrect.trRadiusX > 0) {
          topPath.arcToPoint(
            Offset(rrect.right, rrect.top + rrect.trRadiusY),
            radius: Radius.circular(rrect.trRadiusX),
          );
        }
        canvas.drawPath(topPath, paint);
        break;

      case BorderPosition.bottom:
        paint.shader = gradient.createShader(Rect.fromLTWH(0, size.height - borderWidth, size.width, borderWidth));
        // Extract only the bottom edge with curves
        Path bottomPath = Path();
        bottomPath.moveTo(rrect.left, rrect.bottom - rrect.blRadiusY);
        // Add left bottom corner if has radius
        if (rrect.blRadiusX > 0) {
          bottomPath.arcToPoint(
            Offset(rrect.left + rrect.blRadiusX, rrect.bottom),
            radius: Radius.circular(rrect.blRadiusX),
          );
        }
        bottomPath.lineTo(rrect.right - rrect.brRadiusX, rrect.bottom);
        // Add right bottom corner if has radius
        if (rrect.brRadiusX > 0) {
          bottomPath.arcToPoint(
            Offset(rrect.right, rrect.bottom - rrect.brRadiusY),
            radius: Radius.circular(rrect.brRadiusX),
          );
        }
        canvas.drawPath(bottomPath, paint);
        break;

      case BorderPosition.left:
        paint.shader = gradient.createShader(Rect.fromLTWH(0, 0, borderWidth, size.height));
        Path leftPath = Path();
        leftPath.moveTo(rrect.left, rrect.top + rrect.tlRadiusY);
        leftPath.lineTo(rrect.left, rrect.bottom - rrect.blRadiusY);
        canvas.drawPath(leftPath, paint);
        break;

      case BorderPosition.right:
        paint.shader = gradient.createShader(Rect.fromLTWH(size.width - borderWidth, 0, borderWidth, size.height));
        Path rightPath = Path();
        rightPath.moveTo(rrect.right, rrect.top + rrect.trRadiusY);
        rightPath.lineTo(rrect.right, rrect.bottom - rrect.brRadiusY);
        canvas.drawPath(rightPath, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}