class AppSettings {
  String hubUrl;
  String hubSecret;
  bool isConnected;
  String currency; // 'USD' 或 'CNY'
  double usdToCnyRate;
  int refreshIntervalSeconds;
  bool enableNotifications;
  double alertThresholdPercent;

  // Direct API Keys (手机端独立直连查询)
  String openRouterApiKey;
  String deepSeekApiKey;
  String miniMaxApiKey;

  AppSettings({
    this.hubUrl = '',
    this.hubSecret = '',
    this.isConnected = false,
    this.currency = 'CNY',
    this.usdToCnyRate = 7.25,
    this.refreshIntervalSeconds = 10,
    this.enableNotifications = true,
    this.alertThresholdPercent = 85.0,
    this.openRouterApiKey = '',
    this.deepSeekApiKey = '',
    this.miniMaxApiKey = '',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hubUrl: json['hubUrl']?.toString() ?? '',
      hubSecret: json['hubSecret']?.toString() ?? '',
      isConnected: json['isConnected'] as bool? ?? false,
      currency: json['currency']?.toString() ?? 'CNY',
      usdToCnyRate: (json['usdToCnyRate'] as num?)?.toDouble() ?? 7.25,
      refreshIntervalSeconds: (json['refreshIntervalSeconds'] as num?)?.toInt() ?? 10,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      alertThresholdPercent: (json['alertThresholdPercent'] as num?)?.toDouble() ?? 85.0,
      openRouterApiKey: json['openRouterApiKey']?.toString() ?? '',
      deepSeekApiKey: json['deepSeekApiKey']?.toString() ?? '',
      miniMaxApiKey: json['miniMaxApiKey']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'hubUrl': hubUrl,
    'hubSecret': hubSecret,
    'isConnected': isConnected,
    'currency': currency,
    'usdToCnyRate': usdToCnyRate,
    'refreshIntervalSeconds': refreshIntervalSeconds,
    'enableNotifications': enableNotifications,
    'alertThresholdPercent': alertThresholdPercent,
    'openRouterApiKey': openRouterApiKey,
    'deepSeekApiKey': deepSeekApiKey,
    'miniMaxApiKey': miniMaxApiKey,
  };
}
