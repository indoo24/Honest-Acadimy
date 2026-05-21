import 'package:flutter/material.dart';
import 'package:honset_app/config/theme/app_colors.dart';
import 'package:honset_app/core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showText = true,
    this.foregroundColor,
  });

  final double size;
  final bool showText;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.squashGreen.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: CustomPaint(painter: _SquashMarkPainter()),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              Text(
                'Sports Club Booking',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SquashMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final courtPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = Colors.white.withValues(alpha: 0.85);
    final ballPaint = Paint()..color = AppColors.courtGold;
    final racketPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    final court = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .24,
        size.height * .2,
        size.width * .52,
        size.height * .6,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(court, courtPaint);
    canvas.drawLine(
      Offset(size.width * .24, size.height * .52),
      Offset(size.width * .76, size.height * .52),
      courtPaint,
    );
    canvas.drawCircle(
      Offset(size.width * .66, size.height * .34),
      size.width * .07,
      ballPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * .42, size.height * .64),
        radius: size.width * .16,
      ),
      -0.4,
      4.9,
      false,
      racketPaint,
    );
    canvas.drawLine(
      Offset(size.width * .52, size.height * .72),
      Offset(size.width * .68, size.height * .84),
      racketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
