# 本地开发环境

日期：2026-06-18

## 已安装

- Homebrew：已安装到 `/opt/homebrew`
- Flutter：已安装，`flutter doctor` 通过 Flutter 本体检查
- Android Studio：已安装到 `/Applications/Android Studio.app`
- Android SDK：已安装，Flutter Android toolchain 已通过
- VS Code：已安装到 `/Applications/Visual Studio Code.app`
- Python 3.11：已安装
- FastAPI 项目虚拟环境：已创建 `.venv`
- PostgreSQL 16：已安装并启动
- CocoaPods：已安装
- OpenJDK 17：已安装，用于 Android SDK

## 还需要手动完成

### Xcode

完整 Xcode 需要从 App Store 或 Apple Developer 网站手动安装。安装完成后运行：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

### Docker Desktop

Docker Desktop 的 Homebrew cask 安装需要 sudo 密码创建系统命令链接，Codex 无法代输密码。建议二选一：

1. 从 Docker 官网下载 Docker Desktop 并拖入 Applications。
2. 在你自己的终端运行：

```bash
brew install --cask docker-desktop
```

## 推荐加入 shell 配置

为了让终端长期识别 Homebrew、Python、Flutter 和 Android SDK，建议把下面内容加入 `~/.zshrc`：

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

保存后执行：

```bash
source ~/.zshrc
```

## 常用检查命令

```bash
flutter doctor
python3.11 --version
psql --version
pod --version
```

## 后端启动

```bash
cd "/Users/galvin/Documents/家长端app"
.venv/bin/python -m uvicorn backend.app.main:app --reload
```

接口文档：

```text
http://127.0.0.1:8000/docs
```
