import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 环形 AI 额度进度仪表盘组件
class RadialGauge extends StatelessWidget {
  final double remainingPercent; // 0.0 - 100.0
  final String title;
  final String? subtitle;
  final Color? activeColor;
  final double size;

  const RadialGauge({
    super.key,
    required this.remainingPercent,
    required this.title,
    this.subtitle,
    this.activeColor,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? _getColorByPercent(remainingPercent);
    final percentInt = remainingPercent.clamp(0.0, 100.0).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _GaugePainter(
                  percent: remainingPercent.clamp(0.0, 100.0) / 100.0,
                  activeColor: color,
                  trackColor: AppColors.surfaceLight,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentInt%',
                    style: TextStyle(
                      color: color,
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          SizedBox(
            width: 90,
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorByPercent(double p) {
    if (p > 60) return AppColors.emerald;
    if (p > 25) return AppColors.amber;
    return AppColors.rose;
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color activeColor;
  final Color trackColor;

  _GaugePainter({
    required this.percent,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;
    const strokeWidth = 5.0;

    // 背景底环
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 进度高亮环
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
