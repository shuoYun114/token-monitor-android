# Token Monitor 移动端交接备忘录 (Handover Notes)
> **致原开发会话 / 接手开发者**：本文档记录了在移动端工程中接入 **AI Passport 硬件随身副屏 BLE 蓝牙中继** 的所有技术改动、现有功能矩阵、版本号定义以及已知边界/待优化项。

---

## 📌 一、当前版本号信息 (Version Info)

* **Git Release Tag**: `v1.1.6`
* **Release Name**: `Token Monitor Android v1.1.6 (新增 AI Passport 随身硬件副屏 BLE 中继)`
* **Android Gradle 配置** (`mobile/android/app/build.gradle`):
  * `versionCode`: **`8`** (上一版本为 7)
  * `versionName`: **`"1.1.6"`** (上一版本为 "1.0.6")
* **Flutter pubspec.yaml** (`mobile/pubspec.yaml`):
  * `version`: **`1.1.6+17`** (上一版本为 1.1.5+16)
* **签名体系**: 保持使用工程内的官方正式 `release.keystore`（密码一致），支持平滑覆盖安装。

---

## 🛠️ 二、本次修改了什么 (What Changed)

本次改动主要为了解决**“带着 AI Passport 开发板出门脱离电脑时无法同步数据与对齐时钟”**的问题，使手机 App 成为随身移动中继：

### 1. 依赖与底层权限
* **`mobile/pubspec.yaml`**:
  * 引入 `flutter_blue_plus: 1.32.11`（**注意：必须严格锁定 1.32.11，严禁升级到 `^1.34.0`，原因见下方注意事项**）。
* **`mobile/android/app/src/main/AndroidManifest.xml`**:
  * 增加 Android 12+ (API 31+) 现代蓝牙权限：`BLUETOOTH_SCAN (neverForLocation)` 与 `BLUETOOTH_CONNECT`（免申请敏感位置权限）；
  * 兼容低版本 Android 蓝牙权限 `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION (maxSdkVersion=30)`。

### 2. BLE 硬件中继通信层 (新建)
* **`mobile/lib/services/passport_relay_service.dart`**:
  * 采用单例设计，管理 Nordic UART Service (NUS) 连接；
  * **UUID 规范**:
    * 服务 UUID: `6e400001-b5a3-f393-e0a9-e50e24dcca9e`
    * RX 写入: `6e400002-b5a3-f393-e0a9-e50e24dcca9e` (手机 -> 开发板)
    * TX 通知: `6e400003-b5a3-f393-e0a9-e50e24dcca9e` (开发板 -> 手机)
  * **网络时间戳自动授时**: 连上后立即下发 `{"time": [unix_timestamp, tz_offset]}\n`，解决单片机无 RTC 电池导致出门时间不准问题；
  * **64 字节安全分片机制**: 将 JSON 报文按 64 字节切片并附带 12ms 延时写入，彻底防止 ESP32-C3 接收 FIFO 缓冲溢出丢包；
  * **固件协议匹配**: 将 `AggregateStats` 完整打包成含 `tokens_today`, `cost_today_cents`, `codex` 配额以及 `tools` 细分列表的标准载荷。

### 3. 状态管理流扩展
* **`mobile/lib/providers/passport_relay_provider.dart`**:
  * 封装 `PassportRelayProvider extends ChangeNotifier`，提供响应式连接状态、设备名、上次同步时间等状态与控制方法。
* **`mobile/lib/main.dart`**:
  * 在 `MultiProvider` 中注册 `PassportRelayProvider`。
* **`mobile/lib/providers/monitor_provider.dart`**:
  * 在 `_handleStatsPayload` 处理完数据并更新小组件后，无感挂载 `PassportRelayService().pushStatsSnapshot(...)`，实现手机拿到新 Token 消耗时自动向副屏静默推送。

### 4. 界面与交互层
* **`mobile/lib/ui/widgets/passport_relay_card.dart`**:
  * 遵循微晶毛玻璃与机能风设计，提供呼吸状态指示、设备标识码、一键直连、手动测试同步与断开按钮。
* **`mobile/lib/ui/screens/settings_screen.dart`**:
  * 设置页面列表开头常驻 `PassportRelayCard`。
* **`mobile/lib/ui/screens/home_screen.dart`**:
  * AppBar 右侧操作栏新增随身副屏快捷按钮（未连接灰显、已连接微光绿显），点击唤出底部控制面板。

### 5. 云端 CI/CD 自动化工作流
* **`.github/workflows/build-android.yml`**:
  * Release 发布说明与 Tag 更新为 `v1.1.6`。

---

## 📱 三、应用当前已具备的功能全景 (Feature Matrix)

1. **AI Compute Console 移动大屏总览**:
   * Bento Grid 航天机能风格面板；
   * 今日 / 本月 / 历史 Token 总量与折算人民币费用实时遥测；
   * 活跃客户端（Antigravity、Codex、Claude 等）与主力模型占比环形仪表盘。
2. **实时数据流与多端同步**:
   * 支持通过 SSE (Server-Sent Events) 长连接秒级同步桌面端/云端 Hub 算力；
   * 断网或离线时由 `shared_preferences` 提供离线镜像缓存，杜绝白屏。
3. **AI 消费小票 (Token Receipt) 撕纸与相册存图**:
   * 模拟热敏收银纸微刻排版与真实镂空撕纸锯齿；
   * 附带 AI 毒舌神吐槽文案；
   * 3.0x 超采样位图渲染，通过原生 Kotlin `MediaStore` Platform Channel 一键保存至手机系统相册（`Pictures/TokenMonitor`）。
4. **Android 桌面小组件 (`home_widget`)**:
   * 4x2、2x2 原生 AppWidget，支持桌面常驻显示今日 Token 与限额状态。
5. **黑白双主题切换**:
   * 黑曜石冰蓝 / 暖白色暖黄双套高质感配色。
6. **AI Passport 随身极客副屏 BLE 中继 (本次新增)**:
   * 随身外出携带场景下的无线低功耗中继与自动对时。

---

## ⚠️ 四、尚存限制、潜在边界与待优化点 (Known Limitations & Pending Bugs)

如果后续会话或开发者继续迭代该模块，请特别注意以下边界与优化空间：

1. **构建依赖陷阱 (CRITICAL - DO NOT TOUCH)**:
   * **严禁将 `flutter_blue_plus` 升级为 `^1.34.0`**！
   * **原因**：`flutter_blue_plus 1.34+` 改用了 federated architecture 并引入 `flutter_blue_plus_android-7.x`，其内部 `build.gradle` 强制评估 `compileSdkVersion flutter.compileSdkVersion`，在当前声明式 Gradle 插件体系下会报 `Could not get unknown property 'flutter' for extension 'android'`，导致云端 APK 编译中断。当前锁定 `1.32.11` 稳定版本是最优解。
2. **Android 系统后台 Doze 模式与长久保活**:
   * **现状**：当手机锁屏超过数十分钟进入 Android Doze 深度休眠、或系统内存吃紧杀死前台进程时，BLE 连接会被操作系统断开。
   * **待优化方案**：后续若需要支持全天候锁屏不间断中继，可引入 Android `ForegroundService`（前台通知保活服务），并在设置中引导用户加入系统“忽略电池优化”白名单。
3. **多设备配对选择弹窗**:
   * **现状**：当前的 `startAutoScanAndConnect` 策略是扫描并自动秒级直连附近出现的**第一个**匹配名称（如 `Codex-xxxx` 或 `AI-Passport`）的设备。
   * **待优化方案**：如果同一空间内有多块开发板，建议在 UI 上扩展一个底部 BottomSheet，列出扫描到的所有候选设备及其 RSSI 信号强度，允许用户点选特定设备进行绑定。
4. **断开后的智能重连策略**:
   * **现状**：连接断开后，为防止过度消耗手机电池，目前未开启无休止的高频重试轮询，需要用户在卡片上手动点击重新扫描连接。
   * **待优化方案**：可增加一个带有指数退避（5s -> 15s -> 30s -> 60s）且限制重试次数（如最多 5 次）的自动重连状态机。
