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

  /// 工具专属识别色 (全面对齐官方电脑端 v0.76.0 37款客户端与30家Provider)
  static const Color toolClaude = Color(0xFFCC7C5E);
  static const Color toolCodex = Color(0xFF49A3B0);
  static const Color toolCursor = Color(0xFF0EA5E9);
  static const Color toolAntigravity = Color(0xFF4285F4);
  static const Color toolOpenCode = Color(0xFF6366F1);
  static const Color toolDeepSeek = Color(0xFF0284C7);
  static const Color toolKimi = Color(0xFF14B8A6);
  static const Color toolQwen = Color(0xFF615CED);
  static const Color toolAlibaba = Color(0xFFFF6A00);
  static const Color toolZed = Color(0xFF4173E7);
  static const Color toolUnsloth = Color(0xFF40B85A);
  static const Color toolTrae = Color(0xFF32F08C);
  static const Color toolVolcengine = Color(0xFF006EFF);
  static const Color toolCopilot = Color(0xFF818CF8);
  static const Color toolHermes = Color(0xFFD4AF37);
  static const Color toolOpenClaw = Color(0xFFFF4D4D);
  static const Color toolAmp = Color(0xFFF34E3F);
  static const Color toolDroid = Color(0xFF10B981);
  static const Color toolGrok = Color(0xFF1DA1F2);
  static const Color toolPi = Color(0xFF10B981);
  static const Color toolOmp = Color(0xFFED4ABF);
  static const Color toolGoose = Color(0xFF38BDF8);
  static const Color toolKilo = Color(0xFFF59E0B);
  static const Color toolCommandCode = Color(0xFF8C4EDD);
  static const Color toolMimo = Color(0xFFFF6900);
  static const Color toolMuse = Color(0xFF0866FF);
  static const Color toolZCode = Color(0xFF1E88E5);
  static const Color toolKiro = Color(0xFF9046FF);
  static const Color toolCodeBuddy = Color(0xFF6C4DFF);
  static const Color toolWorkBuddy = Color(0xFF0DC8A5);
  static const Color toolProma = Color(0xFFEC4899);
  static const Color toolCatPaw = Color(0xFF00FFA2);
  static const Color toolQoder = Color(0xFF2ADB5C);
  static const Color toolReasonix = Color(0xFF4D6BFE);
  static const Color toolCherryStudio = Color(0xFFEA5E5D);
  static const Color toolLmStudio = Color(0xFF6C5CE7);
  static const Color toolDevin = Color(0xFF00C49F);
  static const Color toolFx = Color(0xFF6366F1);
  static const Color toolMiniMax = Color(0xFFF23F5D);
  static const Color toolOpenRouter = Color(0xFF6566F1);
  static const Color toolOllama = Color(0xFF888888);
  static const Color toolStepFun = Color(0xFF3B82F6);
  static const Color toolNotion = Color(0xFF94A3B8);
  static const Color toolGeneric = Color(0xFF64748B);

  /// 根据客户端/Provider标识获取官方标准色
  static Color getToolColor(String clientName) {
    final lower = clientName.toLowerCase();
    if (lower.contains('claude')) return toolClaude;
    if (lower.contains('codex') || lower.contains('openai')) return toolCodex;
    if (lower.contains('cursor')) return toolCursor;
    if (lower.contains('antigravity') || lower.contains('gemini')) return toolAntigravity;
    if (lower.contains('opencode')) return toolOpenCode;
    if (lower.contains('deepseek') || lower == 'dsh') return toolDeepSeek;
    if (lower.contains('kimi') || lower.contains('moonshot')) return toolKimi;
    if (lower.contains('qwen') || lower.contains('bailian')) return toolQwen;
    if (lower.contains('alibaba')) return toolAlibaba;
    if (lower.contains('hermes')) return toolHermes;
    if (lower.contains('openclaw')) return toolOpenClaw;
    if (lower.contains('amp')) return toolAmp;
    if (lower.contains('droid') || lower == 'factory') return toolDroid;
    if (lower.contains('grok') || lower.contains('xai')) return toolGrok;
    if (lower.contains('copilot') || lower.contains('github')) return toolCopilot;
    if (lower == 'omp' || lower.contains('ohmypi')) return toolOmp;
    if (lower == 'pi') return toolPi;
    if (lower.contains('goose')) return toolGoose;
    if (lower.contains('zed')) return toolZed;
    if (lower.contains('kilo')) return toolKilo;
    if (lower.contains('commandcode')) return toolCommandCode;
    if (lower.contains('mimo') || lower.contains('xiaomi')) return toolMimo;
    if (lower.contains('muse')) return toolMuse;
    if (lower.contains('zcode') || lower == 'zai' || lower == 'zaiteam') return toolZCode;
    if (lower.contains('kiro')) return toolKiro;
    if (lower.contains('codebuddy')) return toolCodeBuddy;
    if (lower.contains('workbuddy')) return toolWorkBuddy;
    if (lower.contains('proma')) return toolProma;
    if (lower.contains('catpaw')) return toolCatPaw;
    if (lower.contains('qoder')) return toolQoder;
    if (lower.contains('reasonix')) return toolReasonix;
    if (lower.contains('cherrystudio')) return toolCherryStudio;
    if (lower.contains('lmstudio')) return toolLmStudio;
    if (lower.contains('unsloth')) return toolUnsloth;
    if (lower.contains('devin')) return toolDevin;
    if (lower.contains('fx')) return toolFx;
    if (lower.contains('mcode') || lower.contains('minimax')) return toolMiniMax;
    if (lower.contains('openrouter')) return toolOpenRouter;
    if (lower.contains('trae')) return toolTrae;
    if (lower.contains('volcengine') || lower.contains('doubao')) return toolVolcengine;
    if (lower.contains('ollama')) return toolOllama;
    if (lower.contains('stepfun')) return toolStepFun;
    if (lower.contains('notion')) return toolNotion;
    return toolGeneric;
  }

  /// 获取官方标准中文/英文展示名称
  static String getToolLabel(String client) {
    if (client.isEmpty) return 'Unknown';
    final lower = client.toLowerCase();
    const catalog = {
      'claude': 'Claude Code',
      'codex': 'Codex',
      'opencode': 'OpenCode',
      'hermes': 'Hermes Agent',
      'openclaw': 'OpenClaw',
      'cursor': 'Cursor',
      'antigravity': 'Antigravity',
      'cline': 'Cline',
      'amp': 'Amp',
      'droid': 'Factory Droid',
      'factory': 'Factory Droid',
      'kimi': 'Kimi',
      'qwen': 'Qwen',
      'grok': 'Grok Build',
      'copilot': 'GitHub Copilot',
      'pi': 'Pi',
      'omp': 'Oh My Pi',
      'goose': 'Goose',
      'zed': 'Zed Editor',
      'kilo': 'Kilo Code',
      'commandcode': 'Command Code',
      'mimo': 'Xiaomi MiMo',
      'muse': 'Muse Code',
      'zcode': 'ZCode',
      'kiro': 'Kiro',
      'codebuddy': 'CodeBuddy',
      'workbuddy': 'WorkBuddy',
      'proma': 'Proma',
      'catpaw': 'CatPaw',
      'qodercn': 'Qoder CN',
      'qoder': 'Qoder',
      'reasonix': 'Reasonix',
      'dsh': 'DeepSeek Harness',
      'deepseek': 'DeepSeek',
      'cherrystudio': 'Cherry Studio',
      'lmstudio': 'LM Studio',
      'unsloth': 'Unsloth Studio',
      'devin': 'Devin',
      'fx': 'fx',
      'mcode': 'MiniMax Code',
      'minimax': 'MiniMax',
      'zai': 'GLM (智谱)',
      'zaiteam': 'GLM Team',
      'openrouter': 'OpenRouter',
      'volcengine': '火山引擎 (豆包)',
      'ollama': 'Ollama 本地',
      'trae': 'Trae CN',
      'alibaba': '阿里云百炼',
      'stepfun': 'StepFun (阶跃星辰)',
      'notion': 'Notion AI',
      'thirdparty': '第三方 API',
    };
    return catalog[lower] ?? (client[0].toUpperCase() + client.substring(1));
  }

  /// 获取官方 Material 风格矢量图标
  static IconData getToolIcon(String client) {
    final lower = client.toLowerCase();
    if (lower.contains('claude')) return Icons.psychology_rounded;
    if (lower.contains('cursor')) return Icons.code_rounded;
    if (lower.contains('antigravity')) return Icons.auto_awesome_mosaic_rounded;
    if (lower.contains('codex')) return Icons.terminal_rounded;
    if (lower.contains('copilot') || lower.contains('github')) return Icons.hub_rounded;
    if (lower.contains('alibaba') || lower.contains('qwen') || lower.contains('bailian')) return Icons.cloud_done_rounded;
    if (lower.contains('zed')) return Icons.code_off_rounded;
    if (lower.contains('unsloth')) return Icons.auto_awesome_rounded;
    if (lower.contains('trae')) return Icons.integration_instructions_rounded;
    if (lower.contains('volcengine') || lower.contains('doubao')) return Icons.bubble_chart_rounded;
    if (lower.contains('deepseek') || lower == 'dsh') return Icons.explore_rounded;
    if (lower.contains('kimi') || lower.contains('moonshot')) return Icons.chat_bubble_outline_rounded;
    if (lower.contains('opencode')) return Icons.terminal_rounded;
    if (lower.contains('hermes')) return Icons.smart_toy_rounded;
    if (lower.contains('openclaw')) return Icons.pets_rounded;
    if (lower.contains('amp')) return Icons.flash_on_rounded;
    if (lower.contains('droid') || lower == 'factory') return Icons.android_rounded;
    if (lower.contains('grok') || lower.contains('xai')) return Icons.stream_rounded;
    if (lower == 'omp') return Icons.adjust_rounded;
    if (lower == 'pi') return Icons.radio_button_checked_rounded;
    if (lower.contains('goose')) return Icons.flight_takeoff_rounded;
    if (lower.contains('kilo')) return Icons.layers_rounded;
    if (lower.contains('commandcode')) return Icons.code_sharp;
    if (lower.contains('mimo') || lower.contains('xiaomi')) return Icons.phone_android_rounded;
    if (lower.contains('muse')) return Icons.interests_rounded;
    if (lower.contains('zcode') || lower.contains('zai')) return Icons.grain_rounded;
    if (lower.contains('kiro')) return Icons.blur_on_rounded;
    if (lower.contains('codebuddy') || lower.contains('workbuddy')) return Icons.group_work_rounded;
    if (lower.contains('proma')) return Icons.workspace_premium_rounded;
    if (lower.contains('catpaw')) return Icons.fingerprint_rounded;
    if (lower.contains('qoder')) return Icons.developer_mode_rounded;
    if (lower.contains('reasonix')) return Icons.psychology_alt_rounded;
    if (lower.contains('cherrystudio')) return Icons.palette_rounded;
    if (lower.contains('lmstudio')) return Icons.laptop_chromebook_rounded;
    if (lower.contains('devin')) return Icons.assistant_rounded;
    if (lower.contains('fx')) return Icons.functions_rounded;
    if (lower.contains('mcode') || lower.contains('minimax')) return Icons.graphic_eq_rounded;
    if (lower.contains('openrouter')) return Icons.alt_route_rounded;
    if (lower.contains('ollama')) return Icons.storage_rounded;
    if (lower.contains('stepfun')) return Icons.stairs_rounded;
    if (lower.contains('notion')) return Icons.description_rounded;
    return Icons.bolt_rounded;
  }

  /// 根据模型名称动态识别官方厂商与高光色彩 (全面对齐电脑端 usageCharts.js 逻辑)
  static Color getModelColor(String modelName) {
    final lower = modelName.toLowerCase();
    if (RegExp(r'^(cursor-)?auto$').hasMatch(lower)) return toolCursor;
    if (RegExp(r'claude|anthropic|sonnet|opus|haiku').hasMatch(lower)) return const Color(0xFFF97316);
    if (RegExp(r'gpt|openai|codex|^o[134](?:-|$)|o[134]-(mini|pro|preview)|chatgpt').hasMatch(lower)) return const Color(0xFF10B981);
    if (RegExp(r'gemini|gemma|google').hasMatch(lower)) return const Color(0xFF38BDF8);
    if (RegExp(r'grok|xai').hasMatch(lower)) return const Color(0xFF1DA1F2);
    if (RegExp(r'deepseek').hasMatch(lower)) return const Color(0xFF0284C7);
    if (RegExp(r'nemotron|nvidia').hasMatch(lower)) return const Color(0xFF74B71B);
    if (RegExp(r'llama|meta|muse-spark(?:-|$)').hasMatch(lower)) return const Color(0xFF0866FF);
    if (RegExp(r'mistral|mixtral|codestral').hasMatch(lower)) return const Color(0xFFFA520F);
    if (RegExp(r'qwen|qwq|qvq|qmodel').hasMatch(lower)) return const Color(0xFF8B5CF6);
    if (RegExp(r'kimi|moonshot|k2d6-agent|k3-agent|(?:^|[^a-z0-9])k[23](?:[^a-z0-9]|$)').hasMatch(lower)) return const Color(0xFF14B8A6);
    if (RegExp(r'chatglm|\bglm-|\bzai\b|z\.ai|zhipu').hasMatch(lower)) return const Color(0xFF1E88E5);
    if (RegExp(r'cohere|command-r').hasMatch(lower)) return const Color(0xFF39594D);
    if (RegExp(r'mimo|xiaomi').hasMatch(lower)) return const Color(0xFFFF6900);
    if (RegExp(r'minimax|\babab').hasMatch(lower)) return const Color(0xFFF23F5D);
    if (RegExp(r'doubao|\bseed(?:-|$)').hasMatch(lower)) return const Color(0xFF1E37FC);
    if (RegExp(r'stepfun|step-').hasMatch(lower)) return const Color(0xFF3B82F6);
    if (RegExp(r'hy\d|hunyuan').hasMatch(lower)) return const Color(0xFF0053E0);
    if (RegExp(r'^swe[-_]|devin|cognition').hasMatch(lower)) return const Color(0xFF00C49F);
    if (lower == 'big-pickle') return const Color(0xFF6366F1);
    if (lower.contains('flash') || lower.contains('mini') || lower.contains('lite')) {
      return const Color(0xFFFBBF24); // 极速/轻量模型 太阳暖黄
    }
    return const Color(0xFF94A3B8); // 默认灰蓝
  }
}
