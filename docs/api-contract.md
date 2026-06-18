# 后端接口草案

当前前端使用本地 mock 数据。后端开始实现时，可以先按下面的接口切分，保证“前端流程先跑通，接口逐步替换”。

## 通用约定

- Base URL：`/api/v1`
- 返回结构：

```json
{
  "code": 0,
  "message": "ok",
  "data": {}
}
```

- 时间使用 ISO 8601 字符串。
- 涉及定位、通讯录、健康、心情和聊天数据的接口，需要服务端校验家长权限。

## 前端启动数据

### 获取首页所需数据

`GET /bootstrap`

用途：前端启动时一次性获取演示所需的孩子、设备、定位、任务、管控、联系人和报告数据。后续正式工程可以改为分模块并行请求。

## 账号与家庭

### 获取当前家庭

`GET /families/current`

返回：

```json
{
  "familyId": "fam_001",
  "members": [
    {
      "id": "parent_001",
      "name": "妈妈",
      "role": "admin"
    }
  ],
  "children": [
    {
      "id": "child_001",
      "name": "豆豆",
      "age": 8,
      "className": "二年级 3 班"
    }
  ]
}
```

## 设备

### 获取设备状态

`GET /children/{childId}/device`

返回：

```json
{
  "deviceId": "watch_001",
  "model": "豆小宝 Watch S1",
  "online": true,
  "battery": 76,
  "phone": "138 1024 8848",
  "balance": 36.8,
  "dataUsageGb": 1.8,
  "dataLimitGb": 5,
  "lastSyncAt": "2026-06-18T23:12:00+08:00"
}
```

### 绑定设备

`POST /devices/bind`

请求：

```json
{
  "bindCode": "DXB-2026",
  "childId": "child_001"
}
```

## 定位安全

### 获取实时定位

`GET /children/{childId}/location/current`

返回：

```json
{
  "place": "星河小学北门",
  "latitude": 31.2304,
  "longitude": 121.4737,
  "accuracyMeters": 28,
  "status": "safe",
  "updatedAt": "2026-06-18T23:12:00+08:00"
}
```

### 获取今日轨迹

`GET /children/{childId}/location/tracks?date=2026-06-18`

### 获取守护区域

`GET /children/{childId}/geo-zones`

### 新增守护区域

`POST /children/{childId}/geo-zones`

请求：

```json
{
  "name": "外婆家",
  "type": "安全区",
  "range": "200m",
  "enabled": true
}
```

### 更新守护区域开关

`PATCH /geo-zones/{zoneId}`

请求：

```json
{
  "enabled": true
}
```

## 任务激励

### 获取任务列表

`GET /children/{childId}/tasks?date=2026-06-18`

### 创建任务

`POST /children/{childId}/tasks`

请求：

```json
{
  "title": "阅读课外书 15 分钟",
  "remindAt": "2026-06-18T19:30:00+08:00",
  "reward": 6
}
```

### 更新任务状态

`PATCH /tasks/{taskId}`

请求：

```json
{
  "done": true
}
```

## 管控

### 获取模式配置

`GET /children/{childId}/control/modes`

### 更新模式

`PATCH /children/{childId}/control/modes/{modeId}`

请求：

```json
{
  "enabled": true,
  "schedule": "周一至周五 08:00-16:30"
}
```

### 获取应用使用情况

`GET /children/{childId}/apps/usage?date=2026-06-18`

### 更新应用启用状态

`PATCH /children/{childId}/apps/{appId}`

请求：

```json
{
  "enabled": false
}
```

## 通讯录

### 获取白名单联系人

`GET /children/{childId}/contacts`

### 新增联系人

`POST /children/{childId}/contacts`

请求：

```json
{
  "name": "外婆",
  "relation": "家人",
  "phone": "137 0000 7788",
  "trusted": true
}
```

## Agent

### 发送 Agent 指令

`POST /children/{childId}/agent/messages`

请求：

```json
{
  "text": "今晚 19:30 提醒豆豆阅读 15 分钟"
}
```

返回：

```json
{
  "reply": "已创建 19:30 阅读提醒，并同步到手表。",
  "actions": [
    {
      "type": "task.created",
      "taskId": "task_001"
    }
  ]
}
```

### 获取成长周报

`GET /children/{childId}/reports/weekly?week=2026-W25`

返回：

```json
{
  "stars": 42,
  "steps": 8650,
  "sleep": "9h 10m",
  "mood": "平稳",
  "insights": [
    "建议把娱乐模式放在作业完成后开启。"
  ],
  "disclaimer": "健康和心情数据仅作辅助观察，不构成医疗或心理诊断。"
}
```
