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
  late Future<BootstrapData> _bootstrapFuture;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = widget.initialData == null
        ? _load()
        : Future.value(widget.initialData);
  }

  Future<BootstrapData> _load() async {
    try {
      return await _apiClient.bootstrap();
    } catch (_) {
      return mockBootstrapData;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BootstrapData>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? mockBootstrapData;
        final pages = [
          WorkbenchPage(data: data),
          SafetyPage(data: data),
          GrowthPage(data: data),
          ControlPage(data: data),
          ProfilePage(data: data),
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
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                label: '管控',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }
}

class WorkbenchPage extends StatelessWidget {
  const WorkbenchPage({super.key, required this.data});

  final BootstrapData data;

  @override
  Widget build(BuildContext context) {
    final done = data.tasks.where((task) => task.done).length;
    return AppScrollView(
      title: '豆小宝',
      subtitle: '家长端',
      action: IconButton.filledTonal(
        onPressed: () {},
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
          children: const [
            QuickAction(icon: Icons.call_rounded, label: '呼叫'),
            QuickAction(icon: Icons.videocam_rounded, label: '视频'),
            QuickAction(icon: Icons.my_location_rounded, label: '定位'),
            QuickAction(icon: Icons.notifications_active_rounded, label: '找表'),
          ],
        ),
        SectionHeader(title: '今日任务', trailing: '$done/${data.tasks.length} 完成'),
        ...data.tasks.map((task) => TaskTile(task: task)),
      ],
    );
  }
}

class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key, required this.data});

  final BootstrapData data;

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
          ),
        ),
      ],
    );
  }
}

class GrowthPage extends StatelessWidget {
  const GrowthPage({super.key, required this.data});

  final BootstrapData data;

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
        ...data.tasks.map((task) => TaskTile(task: task)),
      ],
    );
  }
}

class ControlPage extends StatelessWidget {
  const ControlPage({super.key, required this.data});

  final BootstrapData data;

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
          ),
        ),
        const SectionHeader(title: '应用使用'),
        ...data.apps.map(
          (app) => PlainTile(
            icon: app.locked ? Icons.lock_rounded : Icons.apps_rounded,
            title: app.name,
            subtitle: '${app.minutes} 分钟 · ${app.enabled ? '允许使用' : '已停用'}',
            active: app.enabled,
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.data});

  final BootstrapData data;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      title: '我的',
      subtitle: '家庭和设备',
      children: [
        ChildHero(child: data.child, location: data.location),
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
        ...children
            .expand((child) => [child, const SizedBox(height: 12)])
            .toList()
          ..removeLast(),
      ],
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
  const QuickAction({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () {},
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
  const TaskTile({super.key, required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return PlainTile(
      icon: task.done
          ? Icons.check_circle_rounded
          : Icons.radio_button_unchecked_rounded,
      title: task.title,
      subtitle: '${task.time} · 奖励 ${task.reward} 颗星',
      active: task.done,
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
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
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
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
