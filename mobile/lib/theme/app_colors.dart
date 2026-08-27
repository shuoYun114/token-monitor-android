import 'package:flutter/material.dart';

/// Token Monitor 移动端专属配色系统 (深色黑曜石 + 赛博毛玻璃霓虹)
class AppColors {
  // 背景色
  static const Color background = Color(0xFF090A0F);
  static const Color surface = Color(0xFF11141D);
  static const Color surfaceLight = Color(0xFF191E30);
  
  // 毛玻璃面板与边框
  static const Color glassPanel = Color(0xBF121622);
  static const Color glassCard = Color(0x99191E30);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderHighlight = Color(0x33FFFFFF);

  // 核心强调色与霓虹
  static const Color cyan = Color(0xFF38BDF8);
  static const Color cyanNeon = Color(0xFF06B6D4);
  static const Color emerald = Color(0xFF10B981);
  static const Color purple = Color(0xFFA855F7);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFF43F5E);
  static const Color indigo = Color(0xFF6366F1);

  // 文字颜色
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // 工具专属识别色 (与桌面版完全对齐)
  static const Color toolClaude = Color(0xFFD97706);
  static const Color toolCodex = Color(0xFF10B981);
  static const Color toolCursor = Color(0xFF0EA5E9);
  static const Color toolAntigravity = Color(0xFFA855F7);
  static const Color toolOpenCode = Color(0xFF6366F1);
  static const Color toolDeepSeek = Color(0xFF0284C7);
  static const Color toolKimi = Color(0xFF14B8A6);
  static const Color toolQwen = Color(0xFF8B5CF6);
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
    if (lower.contains('qwen')) return toolQwen;
    return toolGeneric;
  }
}
