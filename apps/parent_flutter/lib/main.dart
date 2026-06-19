import 'package:flutter/material.dart';

import 'src/api_client.dart';
import 'src/app_state.dart';
import 'src/mock_data.dart';

void main() {
  runApp(const ParentApp());
}

class ParentApp extends StatelessWidget {
  const ParentApp({super.key, this.initialData});

  final BootstrapData? initialData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '豆小宝家长端',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1CA7A8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'PingFang SC',
      ),
      home: HomeShell(initialData: initialData),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialData});

  final BootstrapData? initialData;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _apiClient = ApiClient();
  final _agentController = TextEditingController();
  BootstrapData _data = mockBootstrapData;
  bool _loading = true;
  bool _apiReady = false;
  int _index = 0;
  String _agentReply = '今天路线稳定，放学后可以安排阅读任务。';

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _data = widget.initialData!;
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _agentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _apiClient.bootstrap();
      if (!mounted) return;
      setState(() {
        _data = data;
        _apiReady = true;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _data = mockBootstrapData;
        _apiReady = false;
        _loading = false;
      });
    }
  }

  Future<void> _bindDevice() async {
    final code = await _textSheet(
      title: '绑定设备',
      label: '绑定码',
      initialValue: 'DXB-2026',
      action: '绑定',
    );
    if (code == null) return;
    await _runAction(() => _apiClient.bindDevice(_data.child.id, code));
    setState(() {
      _data = _data.copyWith(child: _data.child.copyWith(lastSync: '刚刚'));
    });
    _toast('设备已绑定并同步');
  }

  Future<void> _addTask() async {
    final title = await _textSheet(
      title: '新建任务',
      label: '任务内容',
      initialValue: '阅读课外书 15 分钟',
      action: '创建',
    );
    if (title == null) return;
    final fallback = TaskItem(
      id: 'task_local_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      time: '19:30',
      reward: 6,
      done: false,
    );
    TaskItem task = fallback;
    await _runAction(() async {
      task = await _apiClient.createTask(_data.child.id, title, '19:30', 6);
    });
    setState(() {
      _data = _data.copyWith(tasks: [task, ..._data.tasks]);
    });
    _toast('任务已加入今日计划');
  }

  Future<void> _addContact() async {
    final name = await _textSheet(
      title: '新增联系人',
      label: '联系人姓名',
      initialValue: '外婆',
      action: '添加',
    );
    if (name == null) return;
    final fallback = ContactItem(
      id: 'contact_local_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      relation: '家人',
      phone: '137 0000 7788',
    );
    ContactItem contact = fallback;
    await _runAction(() async {
      contact = await _apiClient.createContact(
        _data.child.id,
        name,
        '家人',
        '137 0000 7788',
      );
    });
    setState(() {
      _data = _data.copyWith(contacts: [..._data.contacts, contact]);
    });
    _toast('联系人已加入白名单');
  }

  Future<void> _toggleTask(TaskItem task) async {
    final next = !task.done;
    setState(() {
      _data = _data.copyWith(
        tasks: _data.tasks
            .map(
              (item) => item.id == task.id ? item.copyWith(done: next) : item,
            )
            .toList(),
      );
    });
    await _runAction(() => _apiClient.updateTask(task.id, next), silent: true);
  }

  Future<void> _toggleZone(GeoZone zone) async {
    final next = !zone.enabled;
    setState(() {
      _data = _data.copyWith(
        zones: _data.zones
            .map(
              (item) =>
                  item.id == zone.id ? item.copyWith(enabled: next) : item,
            )
            .toList(),
      );
    });
    await _runAction(() => _apiClient.updateZone(zone.id, next), silent: true);
  }

  Future<void> _toggleMode(ControlMode mode) async {
    final next = !mode.active;
    setState(() {
      _data = _data.copyWith(
        modes: _data.modes
            .map(
              (item) => item.id == mode.id ? item.copyWith(active: next) : item,
            )
            .toList(),
      );
    });
    await _runAction(
      () => _apiClient.updateMode(_data.child.id, mode.id, next),
      silent: true,
    );
  }

  Future<void> _toggleApp(AppUsage app) async {
    final next = !app.enabled;
    setState(() {
      _data = _data.copyWith(
        apps: _data.apps
            .map(
              (item) => item.id == app.id ? item.copyWith(enabled: next) : item,
            )
            .toList(),
      );
    });
    await _runAction(
      () => _apiClient.updateApp(_data.child.id, app.id, next),
      silent: true,
    );
  }

  Future<void> _sendAgent() async {
    final text = _agentController.text.trim();
    if (text.isEmpty) return;
    _agentController.clear();
    setState(() => _agentReply = '正在处理：$text');
    String reply = '已创建提醒任务，并同步到今日任务列表。';
    await _runAction(() async {
      reply = await _apiClient.sendAgentMessage(_data.child.id, text);
      final fresh = await _apiClient.bootstrap();
      if (mounted) _data = fresh;
    }, silent: true);
    if (!mounted) return;
    setState(() => _agentReply = reply);
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    bool silent = false,
  }) async {
    if (!_apiReady) return;
    try {
      await action();
    } catch (_) {
      if (!silent) _toast('本地演示已完成，后端暂未同步');
    }
  }

  Future<String?> _textSheet({
    required String title,
    required String label,
    required String initialValue,
    required String action,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: Text(action),
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    return result == null || result.isEmpty ? null : result;
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      WorkbenchPage(
        data: _data,
        loading: _loading,
        apiReady: _apiReady,
        agentController: _agentController,
        agentReply: _agentReply,
        onBindDevice: _bindDevice,
        onAddTask: _addTask,
        onToggleTask: _toggleTask,
        onSendAgent: _sendAgent,
      ),
      SafetyPage(data: _data, onToggleZone: _toggleZone),
      GrowthPage(data: _data, onToggleTask: _toggleTask),
      ControlPage(
        data: _data,
        onToggleMode: _toggleMode,
        onToggleApp: _toggleApp,
      ),
      ProfilePage(data: _data, onAddContact: _addContact),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: '工作台',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_rounded),
            label: '安全',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_rounded),
            label: '成长',
          ),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: '管控'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: '我的'),
        ],
      ),
    );
  }
}

class WorkbenchPage extends StatelessWidget {
  const WorkbenchPage({
    super.key,
    required this.data,
    required this.loading,
    required this.apiReady,
    required this.agentController,
    required this.agentReply,
    required this.onBindDevice,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onSendAgent,
  });

  final BootstrapData data;
  final bool loading;
  final bool apiReady;
  final TextEditingController agentController;
  final String agentReply;
  final VoidCallback onBindDevice;
  final VoidCallback onAddTask;
  final ValueChanged<TaskItem> onToggleTask;
  final VoidCallback onSendAgent;

  @override
  Widget build(BuildContext context) {
    final done = data.tasks.where((task) => task.done).length;
    return AppScrollView(
      title: '豆小宝',
      subtitle: loading
          ? '正在同步数据'
          : apiReady
          ? '已连接本地后端'
          : '演示数据模式',
      action: IconButton.filledTonal(
        onPressed: onBindDevice,
        icon: const Icon(Icons.add_rounded),
        tooltip: '添加设备',
      ),
      children: [
        ChildHero(child: data.child, location: data.location),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                color: const Color(0xFF2BAE66),
                icon: Icons.battery_charging_full_rounded,
                label: '电量',
                value: '${data.child.battery}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                color: const Color(0xFFFFB000),
                icon: Icons.stars_rounded,
                label: '星星',
                value: '${data.reports.stars}',
              ),
            ),
          ],
        ),
        SectionHeader(title: '快捷操作', trailing: '${data.child.lastSync}同步'),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            QuickAction(
              icon: Icons.call_rounded,
              label: '呼叫',
              onTap: () => showInfo(context, '正在呼叫 ${data.child.phone}'),
            ),
            QuickAction(
              icon: Icons.videocam_rounded,
              label: '视频',
              onTap: () => showInfo(context, '视频请求已发送'),
            ),
            QuickAction(
              icon: Icons.my_location_rounded,
              label: '定位',
              onTap: () => showInfo(context, data.location.place),
            ),
            QuickAction(
              icon: Icons.notifications_active_rounded,
              label: '找表',
              onTap: () => showInfo(context, '手表将响铃 60 秒'),
            ),
          ],
        ),
        AgentCard(
          controller: agentController,
          reply: agentReply,
          onSend: onSendAgent,
        ),
        SectionHeader(title: '今日任务', trailing: '$done/${data.tasks.length} 完成'),
        ...data.tasks.map(
          (task) => TaskTile(task: task, onTap: () => onToggleTask(task)),
        ),
        FilledButton.icon(
          onPressed: onAddTask,
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('新建任务'),
        ),
      ],
    );
  }
}

class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key, required this.data, required this.onToggleZone});

  final BootstrapData data;
  final ValueChanged<GeoZone> onToggleZone;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      title: '安全',
      subtitle: '位置守护',
      children: [
        ColorPanel(
          color: const Color(0xFF3C91E6),
          icon: Icons.location_on_rounded,
          title: data.location.place,
          body:
              '${data.location.status} · 精度 ${data.location.accuracy} · ${data.location.updatedAt}',
        ),
        const SectionHeader(title: '今日轨迹'),
        ...data.tracks.map((track) => TimelineTile(track: track)),
        const SectionHeader(title: '守护区域'),
        ...data.zones.map(
          (zone) => PlainTile(
            icon: zone.enabled ? Icons.shield_rounded : Icons.shield_outlined,
            title: zone.name,
            subtitle: '${zone.type} · ${zone.range}',
            active: zone.enabled,
            trailing: Switch(
              value: zone.enabled,
              onChanged: (_) => onToggleZone(zone),
            ),
          ),
        ),
      ],
    );
  }
}

class GrowthPage extends StatelessWidget {
  const GrowthPage({super.key, required this.data, required this.onToggleTask});

  final BootstrapData data;
  final ValueChanged<TaskItem> onToggleTask;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      title: '成长',
      subtitle: '习惯与健康概览',
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                color: const Color(0xFFE45B78),
                icon: Icons.directions_walk_rounded,
                label: '步数',
                value: '${data.reports.steps}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                color: const Color(0xFF7B61FF),
                icon: Icons.bedtime_rounded,
                label: '睡眠',
                value: data.reports.sleep,
              ),
            ),
          ],
        ),
        ColorPanel(
          color: const Color(0xFFFF7A59),
          icon: Icons.mood_rounded,
          title: '今日状态 ${data.reports.mood}',
          body: '建议把娱乐模式放在作业完成后开启。',
        ),
        const SectionHeader(title: '可奖励任务'),
        ...data.tasks.map(
          (task) => TaskTile(task: task, onTap: () => onToggleTask(task)),
        ),
      ],
    );
  }
}

class ControlPage extends StatelessWidget {
  const ControlPage({
    super.key,
    required this.data,
    required this.onToggleMode,
    required this.onToggleApp,
  });

  final BootstrapData data;
  final ValueChanged<ControlMode> onToggleMode;
  final ValueChanged<AppUsage> onToggleApp;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      title: '管控',
      subtitle: '模式和应用',
      children: [
        const SectionHeader(title: '手表模式'),
        ...data.modes.map(
          (mode) => PlainTile(
            icon: mode.active
                ? Icons.toggle_on_rounded
                : Icons.toggle_off_rounded,
            title: mode.name,
            subtitle: mode.time,
            active: mode.active,
            trailing: Switch(
              value: mode.active,
              onChanged: (_) => onToggleMode(mode),
            ),
          ),
        ),
        const SectionHeader(title: '应用使用'),
        ...data.apps.map(
          (app) => PlainTile(
            icon: app.locked ? Icons.lock_rounded : Icons.apps_rounded,
            title: app.name,
            subtitle: '${app.minutes} 分钟 · ${app.enabled ? '允许使用' : '已停用'}',
            active: app.enabled,
            trailing: Switch(
              value: app.enabled,
              onChanged: app.locked ? null : (_) => onToggleApp(app),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.data,
    required this.onAddContact,
  });

  final BootstrapData data;
  final VoidCallback onAddContact;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      title: '我的',
      subtitle: '家庭和设备',
      action: IconButton.filledTonal(
        onPressed: onAddContact,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        tooltip: '新增联系人',
      ),
      children: [
        ChildHero(child: data.child, location: data.location),
        ColorPanel(
          color: const Color(0xFF7B61FF),
          icon: Icons.watch_rounded,
          title: data.child.device,
          body:
              '${data.child.phone} · 话费 ${data.child.balance.toStringAsFixed(1)} 元',
        ),
        const SectionHeader(title: '白名单联系人'),
        ...data.contacts.map(
          (contact) => PlainTile(
            icon: Icons.contacts_rounded,
            title: contact.name,
            subtitle: '${contact.relation} · ${contact.phone}',
            active: true,
          ),
        ),
      ],
    );
  }
}

class AppScrollView extends StatelessWidget {
  const AppScrollView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.action,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final spaced = children
        .expand((child) => [child, const SizedBox(height: 12)])
        .toList();
    if (spaced.isNotEmpty) spaced.removeLast();
    return ListView(
      key: PageStorageKey(title),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 16),
        ...spaced,
      ],
    );
  }
}

class AgentCard extends StatelessWidget {
  const AgentCard({
    super.key,
    required this.controller,
    required this.reply,
    required this.onSend,
  });

  final TextEditingController controller;
  final String reply;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFB000)),
              SizedBox(width: 8),
              Text('家庭 Agent', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          Text(reply, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: '例如：19:30 提醒豆豆阅读',
              suffixIcon: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildHero extends StatelessWidget {
  const ChildHero({super.key, required this.child, required this.location});

  final ChildSummary child;
  final LocationSummary location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CA7A8), Color(0xFF47C2A1), Color(0xFFFFC857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Text(
                  child.avatar,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      child.className,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(child.online ? '在线' : '离线'),
                avatar: Icon(
                  child.online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            location.place,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${location.status} · ${location.accuracy}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          if (trailing != null)
            Text(trailing!, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onTap});

  final TaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PlainTile(
      icon: task.done
          ? Icons.check_circle_rounded
          : Icons.radio_button_unchecked_rounded,
      title: task.title,
      subtitle: '${task.time} · 奖励 ${task.reward} 颗星',
      active: task.done,
      onTap: onTap,
    );
  }
}

class TimelineTile extends StatelessWidget {
  const TimelineTile({super.key, required this.track});

  final TrackPoint track;

  @override
  Widget build(BuildContext context) {
    return PlainTile(
      icon: Icons.circle_rounded,
      title: '${track.time} ${track.place}',
      subtitle: '${track.detail} · ${track.status}',
      active: true,
    );
  }
}

class PlainTile extends StatelessWidget {
  const PlainTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: active
                    ? const Color(0xFFE6F7F4)
                    : const Color(0xFFF1F1F1),
                child: Icon(
                  icon,
                  color: active ? const Color(0xFF128A7E) : Colors.black45,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class ColorPanel extends StatelessWidget {
  const ColorPanel({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showInfo(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
