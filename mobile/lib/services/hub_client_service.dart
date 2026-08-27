import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device_stats.dart';

/// 负责与 Token Monitor Hub (Node.js Hub 或 Cloudflare Worker) 进行 SSE 长连接和 REST 同步
class HubClientService {
  StreamSubscription? _sseSubscription;
  http.Client? _streamingClient;

  /// 单次拉取聚合数据 (/api/stats)
  Future<Map<String, dynamic>> fetchStats({
    required String hubUrl,
    required String hubSecret,
  }) async {
    final baseUrl = hubUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('/api/stats');

    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': 'TokenMonitor-Android/1.0',
    };
    if (hubSecret.isNotEmpty) {
      headers['Authorization'] = 'Bearer ';
      headers['x-hub-secret'] = hubSecret;
    }

    final response = await http.get(uri, headers: headers).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      throw Exception('Hub 返回状态码: ');
    }
  }

  /// 建立 SSE 长连接实时流 (/api/stats/stream)
  void startStreaming({
    required String hubUrl,
    required String hubSecret,
    required Function(Map<String, dynamic> data) onData,
    required Function(dynamic error) onError,
  }) {
    stopStreaming();

    final baseUrl = hubUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('/api/stats/stream');

    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';
    request.headers['User-Agent'] = 'TokenMonitor-Android/1.0';
    if (hubSecret.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer ';
      request.headers['x-hub-secret'] = hubSecret;
    }

    _streamingClient = http.Client();

    _streamingClient!.send(request).then((response) {
      if (response.statusCode != 200) {
        onError('SSE 连接失败，状态码: ');
        return;
      }

      StringBuffer buffer = StringBuffer();

      _sseSubscription = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.startsWith('data:')) {
            final dataStr = line.substring(5).trim();
            if (dataStr.isNotEmpty && dataStr != '[DONE]') {
              try {
                final json = jsonDecode(dataStr) as Map<String, dynamic>;
                onData(json);
              } catch (e) {
                // 忽略非 JSON 行
              }
            }
          }
        },
        onError: (err) {
          onError(err);
        },
        cancelOnError: false,
      );
    }).catchError((err) {
      onError(err);
    });
  }

  void stopStreaming() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
    _streamingClient?.close();
    _streamingClient = null;
  }
}
