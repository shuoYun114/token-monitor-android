# GEMINI.md - Token Monitor 开发者与开发智能体硬性规范

本文档记录本项目的核心硬性规范、自动化构建要求以及 Git 提交准则。所有开发智能体（Antigravity / Gemini / Claude Code 等）及贡献者必须严格遵守。

---

## 📌 核心硬性要求 (Strict Rules)

### 1. 自动 Git Commit 提交规范 (Micro-Commits)
- **触发时机**：每次完成一个独立微功能、修复 Bug、更新配置或达成阶段性验证后，**必须自动执行 Git Commit**。
- **提交信息格式**：严格使用标准化语义前缀：
  - `feat:` 新增功能（如移动端看板、桌面微件、新 Provider 支持）
  - `fix:` 修复 Bug 或逻辑缺陷
  - `refactor:` 代码重构与架构优化
  - `docs:` 文档与说明书更新
  - `ci:` GitHub Actions / CI 工作流调整
  - `style:` 格式调整（不影响代码逻辑）
- **安全检查**：提交前确认 Git 仓库已正确初始化并关联远程仓库。

### 2. GitHub Actions 云端自动构建 APK
- 移动端 Android 客户端（`mobile/`）的构建由 GitHub Actions 云端工作流 `.github/workflows/build-android.yml` 自动接管。
- 每次向 `main`/`master` 分支推送 `mobile/**` 代码或手动触发工作流时，GitHub 云端会自动配置 Java 17 + Flutter 3.24.0 环境，自动拉取依赖并编译出 **`token-monitor-android-release-apk`**。
- 构建生成的 APK 文件保留 30 天，可直接在 GitHub Actions Artifacts 页面点击下载并安装到安卓手机。

### 3. 项目架构与本地优先原则 (Local-First)
- **多端同步**：移动端通过 SSE 长连接与 REST 接口与 Node Hub 或 Cloudflare Worker Hub 通信。
- **离线展示**：手机在断网或 Hub 离线时必须支持本地缓存展示，杜绝白屏或加载阻塞。
- **语言规范**：代码注释与说明文档统一使用**简体中文 (Simplified Chinese)**。

---

## 🚀 常用开发与构建命令

```bash
# 启动桌面版开发
npm start

# 启动 Hub 服务
npm run hub

# 移动端 (需本地安装 Flutter 环境时使用)
cd mobile
flutter pub get
flutter run
flutter build apk --release
```
