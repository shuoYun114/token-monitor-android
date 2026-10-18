import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 瑞士国际主义栅格容器组件 (Swiss Typographic Grid Container)
/// 遵循 Josef Müller-Brockmann 数学网格体系：0.8px 理性发丝线、微倒角、版面对位十字准星 (+) 与极简平面层次
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? glowColor;
  final Color? topHighlightColor;
  final bool enableTopHighlight;
  final bool enableCornerBolts;
  final bool enableCrosshairs;
  final bool enableSwissAccent;
  final String? podTag;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 8, // 瑞士风格：收敛为硬朗理性的 8px 微倒角
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.glowColor,
    this.topHighlightColor,
    this.enableTopHighlight = false,
    this.enableCornerBolts = false,
    this.enableCrosshairs = true, // 默认启用瑞士版面对位十字微标 (+)
    this.enableSwissAccent = false,
    this.podTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final defaultBg = isLight ? AppColors.swissLightSurface : AppColors.swissDarkSurface;
    final defaultBorder = isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder;
    final defaultShadowColor = isLight ? const Color(0x0809090B) : Colors.black.withOpacity(0.4);

    // 瑞士风格极度克制的阴影系统：弱化大面积模糊扩散，强化边界发丝线锐度
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: defaultShadowColor,
        blurRadius: isLight ? 8 : 16,
        offset: Offset(0, isLight ? 2 : 6),
      ),
    ];

    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor!.withOpacity(isLight ? 0.08 : 0.15),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 2),
        ),
      );
    }

    final boxDecoration = BoxDecoration(
      color: gradient == null ? (backgroundColor ?? defaultBg) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: 0.9, // 严格的瑞士 0.9px 发丝线
      ),
      boxShadow: shadows,
    );

    Widget content = Container(
      margin: margin,
      decoration: boxDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // 瑞士风格版面对齐十字微准星 (+)
            if (enableCrosshairs)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SwissCrosshairPainter(isLight: isLight),
                ),
              ),

            // 航天四角螺栓点缀 (保留兼容)
            if (enableCornerBolts && !enableCrosshairs)
              Positioned.fill(
                child: CustomPaint(
                  painter: _ContainerBoltPainter(
                    isLight: isLight,
                    boltColor: isLight ? AppColors.aeroBoltLight : AppColors.aeroBoltDark,
                  ),
                ),
              ),

            // 顶部瑞士精准红发丝线指示器
            if (enableSwissAccent)
              Positioned(
                top: 0,
                left: 12,
                child: Container(
                  width: 24,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.swissRed : AppColors.swissRedBright,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

            // 瑞士版面结构编号微刻 (Section Index)
            if (podTag != null && podTag!.isNotEmpty)
              Positioned(
                top: 7,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isLight ? AppColors.swissRed : AppColors.swissRedBright).withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      podTag!,
                      style: TextStyle(
                        color: isLight ? AppColors.swissLightTextMuted : AppColors.swissDarkTextMuted,
                        fontSize: 8,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

            // 主体内容
            Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

/// 绘制瑞士版面对位十字准星 (+)
class _SwissCrosshairPainter extends CustomPainter {
  final bool isLight;

  _SwissCrosshairPainter({required this.isLight});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (isLight ? const Color(0xFF71717A) : const Color(0xFFA1A1AA)).withOpacity(isLight ? 0.28 : 0.35)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const offset = 8.0;
    const arm = 3.5;

    final corners = [
      Offset(offset, offset),
      Offset(size.width - offset, offset),
      Offset(offset, size.height - offset),
      Offset(size.width - offset, size.height - offset),
    ];

    for (final c in corners) {
      // 水平发丝
      canvas.drawLine(Offset(c.dx - arm, c.dy), Offset(c.dx + arm, c.dy), linePaint);
      // 垂直发丝
      canvas.drawLine(Offset(c.dx, c.dy - arm), Offset(c.dx, c.dy + arm), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwissCrosshairPainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}

class _ContainerBoltPainter extends CustomPainter {
  final bool isLight;
  final Color boltColor;

  _ContainerBoltPainter({required this.isLight, required this.boltColor});

  @override
  void paint(Canvas canvas, Size size) {
    final boltPaint = Paint()
      ..color = boltColor.withOpacity(isLight ? 0.35 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final dotPaint = Paint()
      ..color = boltColor.withOpacity(isLight ? 0.25 : 0.35)
      ..style = PaintingStyle.fill;

    final offset = 7.0;
    final corners = [
      Offset(offset, offset),
      Offset(size.width - offset, offset),
      Offset(offset, size.height - offset),
      Offset(size.width - offset, size.height - offset),
    ];

    for (final c in corners) {
      canvas.drawCircle(c, 2.2, boltPaint);
      canvas.drawCircle(c, 0.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ContainerBoltPainter oldDelegate) =>
      oldDelegate.isLight != isLight || oldDelegate.boltColor != boltColor;
}
