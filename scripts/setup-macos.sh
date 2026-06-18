#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null 2>&1 && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "请先安装 Homebrew：https://brew.sh"
  echo '安装命令：/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

brew update

brew install python@3.11 postgresql@16 cocoapods openjdk@17
brew install --cask flutter android-studio visual-studio-code android-commandlinetools

echo "Docker Desktop 需要 macOS sudo 权限创建系统链接。请优先用官网下载器或在终端手动安装。"

echo
echo "基础环境安装完成。"
echo "请手动安装完整 Xcode：打开 App Store，搜索 Xcode 并安装。"
echo "安装完成后运行：sudo xcodebuild -license accept"
echo "Flutter 检查命令：flutter doctor"
