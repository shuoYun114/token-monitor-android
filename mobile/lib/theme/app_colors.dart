import 'package:flutter/material.dart';

/// Token Monitor 移动端专属配色系统 (深色黑曜石 + 赛博毛玻璃霓虹)
class AppColors {
  // 背景色 (黑曜石深黑，杜绝OLED刺眼纯黑，增强景深)
  static const Color background = Color(0xFF07090E);
  static const Color consoleBg = Color(0xFF080A10);
  static const Color surface = Color(0xFF101420);
  static const Color surfaceLight = Color(0xFF161B2B);
  static const Color surfaceElevated = Color(0xFF1C2237);
  
  // 毛玻璃面板与双层导光边框
  static const Color glassPanel = Color(0xCC111624);
  static const Color glassCard = Color(0x99161C2E);
  static const Color glassBorder = Color(0x1FFFFFFF);
  static const Color glassBorderHighlight = Color(0x40FFFFFF);
  static const Color glassTopHighlight = Color(0x38FFFFFF);

  // 环境光晕色 (Ambient Glow)
  static const Color glowCyan = Color(0x2B38BDF8);
  static const Color glowEmerald = Color(0x2B10B981);
  static const Color glowAmber = Color(0x2BF59E0B);
  static const Color glowPurple = Color(0x2BA855F7);
  static const Color glowRose = Color(0x2BF43F5E);

  // 核心强调色与霓虹
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanNeon = Color(0xFF06B6D4);
  static const Color emerald = Color(0xFF10B981);
  static const Color purple = Color(0xFFA855F7);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color indigo = Color(0xFF6366F1);

  // 文字颜色 (层级分明的科技字阶)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textGhost = Color(0xFF475569);

  // 工具专属识别色 (与桌面版完全对齐)
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
