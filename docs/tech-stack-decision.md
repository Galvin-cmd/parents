# 技术栈决策

日期：2026-06-18

## 结论

豆小宝家长端正式工程建议采用：

- 客户端：Flutter
- 后端：FastAPI
- 数据库：PostgreSQL
- 缓存/异步任务：Redis，后续按需要加入
- 部署：Docker Compose 起步，后续迁移到云服务
- 当前 Web 原型：继续保留为演示和产品验证入口

## 为什么客户端选 Flutter

家长端后续会包含扫码绑定、推送、定位权限、相机、地图、音视频入口、设备状态和 App 上架。Flutter 对 iOS/Android 双端一致性、界面表现和移动端插件生态都比较适合。

当前 Web 原型不废弃，它继续承担三个角色：

- 对外演示
- 产品流程验证
- 后端接口联调参考

等接口和核心流程稳定后，再新建 Flutter App 工程。

## 为什么后端选 FastAPI

豆小宝后端会逐步包含 AI Agent、成长报告、任务建议、安全提醒、合规审计等能力。Python 生态对 AI、数据处理和快速 API 开发更顺。FastAPI 自带 OpenAPI 文档，适合前后端协作。

## 为什么数据库选 PostgreSQL

位置、任务、家庭成员、设备状态、操作记录、授权记录都属于结构化数据。PostgreSQL 稳定、通用、扩展能力强，适合从 MVP 到正式产品持续演进。

## 暂不优先选择

### React Native

React Native 也可做移动端，但当前团队和工程还没有 React 生态基础。Flutter 在视觉一致性和移动端工程闭环上更直接。

### NestJS

NestJS 适合 TypeScript 后端团队。如果未来后端团队以 Node.js 为主，可以重新评估。但当前 AI/报告能力会偏 Python，因此 FastAPI 更合适。

## 推荐工程结构

```text
parents/
├── apps/
│   ├── parent_flutter/     # 后续正式 Flutter 家长端
│   └── web_demo/           # 当前 Web 原型，可后续迁移
├── backend/
│   ├── app/                # FastAPI 正式后端骨架
│   ├── data/               # 本地演示数据
│   ├── tests/
│   └── requirements.txt
├── docs/
└── scripts/
```

## 当前执行顺序

1. 先保留 Web 原型，继续打磨演示链路。
2. 将现有 mock API 迁移到 FastAPI 骨架，接口路径保持 `/api/v1` 不变。
3. 安装 Flutter、Android Studio、Xcode、Python、Docker、PostgreSQL 等正式工程环境。
4. 后端补数据库模型、登录、家庭成员和设备绑定。
5. 后端接口稳定后，新建 Flutter App。
