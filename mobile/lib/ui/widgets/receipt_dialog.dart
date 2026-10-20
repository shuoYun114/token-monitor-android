import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../models/device_stats.dart';
import '../../theme/app_colors.dart';

/// 小票数据传输载体
class ReceiptData {
  final String title;
  final DateTime date;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? dateRange;
  final String hostname;
  final int totalTokens;
  final double costUsd;
  final String currency;
  final double usdToCnyRate;
  final Map<String, dynamic> models;
  final Map<String, dynamic> modelCosts;
  final Map<String, dynamic> clients;
  final Map<String, dynamic> clientCosts;
  final String? primaryClient;
  final int cacheReadTokens;
  final int outputTokens;
  final int unclassifiedTokens;
  final Map<String, dynamic> modelCacheReads;
  final Map<String, dynamic> modelOutputs;
  final Map<String, dynamic> modelUnclassifiedTokens;

  const ReceiptData({
    required this.title,
    required this.date,
    this.startDate,
    this.endDate,
    this.dateRange,
    required this.hostname,
    required this.totalTokens,
    required this.costUsd,
    this.currency = 'CNY',
    this.usdToCnyRate = 7.25,
    this.models = const {},
    this.modelCosts = const {},
    this.clients = const {},
    this.clientCosts = const {},
    this.primaryClient,
    this.cacheReadTokens = 0,
    this.outputTokens = 0,
    this.unclassifiedTokens = 0,
    this.modelCacheReads = const {},
    this.modelOutputs = const {},
    this.modelUnclassifiedTokens = const {},
  });

  /// 票据全局输入/输出与缓存细分
  TokenBreakdown get breakdown => TokenBreakdown.calculate(
        totalTokens: totalTokens,
        cacheReadTokens: cacheReadTokens,
        outputTokens: outputTokens,
        unclassifiedTokens: unclassifiedTokens,
      );

  /// 单个模型的细分
  TokenBreakdown modelBreakdown(String model) {
    int safeInt(dynamic v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return TokenBreakdown.calculate(
      totalTokens: safeInt(models[model]),
      cacheReadTokens: safeInt(modelCacheReads[model]),
      outputTokens: safeInt(modelOutputs[model]),
      unclassifiedTokens: safeInt(modelUnclassifiedTokens[model]),
    );
  }
}

/// 毒舌与幽默神吐槽语料库 (基于 Hchen1218/token-receipt 灵魂灵感)
class ReceiptPunchlines {
  static const List<Map<String, String>> punchlines = [
    // 视觉与改版
    {
      'zh': '画面稳了，预算死了。',
      'en': 'THE LOGO LOOKS CALM. THE BILL DOES NOT.',
    },
    {
      'zh': '最后一版这个词，本来就不诚实。',
      'en': 'THE LAST REVISION WAS NOT THE LAST.',
    },
    {
      'zh': '像素满意了，钱包没有。',
      'en': 'THE PIXELS ARE ALIGNED. THE CASH FLOW IS NOT.',
    },
    {
      'zh': '你修的是对齐，坏的是预算。',
      'en': 'YOU FIXED THE MARGIN, YOU BROKE THE BUDGET.',
    },
    {
      'zh': '再改一版，先死一笔。',
      'en': 'ONE MORE ITERATION, ONE MORE INVOICE.',
    },
    // 缓存与输入输出
    {
      'zh': '缓存命中100%，省钱省得像在白嫖。',
      'en': '100% CACHE HIT. CHEATING THE BILLING DEPT.',
    },
    {
      'zh': '输入几千万，输出两百字。',
      'en': 'TENS OF MILLIONS IN, TWO HUNDRED WORDS OUT.',
    },
    {
      'zh': '缓存零命中，真金白银喂显卡。',
      'en': 'ZERO CACHE HIT. DIRECT WIRE TRANSFER TO NVIDIA.',
    },
    // 调试与 Bug
    {
      'zh': '问题死了，账单活着。',
      'en': 'THE BUG IS DEAD. THE BILL IS ALIVE.',
    },
    {
      'zh': 'Bug 修完了，费用继承了。',
      'en': 'THE EXCEPTION WAS HANDLED. THE COST WAS INHERITED.',
    },
    {
      'zh': '补丁合上了，钱包裂开了。',
      'en': 'THE PATCH WAS APPLIED. THE WALLET WAS FRACTURED.',
    },
    {
      'zh': '错误消失了，代价留档了。',
      'en': 'ERRORS VANISHED. CHARGES PERSISTED.',
    },
    // 深度推理与思考
    {
      'zh': '推理不免费，犹豫更贵。',
      'en': 'REASONING WAS BILLED SEPARATELY.',
    },
    {
      'zh': '思考得很认真，结账也很认真。',
      'en': 'DEEP THINKING CARRIES A DEEP INVOICE.',
    },
    {
      'zh': '答案出来了，脑力税也出来了。',
      'en': 'THE ANSWER ARRIVED. THE COGNITIVE TOLL ARRIVED TOO.',
    },
    {
      'zh': '结论落地了，推理费追上来了。',
      'en': 'CONCLUSION REACHED. FEES NOT FAR BEHIND.',
    },
    // 上下文与缓存
    {
      'zh': '上下文撑住了，预算先躺下了。',
      'en': 'CONTEXT DID NOT OVERFLOW. FUNDS DID.',
    },
    {
      'zh': '模型记住了很多，钱包也记住了。',
      'en': 'THE MODEL REMEMBERED ALL. THE ACCOUNT RECORDED ALL.',
    },
    {
      'zh': '缓存救了一点，不够救你。',
      'en': 'PROMPT CACHE SAVED A FRACTION. NOT ENOUGH TO SAVE YOU.',
    },
    {
      'zh': '窗口没爆，余额先爆了。',
      'en': 'WINDOW STILL HEALTHY. BALANCE FLATLINED.',
    },
    // 交付与破防
    {
      'zh': '东西发出去了，钱回不来了。',
      'en': 'SHIPPED TO PRODUCTION. DEBT SHIPPED TO REALITY.',
    },
    {
      'zh': '结果很体面，账单更诚实。',
      'en': 'THE DEMO WAS POLISHED. THE RECEIPT WAS HONEST.',
    },
    {
      'zh': '你以为它在帮你写代码，其实它在按字收房租。',
      'en': 'IT DOES NOT JUST COMPLETE CODE. IT CHARGES RENT PER WORD.',
    },
    {
      'zh': '报价到了，侥幸死了。',
      'en': 'ESTIMATE ARRIVED. DENIAL CLOSED.',
    },
    {
      'zh': '账单没情绪，你有。',
      'en': 'THE BILL HAS NO EMOTION. YOU HAVE PLENTY.',
    },
  ];

  static Map<String, String> getRandomPunchline([int? seed]) {
    final rand = seed != null ? math.Random(seed) : math.Random();
    return punchlines[rand.nextInt(punchlines.length)];
  }
}

/// 热敏纸小票展示弹窗
class ReceiptDialog extends StatefulWidget {
  final ReceiptData data;

  const ReceiptDialog({super.key, required this.data});

  /// 快捷拉起对话框
  static Future<void> show(BuildContext context, ReceiptData data) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Receipt',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, anim1, anim2) {
        return ReceiptDialog(data: data);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.2),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: curve,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<ReceiptDialog> {
  bool _isEnglish = false;
  bool _isCapturing = false;
  late Map<String, String> _currentPunchline;
  late String _receiptId;
  final GlobalKey _receiptCaptureKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  static const MethodChannel _imageChannel = MethodChannel('com.javis.tokenmonitor/image_saver');

  @override
  void initState() {
    super.initState();
    _currentPunchline = ReceiptPunchlines.getRandomPunchline();
    _receiptId = _generateReceiptId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _generateReceiptId() {
    final d = widget.data.date;
    final randPart = (1000 + math.Random().nextInt(8999)).toString();
    if (widget.data.startDate != null && widget.data.endDate != null) {
      final s = widget.data.startDate!;
      final e = widget.data.endDate!;
      final sStr = '${s.year.toString().substring(2)}${s.month.toString().padLeft(2, '0')}${s.day.toString().padLeft(2, '0')}';
      final eStr = '${e.year.toString().substring(2)}${e.month.toString().padLeft(2, '0')}${e.day.toString().padLeft(2, '0')}';
      return 'TM-$sStr-$eStr-$randPart';
    }
    final datePart = '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    return 'TM-$datePart-$randPart';
  }

  void _nextPunchline() {
    setState(() {
      _currentPunchline = ReceiptPunchlines.getRandomPunchline();
    });
  }

  String _formatTokens(int tokens) {
    if (tokens >= 1000000000) {
      return '${(tokens / 1000000000).toStringAsFixed(2)}B';
    } else if (tokens >= 1000000) {
      return '${(tokens / 1000000).toStringAsFixed(2)}M';
    } else if (tokens >= 1000) {
      return '${(tokens / 1000).toStringAsFixed(1)}K';
    }
    return tokens.toString();
  }

  String _formatCost(double costUsd) {
    if (widget.data.currency == 'CNY') {
      return '¥${(costUsd * widget.data.usdToCnyRate).toStringAsFixed(2)}';
    }
    return '\$${costUsd.toStringAsFixed(3)}';
  }

  int _safeIntTokens(dynamic v) {
    if (v is num) return v.toInt();
    if (v is Map) {
      final t = v['tokens'] ?? v['totalTokens'];
      if (t is num) return t.toInt();
      if (t is String) return int.tryParse(t) ?? 0;
    }
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  double _safeDoubleCost(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    if (v is Map) {
      final c = v['cost'] ?? v['costUsd'];
      if (c is num) return c.toDouble();
      if (c is String) return double.tryParse(c) ?? 0.0;
    }
    return 0.0;
  }

  /// 构建纯文本 ASCII 小票字符串用于复制分享
  String _buildAsciiReceipt() {
    final buffer = StringBuffer();
    final d = widget.data.date;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final punchlineText = _isEnglish ? _currentPunchline['en']! : _currentPunchline['zh']!;

    buffer.writeln('========================================');
    buffer.writeln('          TOKEN MONITOR RECEIPT         ');
    buffer.writeln('       AI COMPUTE CONSUMPTION LOG       ');
    buffer.writeln('========================================');
    buffer.writeln('RECEIPT #: $_receiptId');
    if (widget.data.dateRange != null && widget.data.dateRange!.isNotEmpty) {
      buffer.writeln('PERIOD   : ${widget.data.dateRange}');
      buffer.writeln('PRINTED  : $dateStr');
    } else {
      buffer.writeln('DATE     : $dateStr');
    }
    buffer.writeln('REGISTER : ${widget.data.hostname}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('ITEM / MODEL             QTY      AMOUNT');
    buffer.writeln('----------------------------------------');

    if (widget.data.models.isNotEmpty) {
      widget.data.models.forEach((model, rawTokens) {
        final cost = _safeDoubleCost(widget.data.modelCosts[model]);
        final tokens = _safeIntTokens(rawTokens);
        final name = model.length > 20 ? model.substring(0, 19) : model.padRight(20);
        final tokStr = _formatTokens(tokens).padLeft(7);
        final costStr = _formatCost(cost).padLeft(9);
        buffer.writeln('$name $tokStr $costStr');

        final mBd = widget.data.modelBreakdown(model);
        if (mBd.cacheRead > 0 || mBd.output > 0) {
          buffer.writeln('  [IN(HIT): ${_formatTokens(mBd.cacheRead)} (${mBd.hitPct}%)  OUT: ${_formatTokens(mBd.output)}]');
        }
      });
    } else {
      widget.data.clients.forEach((client, rawTokens) {
        final cost = _safeDoubleCost(widget.data.clientCosts[client]);
        final tokens = _safeIntTokens(rawTokens);
        final name = client.length > 20 ? client.substring(0, 19) : client.padRight(20);
        final tokStr = _formatTokens(tokens).padLeft(7);
        final costStr = _formatCost(cost).padLeft(9);
        buffer.writeln('$name $tokStr $costStr');
      });
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('TOTAL TOKENS : ${_formatTokens(widget.data.totalTokens)}');
    final bd = widget.data.breakdown;
    if (bd.cacheRead > 0 || bd.output > 0) {
      buffer.writeln('  - INPUT (CACHE HIT) : ${_formatTokens(bd.cacheRead)} (${bd.hitPct}%)');
      buffer.writeln('  - INPUT (CACHE MISS): ${_formatTokens(bd.cacheMiss)} (${bd.missPct}%)');
      buffer.writeln('  - OUTPUT TOKENS     : ${_formatTokens(bd.output)}');
      if (bd.unclassified > 0) {
        buffer.writeln('  - UNCLASSIFIED      : ${_formatTokens(bd.unclassified)}');
      }
    }
    buffer.writeln('TOTAL AMOUNT : ${_formatCost(widget.data.costUsd)} (USD: \$${widget.data.costUsd.toStringAsFixed(3)})');
    buffer.writeln('========================================');
    buffer.writeln('PUNCHLINE:');
    buffer.writeln('  $punchlineText');
    buffer.writeln('========================================');
    buffer.writeln('||| | ||||| || | |||| ||| || ||||| | |||');
    buffer.writeln('           [ THANK YOU FOR CODING ]     ');

    return buffer.toString();
  }

  void _copyToClipboard() {
    final text = _buildAsciiReceipt();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
            const SizedBox(width: 8),
            Text(
              _isEnglish ? 'Receipt copied to clipboard!' : '消费小票已成功复制到剪贴板！',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  /// 截取小票生成高清 PNG 并直接写入系统相册 (Pictures/TokenMonitor)
  Future<void> _captureAndSaveReceipt() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // 稍微等待一帧以确保任何可能的排版渲染完成
      await Future.delayed(const Duration(milliseconds: 60));

      final boundary = _receiptCaptureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(_isEnglish ? 'Failed to locate receipt view' : '无法获取小票渲染节点');
      }

      // 采用 3.0 超采样像素比，确保热敏纸上的 ASCII 图案与小字在高分屏上纤毫毕现
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(_isEnglish ? 'Failed to encode PNG image' : '小票图片编码失败');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final filename = 'TokenReceipt_${_receiptId}_${DateTime.now().millisecondsSinceEpoch}';

      // 调用 Android 原生 MethodChannel 将图片安全写入系统相册
      final String? savedPath = await _imageChannel.invokeMethod<String>(
        'saveImageToGallery',
        {
          'imageBytes': pngBytes,
          'filename': filename,
        },
      );

      if (!mounted) return;

      if (savedPath != null) {
        // 浮动成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.cyan, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isEnglish
                        ? 'Receipt saved to gallery (Pictures/TokenMonitor)!'
                        : '小票已保存到系统相册 (Pictures/TokenMonitor)！',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(milliseconds: 2500),
          ),
        );

        // 唤起全屏/弹窗长图预览，支持交互手势缩放
        _showReceiptImagePreview(pngBytes, savedPath);
      } else {
        throw Exception(_isEnglish ? 'Failed to save image to gallery' : '保存图片到相册失败');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.rose, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEnglish ? 'Failed to save receipt: $e' : '保存小票失败: $e',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2D1216),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 3000),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  /// 弹出小票高清图片预览弹窗，支持双指缩放拖拽
  void _showReceiptImagePreview(Uint8List pngBytes, String savedPath) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部标题控制栏
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF131826).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.cyan),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isEnglish ? 'Receipt Saved to Gallery' : '小票已保存到系统相册',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _isEnglish ? 'Pictures/TokenMonitor' : '已存入相册: Pictures/TokenMonitor',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 高清图片预览与手势缩放区
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0F19),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.memory(
                              pngBytes,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 底部轻量交互提示
              Text(
                _isEnglish ? 'Double-tap or pinch to zoom details' : '可双指捏合缩放或拖拽查看细节',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data.date;
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final punchlineText = _isEnglish ? _currentPunchline['en']! : _currentPunchline['zh']!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部快捷控制操作条
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF131826).withOpacity(0.94),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. 语言切换
                  GestureDetector(
                    onTap: () => setState(() => _isEnglish = !_isEnglish),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: _isEnglish ? AppColors.cyan.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.translate_rounded,
                            size: 13,
                            color: _isEnglish ? AppColors.cyan : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEnglish ? 'EN' : '中文',
                            style: TextStyle(
                              color: _isEnglish ? AppColors.cyan : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),

                  // 2. 换一句吐槽
                  GestureDetector(
                    onTap: _nextPunchline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.casino_outlined, size: 13, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _isEnglish ? 'Punchline' : '换句吐槽',
                            style: const TextStyle(
                              color: AppColors.amber,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),

                  // 3. 复制 ASCII 文本
                  GestureDetector(
                    onTap: _copyToClipboard,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded, size: 13, color: AppColors.emerald),
                          const SizedBox(width: 4),
                          Text(
                            _isEnglish ? 'Copy' : '复制小票',
                            style: const TextStyle(
                              color: AppColors.emerald,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),

                  // 4. 截图保存至相册
                  GestureDetector(
                    onTap: _isCapturing ? null : _captureAndSaveReceipt,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF818CF8).withOpacity(0.35), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isCapturing)
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.6,
                                color: Color(0xFFA5B4FC),
                              ),
                            )
                          else
                            const Icon(Icons.camera_alt_rounded, size: 13, color: Color(0xFFA5B4FC)),
                          const SizedBox(width: 4),
                          Text(
                            _isCapturing
                                ? (_isEnglish ? 'Saving...' : '保存中...')
                                : (_isEnglish ? 'Save Image' : '截图存相册'),
                            style: const TextStyle(
                              color: Color(0xFFA5B4FC),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 5. 关闭按钮
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),

          // 小票主体 (仿真热敏纸张)
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: _receiptCaptureKey,
                  child: Container(
                    width: 320,
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 顶部收银机锯齿撕纸边
                        CustomPaint(
                          size: const Size(320, 8),
                          painter: _ReceiptJaggedEdgePainter(isTop: true),
                        ),

                        // 小票正文主体
                        Container(
                          width: 320,
                          color: const Color(0xFFFAF8F5), // 真实收银机热敏纸米白色
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                          // 1. ASCII 艺术 Logo 区
                          _buildAsciiLogo(widget.data.primaryClient),

                          const SizedBox(height: 8),
                          Text(
                            _isEnglish ? 'TOKEN MONITOR REGISTER' : 'TOKEN MONITOR 收银台',
                            style: const TextStyle(
                              color: Color(0xFF18181B),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            _isEnglish ? 'AI COMPUTE EXPENSE REPORT' : 'AI 算力消耗结账小票',
                            style: const TextStyle(
                              color: Color(0xFF52525B),
                              fontSize: 10,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 10),
                          _buildDottedRule(),
                          const SizedBox(height: 8),

                          // 2. 元信息区
                          _buildMetaRow(_isEnglish ? 'RECEIPT #' : '小票编号', _receiptId),
                          if (widget.data.dateRange != null && widget.data.dateRange!.isNotEmpty) ...[
                            _buildMetaRow(_isEnglish ? 'PERIOD' : '统计周期', widget.data.dateRange!),
                            _buildMetaRow(_isEnglish ? 'PRINTED' : '打印时间', dateStr),
                          ] else ...[
                            _buildMetaRow(_isEnglish ? 'DATE TIME' : '结账时间', dateStr),
                          ],
                          _buildMetaRow(_isEnglish ? 'REGISTER' : '监控终端', widget.data.hostname),
                          if (widget.data.primaryClient != null && widget.data.primaryClient!.isNotEmpty)
                            _buildMetaRow(_isEnglish ? 'PRIMARY' : '主力工具', widget.data.primaryClient!.toUpperCase()),

                          const SizedBox(height: 8),
                          _buildDottedRule(),
                          const SizedBox(height: 8),

                          // 3. 表头区
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isEnglish ? 'ITEM / MODEL' : '条目 / 模型',
                                style: const TextStyle(
                                  color: Color(0xFF18181B),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _isEnglish ? 'TOKENS' : 'TOKEN',
                                    style: const TextStyle(
                                      color: Color(0xFF18181B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    _isEnglish ? 'AMOUNT' : '金额',
                                    style: const TextStyle(
                                      color: Color(0xFF18181B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildDottedRule(isLight: true),
                          const SizedBox(height: 6),

                          // 4. 明细条目清单
                          if (widget.data.models.isNotEmpty) ...[
                            ...widget.data.models.entries.map((e) {
                              final cost = _safeDoubleCost(widget.data.modelCosts[e.key]);
                              final tokens = _safeIntTokens(e.value);
                              final mBd = widget.data.modelBreakdown(e.key);
                              return _buildItemRow(e.key, tokens, cost, breakdown: mBd);
                            }),
                          ] else if (widget.data.clients.isNotEmpty) ...[
                            ...widget.data.clients.entries.map((e) {
                              final cost = _safeDoubleCost(widget.data.clientCosts[e.key]);
                              final tokens = _safeIntTokens(e.value);
                              return _buildItemRow(e.key, tokens, cost);
                            }),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _isEnglish ? '[ NO ACTIVE TOKENS TODAY ]' : '[ 今日暂无活跃消耗 ]',
                                style: const TextStyle(
                                  color: Color(0xFF71717A),
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),
                          _buildDoubleRule(),
                          const SizedBox(height: 8),

                          // 5. 汇总区 (加粗大字)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isEnglish ? 'TOTAL TOKENS' : 'TOKEN 总消耗',
                                style: const TextStyle(
                                  color: Color(0xFF18181B),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                _formatTokens(widget.data.totalTokens),
                                style: const TextStyle(
                                  color: Color(0xFF18181B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          // 细分遥测：输入(缓存命中/未命中)、输出与未分类
                          Builder(
                            builder: (context) {
                              final bd = widget.data.breakdown;
                              if (bd.cacheRead == 0 && bd.output == 0 && bd.cacheMiss == 0) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                margin: const EdgeInsets.only(top: 5, bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    _buildSummarySubRow(
                                      _isEnglish ? 'Input (Cache Hit)' : '输入 (缓存命中)',
                                      '${_formatTokens(bd.cacheRead)} (${bd.hitPct}%)',
                                    ),
                                    _buildSummarySubRow(
                                      _isEnglish ? 'Input (Direct)' : '输入 (缓存未命中)',
                                      '${_formatTokens(bd.cacheMiss)} (${bd.missPct}%)',
                                    ),
                                    _buildSummarySubRow(
                                      _isEnglish ? 'Output Tokens' : '输出 Tokens',
                                      _formatTokens(bd.output),
                                    ),
                                    if (bd.unclassified > 0)
                                      _buildSummarySubRow(
                                        _isEnglish ? 'Unclassified' : '未分类',
                                        _formatTokens(bd.unclassified),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isEnglish ? 'ESTIMATED TOTAL' : '总估算支出',
                                style: const TextStyle(
                                  color: Color(0xFF18181B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                _formatCost(widget.data.costUsd),
                                style: const TextStyle(
                                  color: Color(0xFF09090B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          if (widget.data.currency == 'CNY') ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '≈ \$${widget.data.costUsd.toStringAsFixed(3)} USD',
                                style: const TextStyle(
                                  color: Color(0xFF71717A),
                                  fontSize: 9.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),
                          _buildDoubleRule(),
                          const SizedBox(height: 12),

                          // 6. 灵魂核心：毒舌神吐槽 (The Punchline)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EDE6),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFD4D4D8), width: 0.8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isEnglish ? '// RECEIPT PUNCHLINE //' : '// 账单毒舌神吐槽 //',
                                  style: const TextStyle(
                                    color: Color(0xFF71717A),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'monospace',
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  punchlineText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF09090B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'monospace',
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 7. ASCII 条形码
                          const Text(
                            '|||  |||||  ||  |||  ||||  ||  |||||  |||  ||',
                            style: TextStyle(
                              color: Color(0xFF18181B),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _receiptId,
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontFamily: 'monospace',
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            _isEnglish
                                ? '*** THANK YOU FOR CODING ***'
                                : '*** 感谢你为 AI 算力添砖加瓦 ***',
                            style: const TextStyle(
                              color: Color(0xFF52525B),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 底部收银机锯齿撕纸边
                    CustomPaint(
                      size: const Size(320, 8),
                      painter: _ReceiptJaggedEdgePainter(isTop: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71717A),
              fontSize: 9.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF18181B),
              fontSize: 9.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, int tokens, double costUsd, {TokenBreakdown? breakdown}) {
    final displayName = name.length > 18 ? '${name.substring(0, 16)}..' : name;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: Color(0xFF27272A),
                    fontSize: 10,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTokens(tokens),
                style: const TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                _formatCost(costUsd),
                style: const TextStyle(
                  color: Color(0xFF18181B),
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (breakdown != null && (breakdown.cacheRead > 0 || breakdown.output > 0)) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 1),
              child: Text(
                '↳ ${_isEnglish ? "IN(HIT)" : "输入缓存"}: ${_formatTokens(breakdown.cacheRead)} (${breakdown.hitPct}%)  ${_isEnglish ? "OUT" : "输出"}: ${_formatTokens(breakdown.output)}',
                style: const TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 8.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySubRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71717A),
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF27272A),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedRule({bool isLight = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 5).floor();
        return Text(
          '- ' * count,
          style: TextStyle(
            color: isLight ? const Color(0xFFD4D4D8) : const Color(0xFFA1A1AA),
            fontSize: 7,
            fontFamily: 'monospace',
            letterSpacing: 1.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        );
      },
    );
  }

  Widget _buildDoubleRule() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 6).floor();
        return Text(
          '=' * count,
          style: const TextStyle(
            color: Color(0xFF71717A),
            fontSize: 8,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.clip,
        );
      },
    );
  }

  Widget _buildAsciiLogo(String? client) {
    final c = client?.toLowerCase() ?? '';
    if (c.contains('claude')) {
      return const Column(
        children: [
          Text(
            '   ▐▛███▜▌\n  ▝▜█████▛▘\n    ▘▘ ▝▝',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF18181B),
              fontSize: 9,
              height: 1.1,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'CLAUDE CODE',
            style: TextStyle(
              color: Color(0xFF18181B),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }
    if (c.contains('cursor')) {
      return const Column(
        children: [
          Text(
            '    ▲    \n   ╱ ╲   \n  ╱___╲  ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF18181B),
              fontSize: 9,
              height: 1.1,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'CURSOR',
            style: TextStyle(
              color: Color(0xFF18181B),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }

    // 默认 Token Monitor 像素徽标
    return const Column(
      children: [
        Text(
          '╔════════════════════════╗\n'
          '║  TOKEN MONITOR // REG  ║\n'
          '╚════════════════════════╝',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 9,
            height: 1.15,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// 绘制收银机锯齿撕纸效果
class _ReceiptJaggedEdgePainter extends CustomPainter {
  final bool isTop;

  _ReceiptJaggedEdgePainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFAF8F5)
      ..style = PaintingStyle.fill;

    final path = Path();
    const toothWidth = 8.0;
    final toothHeight = size.height;
    final count = (size.width / toothWidth).ceil();

    if (isTop) {
      path.moveTo(0, toothHeight);
      for (int i = 0; i < count; i++) {
        final x = i * toothWidth;
        path.lineTo(x + toothWidth / 2, 0);
        path.lineTo(x + toothWidth, toothHeight);
      }
      path.lineTo(size.width, toothHeight);
      path.close();
    } else {
      path.moveTo(0, 0);
      for (int i = 0; i < count; i++) {
        final x = i * toothWidth;
        path.lineTo(x + toothWidth / 2, toothHeight);
        path.lineTo(x + toothWidth, 0);
      }
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
