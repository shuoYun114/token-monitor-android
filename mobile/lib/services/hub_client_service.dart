import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 负责与 Token Monitor Hub (Node.js Hub 或 Cloudflare Worker) 进行 SSE 长连接和 REST 同步
class HubClientService {
  StreamSubscription? _sseSubscription;
  http.Client? _streamingClient;

  static String normalizeHubUrl(String rawUrl) {
    String url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    return url.replaceAll(RegExp(r'/+$'), '');
  }

  static Map<String, String> buildHeaders(String secret) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': 'TokenMonitor-Android/1.0',
    };
    final trimmedSecret = secret.trim();
    if (trimmedSecret.isNotEmpty) {
      headers['Authorization'] = 'Bearer $trimmedSecret';
      headers['x-token-monitor-secret'] = trimmedSecret;
      headers['x-hub-secret'] = trimmedSecret;
    }
    return headers;
  }

  /// 单次拉取聚合数据 (/api/stats)
  Future<Map<String, dynamic>> fetchStats({
    required String hubUrl,
    required String hubSecret,
  }) async {
    final baseUrl = normalizeHubUrl(hubUrl);
    final uri = Uri.parse('$baseUrl/api/stats');
    final headers = buildHeaders(hubSecret);

    try {
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;
      } else if (response.statusCode == 401) {
        throw Exception('401 密钥不匹配 (请检查 Secret)');
      } else if (response.statusCode == 404) {
        throw Exception('404 接口未找到 (请检查 Hub URL)');
      } else {
        throw Exception('HTTP ${response.statusCode} 错误');
      }
    } on SocketException catch (e) {
      throw Exception('网络连接失败 (${e.message}，请确保手机与电脑在同一WiFi)');
    } on TimeoutException {
      throw Exception('连接超时 (请检查电脑 IP 是否正确、防火墙是否放行 17321 端口)');
    } catch (e) {
      rethrow;
    }
  }

  /// 单次拉取全量历史数据 (/api/history)
  Future<Map<String, dynamic>> fetchHistory({
    required String hubUrl,
    required String hubSecret,
  }) async {
    final baseUrl = normalizeHubUrl(hubUrl);
    final uri = Uri.parse('$baseUrl/api/history');
    final headers = buildHeaders(hubSecret);

    try {
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;
      } else {
        throw Exception('拉取历史数据失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
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

    final baseUrl = normalizeHubUrl(hubUrl);
    final uri = Uri.parse('$baseUrl/api/stats/stream');

    final request = http.Request('GET', uri);
    final headers = buildHeaders(hubSecret);
    request.headers.addAll(headers);
    request.headers['Accept'] = 'text/event-stream';
    request.headers['Cache-Control'] = 'no-cache';

    _streamingClient = http.Client();

    _streamingClient!.send(request).then((response) {
      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          onError('401 密钥不匹配');
        } else {
          onError('SSE 连接返回 ${response.statusCode}');
        }
        return;
      }

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
              } catch (_) {}
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
