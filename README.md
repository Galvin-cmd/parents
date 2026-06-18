# 豆小宝家长端

这是根据 MVP 优先级搭建的前端流程原型，当前不依赖后端接口，使用本地 mock 数据完成主要交互。

## 在线预览

GitHub Pages 发布后可访问：

https://galvin-cmd.github.io/parents/

发布来源使用 GitHub Actions。

## 已覆盖

- 工作台：孩子状态、快捷呼叫、实时定位入口、家庭 Agent、今日任务
- 安全：定位卡片、守护区域、历史轨迹、寻找手表入口
- 成长：任务激励、成长周报、运动/睡眠/心情辅助观察、下周行动入口
- 管控：学习/睡眠/娱乐模式、应用禁用、通讯白名单、陌生人拒接
- 我的：设备绑定、成员管理、SIM/流量、客服售后、AI 与隐私设置

## 运行

直接打开 `index.html` 即可预览。也可以在项目目录运行：

```bash
python3 backend/server.py
```

然后访问 `http://127.0.0.1:5173`。这个服务会同时提供前端页面和 `/api/v1` mock 接口。

本地服务会把任务、联系人、守护区域和管控开关保存到 `backend/data/store.json`。这个文件是运行数据，不会提交到 GitHub。

## 后续路线

下一阶段建议见：

- [`docs/next-steps.md`](./docs/next-steps.md)：迭代路线
- [`docs/mvp-scope.md`](./docs/mvp-scope.md)：MVP 范围
- [`docs/api-contract.md`](./docs/api-contract.md)：后端接口草案

## 提交脚本

如果 Codex 暂时不能直接写入 Git，可以运行：

```bash
./scripts/push.sh "提交说明"
```

工作区写入权限开启后，Codex 会在完成改动后优先尝试运行这个脚本。
