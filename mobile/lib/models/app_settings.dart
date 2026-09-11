/// 应用本地配置模型
class AppSettings {
  String hubUrl;
  String hubSecret;
  String openRouterApiKey;
  String deepSeekApiKey;
  String currency; // 'CNY' or 'USD'
  double usdToCnyRate;
  int refreshIntervalSeconds;
  bool isConnected;
  String themeMode; // 'dark' (深色黑曜石+淡蓝) or 'light' (纯白+暖黄)
  String passportName; // AI Passport 随身副屏极客昵称 (展示在工牌中央顶部，最大30字符)
  String passportOwner; // AI Passport 绑定账号与邮箱 (展示在副屏资产第一行，最大30字符)

  AppSettings({
    this.hubUrl = '',
    this.hubSecret = '',
    this.openRouterApiKey = '',
    this.deepSeekApiKey = '',
    this.currency = 'CNY',
    this.usdToCnyRate = 6.7203, // 与桌面端官方保持完全一致
    this.refreshIntervalSeconds = 15,
    this.isConnected = false,
    this.themeMode = 'dark',
    this.passportName = 'syhx114514',
    this.passportOwner = 'syhx114514@gmail.com',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hubUrl: json['hubUrl']?.toString() ?? '',
      hubSecret: json['hubSecret']?.toString() ?? '',
      openRouterApiKey: json['openRouterApiKey']?.toString() ?? '',
      deepSeekApiKey: json['deepSeekApiKey']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'CNY',
      usdToCnyRate: (json['usdToCnyRate'] as num?)?.toDouble() ?? 6.7203,
      refreshIntervalSeconds: (json['refreshIntervalSeconds'] as num?)?.toInt() ?? 15,
      isConnected: json['isConnected'] == true,
      themeMode: json['themeMode']?.toString() ?? 'dark',
      passportName: json['passportName']?.toString() ?? 'syhx114514',
      passportOwner: json['passportOwner']?.toString() ?? 'syhx114514@gmail.com',
    );
  }

  Map<String, dynamic> toJson() => {
    'hubUrl': hubUrl,
    'hubSecret': hubSecret,
    'openRouterApiKey': openRouterApiKey,
    'deepSeekApiKey': deepSeekApiKey,
    'currency': currency,
    'usdToCnyRate': usdToCnyRate,
    'refreshIntervalSeconds': refreshIntervalSeconds,
    'isConnected': isConnected,
    'themeMode': themeMode,
    'passportName': passportName,
    'passportOwner': passportOwner,
  };
}
