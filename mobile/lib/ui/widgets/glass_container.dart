import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// 具有高质感赛博微晶毛玻璃、双层导光受光面与环境光晕的容器组件
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
  final String? podTag;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.glowColor,
    this.topHighlightColor,
    this.enableTopHighlight = true,
    this.enableCornerBolts = false,
    this.podTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final defaultBg = isLight ? AppColors.lightGlassCard : AppColors.glassPanel;
    final defaultBorder = isLight ? AppColors.lightGlassBorder : AppColors.glassBorder;
    final defaultTopHighlight = isLight ? Colors.white : AppColors.glassTopHighlight;
    final defaultShadowColor = isLight ? const Color(0x0D0F172A) : Colors.black.withOpacity(0.45);

    // 阴影组合：景深阴影 + 柔和环境光晕
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: defaultShadowColor,
        blurRadius: isLight ? 12 : 20,
        offset: Offset(0, isLight ? 4 : 10),
      ),
    ];

    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor!.withOpacity(isLight ? 0.12 : 0.18),
          blurRadius: 28,
          spreadRadius: -4,
          offset: const Offset(0, 4),
        ),
      );
    }

    final boxDecoration = BoxDecoration(
      color: gradient == null ? (backgroundColor ?? defaultBg) : null,
      gradient: gradient ??
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? [
                    backgroundColor ?? Colors.white,
                    backgroundColor?.withOpacity(0.9) ?? const Color(0xF7FFFFFF),
                  ]
                : [
                    backgroundColor ?? const Color(0xE6131828),
                    backgroundColor?.withOpacity(0.7) ?? const Color(0xD90E121E),
                  ],
          ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? defaultBorder,
        width: 1,
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
            // 物理微晶玻璃受光面顶边导光高光线 (西瓜同学 Dual-tone Glow 法则)
            if (enableTopHighlight)
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (topHighlightColor ?? Colors.white).withOpacity(0.0),
                        topHighlightColor ?? AppColors.glassTopHighlight,
                        (topHighlightColor ?? Colors.white).withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

            // 航天精密四角螺栓点缀
            if (enableCornerBolts)
              Positioned.fill(
                child: CustomPaint(
                  painter: _ContainerBoltPainter(
                    isLight: isLight,
                    boltColor: isLight ? AppColors.aeroBoltLight : AppColors.aeroBoltDark,
                  ),
                ),
              ),

            // 工业遥测微刻标牌
            if (podTag != null && podTag!.isNotEmpty)
              Positioned(
                top: 6,
                right: 10,
                child: Text(
                  podTag!,
                  style: TextStyle(
                    color: isLight ? AppColors.lightTextMuted : AppColors.textMuted.withOpacity(0.6),
                    fontSize: 7.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
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
