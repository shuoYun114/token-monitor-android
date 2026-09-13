# 更新日志 (CHANGELOG)

本项目遵循 [Semantic Versioning 2.0.0](https://semver.org/lang/zh-CN/) 语义化版本规范。

---

## [v1.1.7] - 2026-09-11

### 🚀 新增特性 (Features)
* **副屏工牌身份档案无线修改 (Hardware Profile Editor)**：
  * 在随身硬件副屏卡片（`PassportRelayCard`）内新增「工牌身份档案」编辑表单，支持直连修改开发板上的 **极客昵称 (Name)** 与 **通行证账号/邮箱 (Owner)**；
  * 输入框内置空格自动去除与 30 字符截断保护，严格契合开发板固件的 `BUDDY_NAME_MAX` 与 `BUDDY_OWNER_MAX` 边界；
  * 点击「保存并下发至副屏工牌」按钮后，通过 BLE NUS 通道无线下发并调用开发板 ESP32 的 NVS 闪存接口直接固化，屏幕即时重绘，断电关机依然永久保留；
  * 手机本地通过 `AppSettings` 和 `StorageService` 自动持久化记忆上次输入的档案信息，每次进入 App 自动回填。

### 🛠️ 编译系统与工程优化 (Build & Performance)
* **本地极速编译环境 (Local Build Acceleration)**：
  * 在 `D:\dev_tools` 部署纯命令行 Flutter 3.24.5 + Android SDK 构建链，打包时间从云端 GitHub Actions 的 **8 分多钟彻底缩减至 65 秒**；
  * 针对主流 Android 设备全面优化 `--target-platform android-arm64`，安装包体积由 **38.5 MB 大幅精简至 22.6 MB**（瘦身 41%）；
  * 在 `android/build.gradle` 与 `android/settings.gradle` 中配置阿里云 Maven 与 Gradle Plugin 国内高速镜像，免去海外网络超时丢包困扰；
  * 根目录新增一键打包脚本 [`build_apk.bat`](file:///D:/PYTHON/APP/token%20monitor/build_apk.bat)，双击即可在 1 分钟内打出正式签名的 Release APK。

### 🐛 缺陷修复 (Bug Fixes)
* **修复 Windows 跨盘符编译崩溃**：
  * 针对 Kotlin 增量编译在不同驱动器（C 盘 Pub 缓存与 D 盘工程源码）之间抛出 `java.lang.IllegalArgumentException: this and base files have different roots` 的已知 Bug，在 `android/gradle.properties` 中添加 `kotlin.incremental=false` 进行彻底加固；
* **补齐 Android 33 编译依赖**：
  * 本地补全 `platforms;android-33`，解决 `flutter_blue_plus` 编译生成资源 R 文件时的 SDK 缺失报错。

---

## [v1.1.6] - 2026-09-11

### 🚀 新增特性 (Features)
* **AI Passport 随身极客副屏 BLE 蓝牙中继 (Hardware BLE Relay)**：
  * 接入 FoloToy AI Passport 硬件平台（ESP32-C3），手机作为移动随身中继，外出携带时全天候无线同步算力数据；
  * **网络时间戳自动校准**：手机与副屏建立连接后立即下发 `{"time": [unix_timestamp, tz_offset]}`，解决开发板脱离 PC 后无 RTC 电池导致时钟偏移的问题；
  * **64 字节安全分片流**：通过 Nordic UART Service (NUS) RX 通道以 64 字节分片并附带 12ms 延时写入，彻底杜绝单片机 FIFO 缓冲溢出；
  * **全自动静默推送**：当手机通过 SSE 长连接或定时轮询获取最新 Token 消耗时，自动增量推送至副屏；
  * **机能风控制面板**：
    * 提供呼吸状态指示灯、硬件 MAC/名称识别、一键快速扫描直连、手动强制测试同步与断开功能；
    * App 首页顶部 AppBar 增加硬件副屏快捷图标，点击唤起底部悬浮控制台。

### 📦 依赖与权限 (Dependencies & Permissions)
* 引入 `flutter_blue_plus: 1.32.11`（锁定稳定版本）；
* 在 `AndroidManifest.xml` 中适配 Android 12+ (API 31+) 现代蓝牙权限（`BLUETOOTH_SCAN neverForLocation`, `BLUETOOTH_CONNECT`）及低版本兼容权限。

---

## [v1.0.6 及之前版本] - 历史基线特性 (Baseline)

* **AI Compute Console 移动大屏总览**：
  * 采用 Bento Grid 航天机能风格面板；
  * 实时遥测今日、本月与历史 Token 消耗及人民币折算费用；
  * 活跃客户端（Antigravity、Codex、Claude 等）与主力模型配额占比环形遥测图表。
* **实时数据同步体系**：
  * 基于 SSE (Server-Sent Events) 的低延迟多端数据同步；
  * 本地 SharedPreferences 离线镜像缓存，无网环境秒开不白屏。
* **AI 消费小票 (Token Receipt) 趣味互动**：
  * 模拟热敏收银纸微刻排版与真实镂空撕纸锯齿交互；
  * 附带 AI 毒舌神吐槽文案；
  * 3.0x 超采样位图渲染与原生 Kotlin MediaStore 相册无损保存通道。
* **桌面微件与质感主题**：
  * 2x2 与 4x2 Android 原生 AppWidget 桌面小组件；
  * 黑曜石冰蓝与暖白暖黄双套高质感配色切换。
