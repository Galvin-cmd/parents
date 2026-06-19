class BootstrapData {
  const BootstrapData({
    required this.child,
    required this.location,
    required this.tracks,
    required this.zones,
    required this.tasks,
    required this.modes,
    required this.apps,
    required this.contacts,
    required this.reports,
  });

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    return BootstrapData(
      child: ChildSummary.fromJson(
        json['child'] as Map<String, dynamic>? ?? {},
      ),
      location: LocationSummary.fromJson(
        json['location'] as Map<String, dynamic>? ?? {},
      ),
      tracks: listOf(json['tracks'], TrackPoint.fromJson),
      zones: listOf(json['zones'], GeoZone.fromJson),
      tasks: listOf(json['tasks'], TaskItem.fromJson),
      modes: listOf(json['modes'], ControlMode.fromJson),
      apps: listOf(json['apps'], AppUsage.fromJson),
      contacts: listOf(json['contacts'], ContactItem.fromJson),
      reports: ReportSummary.fromJson(
        json['reports'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  final ChildSummary child;
  final LocationSummary location;
  final List<TrackPoint> tracks;
  final List<GeoZone> zones;
  final List<TaskItem> tasks;
  final List<ControlMode> modes;
  final List<AppUsage> apps;
  final List<ContactItem> contacts;
  final ReportSummary reports;
}

typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

List<T> listOf<T>(Object? value, JsonFactory<T> factory) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(factory).toList();
}

class ChildSummary {
  const ChildSummary({
    required this.id,
    required this.name,
    required this.className,
    required this.avatar,
    required this.device,
    required this.battery,
    required this.online,
    required this.phone,
    required this.balance,
    required this.lastSync,
  });

  factory ChildSummary.fromJson(Map<String, dynamic> json) {
    final name = stringValue(json['name'], '豆豆');
    return ChildSummary(
      id: stringValue(json['id'], 'child_001'),
      name: name,
      className: stringValue(json['className'], '二年级 3 班'),
      avatar: stringValue(
        json['avatar'],
        name.isEmpty ? '豆' : name.substring(0, 1),
      ),
      device: stringValue(json['device'], '豆小宝 Watch S1'),
      battery: intValue(json['battery'], 76),
      online: boolValue(json['online'], true),
      phone: stringValue(json['phone'], '138 1024 8848'),
      balance: doubleValue(json['balance'], 36.8),
      lastSync: stringValue(json['lastSync'], '2 分钟前'),
    );
  }

  final String id;
  final String name;
  final String className;
  final String avatar;
  final String device;
  final int battery;
  final bool online;
  final String phone;
  final double balance;
  final String lastSync;
}

class LocationSummary {
  const LocationSummary({
    required this.place,
    required this.status,
    required this.updatedAt,
    required this.accuracy,
  });

  factory LocationSummary.fromJson(Map<String, dynamic> json) {
    return LocationSummary(
      place: stringValue(json['place'], '星河小学北门'),
      status: stringValue(json['status'], '在安全区域内'),
      updatedAt: stringValue(json['updatedAt'], '23:12'),
      accuracy: stringValue(json['accuracy'], '28m'),
    );
  }

  final String place;
  final String status;
  final String updatedAt;
  final String accuracy;
}

class TrackPoint {
  const TrackPoint({
    required this.time,
    required this.place,
    required this.detail,
    required this.status,
  });

  factory TrackPoint.fromJson(Map<String, dynamic> json) {
    return TrackPoint(
      time: stringValue(json['time'], ''),
      place: stringValue(json['place'], ''),
      detail: stringValue(json['detail'], ''),
      status: stringValue(json['status'], ''),
    );
  }

  final String time;
  final String place;
  final String detail;
  final String status;
}

class GeoZone {
  const GeoZone({
    required this.name,
    required this.type,
    required this.range,
    required this.enabled,
  });

  factory GeoZone.fromJson(Map<String, dynamic> json) {
    return GeoZone(
      name: stringValue(json['name'], ''),
      type: stringValue(json['type'], ''),
      range: stringValue(json['range'], ''),
      enabled: boolValue(json['enabled'], true),
    );
  }

  final String name;
  final String type;
  final String range;
  final bool enabled;
}

class TaskItem {
  const TaskItem({
    required this.title,
    required this.time,
    required this.reward,
    required this.done,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: stringValue(json['title'], ''),
      time: stringValue(json['time'], ''),
      reward: intValue(json['reward'], 0),
      done: boolValue(json['done'], false),
    );
  }

  final String title;
  final String time;
  final int reward;
  final bool done;
}

class ControlMode {
  const ControlMode({
    required this.name,
    required this.time,
    required this.active,
  });

  factory ControlMode.fromJson(Map<String, dynamic> json) {
    return ControlMode(
      name: stringValue(json['name'], ''),
      time: stringValue(json['time'], ''),
      active: boolValue(json['active'], false),
    );
  }

  final String name;
  final String time;
  final bool active;
}

class AppUsage {
  const AppUsage({
    required this.name,
    required this.minutes,
    required this.enabled,
    required this.locked,
  });

  factory AppUsage.fromJson(Map<String, dynamic> json) {
    return AppUsage(
      name: stringValue(json['name'], ''),
      minutes: intValue(json['minutes'], 0),
      enabled: boolValue(json['enabled'], true),
      locked: boolValue(json['locked'], false),
    );
  }

  final String name;
  final int minutes;
  final bool enabled;
  final bool locked;
}

class ContactItem {
  const ContactItem({
    required this.name,
    required this.relation,
    required this.phone,
  });

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      name: stringValue(json['name'], ''),
      relation: stringValue(json['relation'], ''),
      phone: stringValue(json['phone'], ''),
    );
  }

  final String name;
  final String relation;
  final String phone;
}

class ReportSummary {
  const ReportSummary({
    required this.stars,
    required this.steps,
    required this.sleep,
    required this.mood,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      stars: intValue(json['stars'], 0),
      steps: intValue(json['steps'], 0),
      sleep: stringValue(json['sleep'], '--'),
      mood: stringValue(json['mood'], '--'),
    );
  }

  final int stars;
  final int steps;
  final String sleep;
  final String mood;
}

String stringValue(Object? value, String fallback) {
  return value is String && value.isNotEmpty ? value : fallback;
}

int intValue(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return fallback;
}

double doubleValue(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return fallback;
}

bool boolValue(Object? value, bool fallback) {
  return value is bool ? value : fallback;
}
