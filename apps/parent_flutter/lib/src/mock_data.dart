import 'app_state.dart';

final mockBootstrapData = BootstrapData.fromJson({
  'child': {
    'id': 'child_001',
    'name': '豆豆',
    'className': '二年级 3 班',
    'avatar': '豆',
    'device': '豆小宝 Watch S1',
    'battery': 76,
    'online': true,
    'phone': '138 1024 8848',
    'balance': 36.8,
    'lastSync': '2 分钟前',
  },
  'location': {
    'place': '星河小学北门',
    'status': '在安全区域内',
    'updatedAt': '23:12',
    'accuracy': '28m',
  },
  'tracks': [
    {'time': '07:36', 'place': '家', 'detail': '离家', 'status': '正常'},
    {'time': '07:51', 'place': '梧桐路公交站', 'detail': '通勤中', 'status': '正常'},
    {'time': '07:58', 'place': '星河小学', 'detail': '到校', 'status': '进入安全区'},
    {'time': '16:42', 'place': '星河小学北门', 'detail': '放学等待', 'status': '安全区内'},
  ],
  'zones': [
    {'name': '星河小学', 'type': '安全区', 'range': '300m', 'enabled': true},
    {'name': '少年宫路口', 'type': '提醒区', 'range': '120m', 'enabled': true},
    {'name': '城南施工段', 'type': '危险区', 'range': '200m', 'enabled': true},
  ],
  'tasks': [
    {'title': '英语听读 15 分钟', 'time': '19:10', 'reward': 8, 'done': false},
    {'title': '整理明天书包', 'time': '20:20', 'reward': 6, 'done': true},
    {'title': '睡前刷牙打卡', 'time': '21:00', 'reward': 4, 'done': false},
  ],
  'modes': [
    {'name': '学习模式', 'time': '周一至周五 08:00-16:30', 'active': true},
    {'name': '睡眠模式', 'time': '每天 21:30-07:00', 'active': true},
    {'name': '娱乐模式', 'time': '每天最多 30 分钟', 'active': false},
  ],
  'apps': [
    {'name': '电话', 'minutes': 12, 'enabled': true, 'locked': false},
    {'name': '微聊', 'minutes': 18, 'enabled': true, 'locked': false},
    {'name': '故事', 'minutes': 24, 'enabled': true, 'locked': true},
    {'name': '运动', 'minutes': 31, 'enabled': true, 'locked': false},
  ],
  'contacts': [
    {'name': '妈妈', 'relation': '管理员', 'phone': '138 1024 8848'},
    {'name': '爸爸', 'relation': '家人', 'phone': '136 2233 9001'},
    {'name': '班主任王老师', 'relation': '老师', 'phone': '139 0000 2016'},
  ],
  'reports': {'stars': 42, 'steps': 8650, 'sleep': '9h 10m', 'mood': '平稳'},
});
