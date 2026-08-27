# Token Monitor for Android (移动端 & 桌面小组件)

这是 [Token Monitor](https://github.com/Javis603/token-monitor) 的 Android 移动客户端与桌面小组件移植版本。

---

## 🌟 核心特性

1. **移动端实时看板**：
   - 通过 SSE (Server-Sent Events) 长连接或定时轮询连接 Token Monitor 聚合中心（Node Hub 或 Cloudflare Worker Hub）；
   - 实时显示全设备（Mac / PC / Linux）与单设备的今日/本月 Token 消耗与费用（支持 ¥ CNY / $ USD 实时汇率切换）；
   - 展现 Claude Code、Codex、Cursor、Antigravity、OpenCode 等 32+ 款 AI 编程工具的细分用量与状态。

2. **AI 额度与余额中心**：
   - 实时同步与展示 Claude / OpenAI 多账号 5 小时 Session 窗口速率、每周上限；
   - 支持在手机端直接输入 API Key 独立探测 OpenRouter 信用额度、DeepSeek 预付余额等。

3. **Android 桌面原生小组件 (Home Screen AppWidget)**：
   - 提供 **4x2**（大号综合面板）与 **2x2**（中号紧凑看板）两种尺寸；
   - 随时在手机桌面、负一屏一眼掌握今日花费、Token 数量与 Claude 额度重置时间。

4. **秒级扫码配对**：
   - 支持扫描桌面版 Token Monitor「多设备同步」中展示的二维码一键完成配对连接。

---

## 🛠️ 项目结构

```
mobile/
├── pubspec.yaml                 # Flutter 依赖与资产配置
├── lib/
│   ├── main.dart                # 应用入口与底部多 Tab 导航控制器
│   ├── models/                  # 数据模型层 (用量、设备、提供商额度、设置)
│   ├── services/                # 网络通信层 (Hub SSE流、Direct API探测、本地存储、小部件桥接)
│   ├── providers/               # 全局响应式状态管理 (MonitorProvider)
│   ├── theme/                   # 黑曜石深色 + 赛博毛玻璃视觉体系
│   └── ui/
│       ├── screens/             # 主看板、额度中心、设备管理、设置、扫码页面
│       └── widgets/             # 毛玻璃卡片、环形仪表盘、工具卡片、状态胶囊
└── android/
    └── app/src/main/
        ├── AndroidManifest.xml  # Android 权限与 AppWidget 接收器声明
        ├── kotlin/              # 原生 Kotlin 小部件 Provider
        └── res/                 # 2x2 与 4x2 桌面小部件 XML 布局
```

---

## 🚀 运行与构建指南

### 1. 本地调试运行
```bash
cd mobile
flutter pub get
flutter run
```

### 2. 构建 Android APK 安装包
```bash
cd mobile
flutter build apk --release
```
生成的安装包位于：`mobile/build/app/outputs/flutter-apk/app-release.apk`。

---

## 📱 添加桌面小组件方法

1. 安装并在手机上打开一次 **Token Monitor**，在「设置」中完成 Hub 配对或 API 密钥录入；
2. 长按手机主屏幕空白区域 -> 点击「小组件 / 微件 (Widgets)」；
3. 在列表中找到 **Token Monitor**，选择 **2x2** 或 **4x2** 尺寸并拖动到桌面即可。
