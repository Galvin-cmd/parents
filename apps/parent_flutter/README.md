# 豆小宝家长端 Flutter

这是豆小宝家长端的正式 Flutter 客户端工程，当前保留与 Web 原型一致的接口路径。

## 运行

```bash
flutter run
```

默认接口：

- Android 模拟器：`http://10.0.2.2:8000/api/v1`
- iOS 模拟器：`http://127.0.0.1:8000/api/v1`

如果后端没有启动，App 会自动使用本地演示数据，方便继续看页面和流程。

## 构建

Android 调试 APK：

```bash
flutter build apk --debug
```

产物位置：

```text
build/app/outputs/flutter-apk/app-debug.apk
```

iOS 模拟器构建：

```bash
flutter build ios --simulator
```

产物位置：

```text
build/ios/iphonesimulator/Runner.app
```

正式 iOS 真机包和上架包还需要 Apple Developer 账号、Bundle ID 和签名配置。
