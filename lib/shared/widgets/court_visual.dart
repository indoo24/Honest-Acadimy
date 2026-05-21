import 'package:flutter/material.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class CourtVisual extends StatelessWidget {
  const CourtVisual({super.key, required this.surface, this.borderRadius});

  final CourtSurface surface;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CustomPaint(
        painter: _CourtPainter(surface: surface),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: surface == CourtSurface.glassBack
                  ? const [AppColors.deepTeal, AppColors.squashGreen]
                  : const [AppColors.clubNavy, AppColors.rallyOrange],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtPainter extends CustomPainter {
  const _CourtPainter({required this.surface});

  final CourtSurface surface;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: .34)
      ..strokeWidth = 2;
    final floorPaint = Paint()
      ..color = Colors.white.withValues(
        alpha: surface == CourtSurface.glassBack ? .11 : .08,
      );
    final courtRect = Rect.fromLTWH(
      size.width * .1,
      size.height * .18,
      size.width * .8,
      size.height * .68,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(courtRect, const Radius.circular(8)),
      floorPaint,
    );
    canvas.drawLine(courtRect.topLeft, courtRect.topRight, linePaint);
    canvas.drawLine(courtRect.centerLeft, courtRect.centerRight, linePaint);
    canvas.drawLine(
      Offset(courtRect.left + courtRect.width * .5, courtRect.center.dy),
      Offset(courtRect.left + courtRect.width * .5, courtRect.bottom),
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .3),
      size.shortestSide * .045,
      Paint()..color = AppColors.courtGold,
    );
  }

  @override
  bool shouldRepaint(covariant _CourtPainter oldDelegate) =>
      oldDelegate.surface != surface;
}
