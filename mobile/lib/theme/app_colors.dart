import 'package:flutter/material.dart';

/// Token Monitor 移动端专属配色系统 (深色黑曜石 + 赛博毛玻璃霓虹)
class AppColors {
  // 背景色 (黑曜石深黑，杜绝OLED刺眼纯黑，增强景深)
  static const Color background = Color(0xFF07090E);
  static const Color consoleBg = Color(0xFF080A10);
  static const Color surface = Color(0xFF101420);
  static const Color surfaceLight = Color(0xFF161B2B);
  static const Color surfaceElevated = Color(0xFF1C2237);
  
  // 航天精密机械与钛合金质感色阶 (Aerospace Telemetry Palette)
  static const Color aeroTitanium = Color(0xFF1E2433); // 航天深钛灰
  static const Color aeroMetalTrack = Color(0xFF2A344A); // 机械刻度金属底轨
  static const Color aeroDialBorder = Color(0x3D38BDF8); // 陀飞轮发光外圈
  static const Color aeroBezelDark = Color(0xFF141926); // 深色精密外圈
  static const Color aeroBezelLight = Color(0xFFE5E9F0); // 浅色拉丝表圈
  static const Color aeroBoltDark = Color(0xFF334155); // 深色精密紧固件螺栓
  static const Color aeroBoltLight = Color(0xFF94A3B8); // 浅色精密紧固件螺栓
  static const Color aeroTickDark = Color(0x6638BDF8); // 深色机械微刻度线
  static const Color aeroTickLight = Color(0x80D97706); // 浅色机械微刻度线
  
  // 毛玻璃面板与双层导光边框
  static const Color glassPanel = Color(0xCC111624);
  static const Color glassCard = Color(0x99161C2E);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderHighlight = Color(0x40FFFFFF);
  static const Color glassTopHighlight = Color(0x38FFFFFF);
  static const Color glassTopHighlightWarm = Color(0x40FFFDF5); // 物理微晶玻璃受光面暖白导光高光线
  static const Color glassBorderWarm = Color(0x26FAF8F5);

  // 环境光晕色 (Ambient Glow)
  static const Color glowCyan = Color(0x2B38BDF8);
  static const Color glowEmerald = Color(0x2B10B981);
  static const Color glowAmber = Color(0x2BF59E0B);
  static const Color glowPurple = Color(0x2BA855F7);
  static const Color glowRose = Color(0x2BF43F5E);
  static const Color glowWarmYellow = Color(0x36FBBF24); // 暖黄弥散环境光晕
  static const Color glowWarmWhite = Color(0x22FAF8F5); // 暖白微晶光晕

  // 核心强调色与霓虹
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanNeon = Color(0xFF06B6D4);
  static const Color emerald = Color(0xFF10B981);
  static const Color purple = Color(0xFFA855F7);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color indigo = Color(0xFF6366F1);

  // 暖黄色系 (Warm Yellow / Warm Gold - 太阳暖黄/琥珀温润金，赋予算力价值与奢华感)
  static const Color warmYellow = Color(0xFFFBBF24); // 经典温润暖黄
  static const Color warmYellowBright = Color(0xFFFACC15); // 日光高亮暖黄
  static const Color warmYellowSoft = Color(0xFFFDE68A); // 柔和浅暖黄
  static const Color warmYellowDark = Color(0xFFD97706); // 琥珀深金
  static const Color warmYellowCard = Color(0x1AFBBF24); // 暖黄微晶卡槽背景
  static const Color warmYellowBorder = Color(0x4DFBBF24); // 暖黄卡槽边框
  static const Color warmYellowBadgeBg = Color(0x26FBBF24); // 暖黄胶囊背景

  // 文字颜色 (层级分明的科技字阶 + 暖白温润字阶)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textGhost = Color(0xFF475569);

  // 暖色调白色系 (Warm White Series - 象牙暖白/温润奶白，消除冷光刺眼，提升典雅质感)
  static const Color warmWhite = Color(0xFFFAF8F5); // 象牙暖白
  static const Color warmWhitePure = Color(0xFFFFFDF8); // 纯净高光暖白
  static const Color warmWhiteSoft = Color(0xFFF3EFE6); // 柔和微晶暖白
  static const Color warmWhiteMuted = Color(0xFFD5CEC2); // 次级次级暖白
  static const Color textPrimaryWarm = Color(0xFFFAF8F5); // 暖白主文字
  static const Color textSecondaryWarm = Color(0xFFA8A196); // 暖白次级文字

  // ================= 瑞士国际主义风格调色板 (Swiss Typographic Palette) =================
  // 核心灵魂强调色：瑞士精准红 (Swiss Precision Red)
  static const Color swissRed = Color(0xFFDC2626); // 经典瑞士国旗红，理性克制且极度醒目
  static const Color swissRedBright = Color(0xFFEF4444); // 深色高光穿透红
  static const Color swissRedMuted = Color(0xFF991B1B); // 沉稳深酒红
  static const Color swissRedBadge = Color(0x1FEF4444); // 瑞士红胶囊背景
  static const Color swissRedBorder = Color(0x5CEF4444); // 瑞士红发丝线边框
  static const Color swissRedGlow = Color(0x33EF4444); // 瑞士红微光

  // 瑞士冷白浅色体系 (Swiss Light / Alpine Canvas)
  static const Color swissLightBg = Color(0xFFF4F4F6); // 纯粹平坦的国际主义白纸底色
  static const Color swissLightSurface = Color(0xFFFFFFFF); // 纯白几何网格面
  static const Color swissLightSurfaceAlt = Color(0xFFEBECEF); // 次级分栏微灰网格
  static const Color swissLightBorder = Color(0xFFD4D4D8); // 0.8px 理性发丝线
  static const Color swissLightBorderStrong = Color(0xFF18181B); // 强对比几何黑线
  static const Color swissLightTextPrimary = Color(0xFF09090B); // 极致深黑标题
  static const Color swissLightTextSecondary = Color(0xFF52525B); // 客观石墨灰
  static const Color swissLightTextMuted = Color(0xFF71717A); // 微刻数据标签灰

  // 瑞士曜黑深色体系 (Swiss Dark / Zürich Night)
  static const Color swissDarkBg = Color(0xFF08080A); // 纯粹深曜黑底，零杂质
  static const Color swissDarkSurface = Color(0xFF111114); // 几何黑板底座
  static const Color swissDarkSurfaceAlt = Color(0xFF18181C); // 次级网格
  static const Color swissDarkBorder = Color(0xFF27272A); // 精密深色发丝线
  static const Color swissDarkBorderStrong = Color(0xFF52525B); // 强对比发丝线
  static const Color swissDarkTextPrimary = Color(0xFFFAFAFA); // 纯白高对比标题
  static const Color swissDarkTextSecondary = Color(0xFFA1A1AA); // 客观灰
  static const Color swissDarkTextMuted = Color(0xFF71717A); // 微刻标签灰

  // 瑞士风格 GitHub 热力图色阶 (瑞士红渐进)
  static const List<Color> swissHeatmapLevelsLight = [
    Color(0xFFE4E4E7), // Level 0: 熄灭晶体灰
    Color(0xFFFFE4E6), // Level 1: 淡粉红微阶
    Color(0xFFFDA4AF), // Level 2: 柔和玫瑰粉
    Color(0xFFF43F5E), // Level 3: 鲜明瑞士红
    Color(0xFFBE123C), // Level 4: 浓烈深红
  ];

  static const List<Color> swissHeatmapLevelsDark = [
    Color(0xFF18181C), // Level 0: 熄灭暗格
    Color(0xFF4C0519), // Level 1: 暗调血红
    Color(0xFF881337), // Level 2: 中度深红
    Color(0xFFE11D48), // Level 3: 瑞士亮红
    Color(0xFFFB7185), // Level 4: 极光高亮粉红
  ];

  // 浅色模式专属色系 (Light Amber - 纯净暖白 + 暖黄色)
  static const Color lightBackground = Color(0xFFF4F4F6); // 升级为平坦瑞士冷白
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFEBECEF);
  static const Color lightGlassCard = Color(0xFFFFFFFF);
  static const Color lightGlassBorder = Color(0xFFD4D4D8);
  static const Color lightTextPrimary = Color(0xFF09090B);
  static const Color lightTextSecondary = Color(0xFF52525B);
  static const Color lightTextMuted = Color(0xFF71717A);

  // 黑主题专属冰蓝强调色阶 (保留兼容)
  static const Color iceBlue = Color(0xFF38BDF8);
  static const Color iceBlueLight = Color(0xFF7DD3FC);
  static const Color iceBlueUltra = Color(0xFFBAE6FD);
  static const Color iceBlueDark = Color(0xFF0284C7);

  // GitHub 热力图 5 级色阶定义
  // 黑主题
  static const List<Color> darkHeatmapLevels = swissHeatmapLevelsDark;

  // 白主题
  static const List<Color> lightHeatmapLevels = swissHeatmapLevelsLight;

  /// 根据主题获取热力图色阶
  static List<Color> getHeatmapLevels(bool isLight) {
    return isLight ? lightHeatmapLevels : darkHeatmapLevels;
  }

  /// 根据主题获取主品牌色 (全面升级为经典瑞士精准红)
  static Color getThemeAccent(bool isLight) {
    return isLight ? swissRed : swissRedBright;
  }

  /// 工具专属识别色 (与桌面版完全对齐)
  static const Color toolClaude = Color(0xFFD97706);
  static const Color toolCodex = Color(0xFF10B981);
  static const Color toolCursor = Color(0xFF0EA5E9);
  static const Color toolAntigravity = Color(0xFFA855F7);
  static const Color toolOpenCode = Color(0xFF6366F1);
  static const Color toolDeepSeek = Color(0xFF0284C7);
  static const Color toolKimi = Color(0xFF14B8A6);
  static const Color toolQwen = Color(0xFF8B5CF6);
  static const Color toolAlibaba = Color(0xFFFF6A00);
  static const Color toolZed = Color(0xFF22C55E);
  static const Color toolUnsloth = Color(0xFFEC4899);
  static const Color toolTrae = Color(0xFF3B82F6);
  static const Color toolVolcengine = Color(0xFF06B6D4);
  static const Color toolCopilot = Color(0xFF818CF8);
  static const Color toolGeneric = Color(0xFF64748B);

  static Color getToolColor(String clientName) {
    final lower = clientName.toLowerCase();
    if (lower.contains('claude')) return toolClaude;
    if (lower.contains('codex') || lower.contains('openai')) return toolCodex;
    if (lower.contains('cursor')) return toolCursor;
    if (lower.contains('antigravity') || lower.contains('gemini')) return toolAntigravity;
    if (lower.contains('opencode')) return toolOpenCode;
    if (lower.contains('deepseek')) return toolDeepSeek;
    if (lower.contains('kimi')) return toolKimi;
    if (lower.contains('qwen') || lower.contains('alibaba') || lower.contains('bailian')) return toolAlibaba;
    if (lower.contains('zed')) return toolZed;
    if (lower.contains('unsloth')) return toolUnsloth;
    if (lower.contains('trae')) return toolTrae;
    if (lower.contains('volcengine') || lower.contains('doubao')) return toolVolcengine;
    if (lower.contains('copilot') || lower.contains('github')) return toolCopilot;
    return toolGeneric;
  }

  static Color getModelColor(String modelName) {
    final lower = modelName.toLowerCase();
    if (lower.contains('flash') || lower.contains('mini') || lower.contains('lite')) {
      return const Color(0xFFFBBF24); // 极速/轻量模型 太阳暖黄
    }
    if (lower.contains('gemini')) return const Color(0xFF38BDF8); // 谷歌 Gemini 科技青
    if (lower.contains('claude') || lower.contains('sonnet') || lower.contains('haiku') || lower.contains('opus')) {
      return const Color(0xFFF97316); // Claude 珊瑚橙
    }
    if (lower.contains('gpt') || lower.contains('o1') || lower.contains('o3') || lower.contains('openai')) {
      return const Color(0xFF10B981); // OpenAI 翡翠绿
    }
    if (lower.contains('deepseek')) return const Color(0xFF0284C7); // DeepSeek 深度蓝
    if (lower.contains('qwen')) return const Color(0xFF8B5CF6); // 通义千问 霓虹紫
    if (lower.contains('kimi') || lower.contains('moonshot')) return const Color(0xFF14B8A6); // Kimi 青绿
    return const Color(0xFF94A3B8); // 默认灰蓝
  }
}

