# Token Monitor 移动端交接与架构备忘录 (HANDOFF)
> **致接手开发者 / AI 助手**：本文档记录了 Token Monitor 移动端工程中接入 **AI Passport 硬件随身副屏 BLE 蓝牙中继**、**工牌档案无线修改** 以及 **本地 65 秒极速编译系统** 的全部技术实现细节、避坑经验、已知边界与后续演进路线。

---

## 📌 一、当前版本号基线 (Version Info)

* **Git Release Tag**: `v1.1.7`
* **Release Name**: `Token Monitor Android v1.1.7 (支持手机端直接修改 AI Passport 副屏个人信息与工牌档案)`
* **Android Gradle 配置** (`mobile/android/app/build.gradle`):
  * `versionCode`: **`9`**
  * `versionName`: **`"1.1.7"`**
* **Flutter pubspec.yaml** (`mobile/pubspec.yaml`):
  * `version`: **`1.1.7+18`**
* **签名体系**: 保持使用工程内的官方正式 `release.keystore`（`mobile/android/app/release.keystore`，别名 `tokenmonitor`，密码 `tokenmonitor2026`），严格保证证书指纹一致，支持平滑覆盖安装。
* **编译产物位置**:
  * 根目录快捷打包: [`build_apk.bat`](file:///D:/PYTHON/APP/token%20monitor/build_apk.bat)
  * 本地生成 APK: [`mobile/build/app/outputs/flutter-apk/app-release.apk`](file:///D:/PYTHON/APP/token%20monitor/mobile/build/app/outputs/flutter-apk/app-release.apk) (22.62 MB)
  * 副屏工程交付位置: [`d:/PYTHON/Ai passport/TokenMonitor-v1.1.7-release.apk`](file:///d:/PYTHON/Ai%20passport/TokenMonitor-v1.1.7-release.apk)
  * GitHub 云端 Releases: [GitHub Releases v1.1.7](https://github.com/shuoYun114/token-monitor-android/releases/tag/v1.1.7) (私有仓库托管)

---

## 🛠️ 二、系统架构与新增核心模块 (Architecture & What Changed)

### 1. 随身硬件 BLE 中继通信层 (`PassportRelayService`)
* **文件路径**: [`mobile/lib/services/passport_relay_service.dart`](file:///D:/PYTHON/APP/token%20monitor/mobile/lib/services/passport_relay_service.dart)
* **协议与服务规范 (Nordic UART Service - NUS)**:
  * 主服务 UUID: `6e400001-b5a3-f393-e0a9-e50e24dcca9e`
  * RX 写入特征: `6e400002-b5a3-f393-e0a9-e50e24dcca9e` (手机 -> 开发板)
  * TX 监听通知: `6e400003-b5a3-f393-e0a9-e50e24dcca9e` (开发板 -> 手机)
* **网络时钟同步**:
  * 蓝牙握手连通后，手机端立刻向 RX 写入第一条指令：`{"time": [unix_timestamp, tz_offset]}\n`；
  * 彻底解决 ESP32-C3 离线断网后缺乏 RTC 电池导致的出门时间漂移问题。
* **64 字节安全分片与延时写入 (Chunking & Delay)**:
  * 针对 ESP32-C3 接收端 FIFO 缓冲区极小的硬件限制，将所有下发 JSON 报文以 64 字节分片；
  * 每包切片附带 `Future.delayed(Duration(milliseconds: 12))` 保护写入，彻底避免底层丢包与接收溢出。
* **固件数据契约匹配 (`pushStatsSnapshot`)**:
  * 将 `AggregateStats` 完整打包并映射为含 `tokens_today`, `cost_today_cents`, `codex` 配额以及 `tools` 细分列表的标准载荷。

### 2. 工牌身份档案无线修改与 NVS 固化
* **协议指令契约**:
  * 极客昵称更新: `{"cmd": "name", "name": "<昵称>", "value": "<昵称>"}\n`
  * 账号邮箱更新: `{"cmd": "owner", "name": "<账号>", "owner": "<账号>", "value": "<账号>"}\n`
* **边界保护**:
  * 自动进行前后空格去除，并在下发前截断为最长 30 字符，严格符合开发板固件 `BUDDY_NAME_MAX` 与 `BUDDY_OWNER_MAX` 边界；
  * 开发板收到后直接调用底层 `app_save_buddy_profile()` 固化写入 NVS 闪存并即时刷新屏幕，关机重启依然永久保存。
* **本地记忆机制**:
  * 手机端通过 [`AppSettings`](file:///D:/PYTHON/APP/token%20monitor/mobile/lib/models/app_settings.dart) 与 `StorageService` 将用户编辑的工牌档案保存在本地 `SharedPreferences`，每次打开 App 自动回显。

### 3. 全局状态响应流与自动中继
* **`PassportRelayProvider`**: 继承 `ChangeNotifier` 并在 `main.dart` 中挂载为全局 Provider，管理连接状态、设备名、上次同步时间等响应式数据；
* **`MonitorProvider`**: 在 `_handleStatsPayload` 处理完 Token 遥测数据后，无感调用 `PassportRelayService().pushStatsSnapshot(...)`，实现手机端获取新用量时副屏全自动静默刷新。

### 4. 界面与交互层 (`PassportRelayCard`)
* **文件路径**: [`mobile/lib/ui/widgets/passport_relay_card.dart`](file:///D:/PYTHON/APP/token%20monitor/mobile/lib/ui/widgets/passport_relay_card.dart)
* 延续暗黑机能风设计，包含微晶毛玻璃底板、状态呼吸指示灯与一键扫描直连按钮；
* 连接成功后平滑展开「工牌身份档案」编辑卡片与「保存并下发至副屏工牌」按钮，提供即时 SnackBar 反馈；
* 首页 AppBar 增加微标快捷按钮，设置页面顶部常驻控制卡片。

---

## ⚡ 三、本地 65 秒极速编译构建体系 (Local Build Pipeline)

为了摆脱云端 GitHub Actions 每次耗时 8 分多钟的低效等待，本地已在 **D 盘** 建立完整的纯命令行极速构建环境：

### 1. 环境目录与配置 (100% 隔离 C 盘)
* **Flutter SDK**: `D:\dev_tools\flutter` (v3.24.5 稳定版)
* **Android SDK**: `D:\dev_tools\android-sdk` (`cmdline-tools`, `build-tools 34.0.0`, `platforms;android-33`, `platforms;android-34`)
* **Gradle 缓存**: 环境变量 `GRADLE_USER_HOME=D:\dev_tools\.gradle`，强行重定向缓存至 D 盘，**系统 C 盘 0 字节侵占**；
* **国内镜像加速**:
  * `PUB_HOSTED_URL=https://pub.flutter-io.cn`
  * `FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn`
  * `android/settings.gradle` 和 `android/build.gradle` 已接入阿里云 Maven & Plugin 高速镜像源。

### 2. 架构优化与一键打包
* 默认打包命令已优化为主流 64 位单架构：
  ```bash
  flutter build apk --release --target-platform android-arm64
  ```
* 打包时间从 **8 分 15 秒 缩短至 65 秒**，包体由 **38.5MB 缩小至 22.6MB**；
* 根目录提供一键脚本：双击 [`build_apk.bat`](file:///D:/PYTHON/APP/token%20monitor/build_apk.bat) 即可全自动完成依赖解析、打包与产物自动复制。

---

## ⚠️ 四、技术防坑指南 (CRITICAL PITFALLS - 必读)

接手开发或继续迭代该模块时，**绝对不能违反以下原则**：

1. **绝对不要升级 `flutter_blue_plus` 到 `^1.34.0`**：
   * **原因**：`flutter_blue_plus 1.34+` 改用了 federated architecture 并引入 `flutter_blue_plus_android-7.x`，其内部 `build.gradle` 强制使用已废弃的 `compileSdkVersion flutter.compileSdkVersion`，在当前声明式 Gradle 体系下会导致构建直接报错中断。**必须严格锁定 `1.32.11` 稳定版本**。
2. **Windows 跨盘符编译崩溃陷阱 (`different roots`)**：
   * **现象**：当项目在 D 盘而 pub 依赖在 C 盘时，Kotlin 增量编译器计算相对路径时会抛出 `IllegalArgumentException: this and base files have different roots`；
   * **解决方案**：必须在 `mobile/android/gradle.properties` 中保持 `kotlin.incremental=false`。
3. **Android SDK 依赖必须同时具备 API 33 和 API 34**：
   * 主工程 targetSdk 为 34，但 `flutter_blue_plus` 插件的 compileSdk 为 33。本地 SDK 目录 `D:\dev_tools\android-sdk\platforms` 下必须同时保留 `android-33` 与 `android-34`。
4. **Gradle `afterEvaluate` 禁忌**：
   * 根目录 `android/build.gradle` 中不能在 `evaluationDependsOn(":app")` 之后再调用 `subprojects.afterEvaluate`，否则会引发 Gradle 生命周期错乱报错。

---

## 🔮 五、尚存局限与后续演进建议 (Roadmap)

1. **Android 后台 Doze 模式与长时间保活**：
   * **现状**：手机深度锁屏数十分钟后进入系统休眠，BLE 链路会被操作系统挂起或中断；
   * **演进方案**：后续若需要全天候锁屏不间断中继，可引入 Android `ForegroundService` 前台通知保活，并提示用户将 App 加入系统电池优化白名单。
2. **多设备配对选择器**：
   * **现状**：目前策略是扫描并直连附近发现的第一个匹配名称（如 `Codex-xxxx` 或 `AI-Passport`）的设备；
   * **演进方案**：若同一空间存在多块副屏，可在 UI 上弹出 BottomSheet 列表，展示扫描到的设备名称与 RSSI 信号强度供用户自选。
3. **断开后自动指数退避重连**：
   * **现状**：连接断开后为节省手机电量，需手动点击重连；
   * **演进方案**：增加带有指数退避（5s -> 15s -> 30s -> 60s）且最多重试 5 次的自动重连状态机。
