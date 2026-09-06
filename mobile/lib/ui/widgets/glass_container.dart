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
  final bool enableTopHighlight;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.glowColor,
    this.enableTopHighlight = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 阴影组合：景深阴影 + 柔和环境光晕
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withOpacity(0.45),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];

    if (glowColor != null) {
      shadows.add(
        BoxShadow(
          color: glowColor!.withOpacity(0.18),
          blurRadius: 28,
          spreadRadius: -4,
          offset: const Offset(0, 4),
        ),
      );
    }

    final boxDecoration = BoxDecoration(
      color: gradient == null ? (backgroundColor ?? AppColors.glassPanel) : null,
      gradient: gradient ??
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor ?? const Color(0xE6131828),
              backgroundColor?.withOpacity(0.7) ?? const Color(0xD90E121E),
            ],
          ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
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
                        Colors.white.withOpacity(0.0),
                        AppColors.glassTopHighlight,
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
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
