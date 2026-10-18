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
    this.borderRadius = 10, // 现代精致 10px 微倒角
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.glowColor,
    this.topHighlightColor,
    this.enableTopHighlight = false,
    this.enableCornerBolts = false,
    this.enableCrosshairs = false, // 默认关闭杂乱十字，保持留白与纯净
    this.enableSwissAccent = false,
    this.podTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final defaultBg = isLight ? AppColors.swissLightSurface : AppColors.swissDarkSurface;
    final defaultBorder = isLight ? AppColors.swissLightBorder : AppColors.swissDarkBorder;
    final defaultShadowColor = isLight ? const Color(0x0609090B) : Colors.black.withOpacity(0.35);

    // 现代瑞士风格极度克制的微阴影系统：弱化模糊扩散，强化边界发丝线锐度
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: defaultShadowColor,
        blurRadius: isLight ? 6 : 12,
        offset: Offset(0, isLight ? 2 : 4),
      ),
    ];

    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor!.withOpacity(isLight ? 0.06 : 0.12),
          blurRadius: 16,
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
        width: 0.8, // 严格的 0.8px 优雅发丝线
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
            // 瑞士风格版面对齐十字微准星 (+) - 仅显式启用时绘制
            if (enableCrosshairs)
              Positioned.fill(
                child: CustomPaint(
                  painter: _SwissCrosshairPainter(isLight: isLight),
                ),
              ),

            // 顶部瑞士精准红发丝线指示器 (高阶点睛，仅 2px 高)
            if (enableSwissAccent)
              Positioned(
                top: 0,
                left: 14,
                child: Container(
                  width: 24,
                  height: 2.0,
                  decoration: BoxDecoration(
                    color: isLight ? AppColors.swissRed : AppColors.swissRedBright,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

            // 主体内容 (绝不被绝对定位元素遮挡)
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

