import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// 本地数据库服务（离线存储）
/// 使用 Hive 实现，支持无网络环境下的数据读写
class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  factory LocalDatabase() => _instance;
  LocalDatabase._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Hive Boxes（数据集合）
  late Box<String> _usersBox;
  late Box<String> _familyRecordsBox;
  late Box<String> _learningRecordsBox;
  late Box<String> _lifeRecordsBox;
  late Box<String> _workRecordsBox;
  late Box<String> _threeViewsBox;
  late Box<String> _settingsBox;
  late Box<String> _syncQueueBox;  // 待同步队列

  /// 初始化 Hive 数据库
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _usersBox = await Hive.openBox('users');
    _familyRecordsBox = await Hive.openBox('family_records');
    _learningRecordsBox = await Hive.openBox('learning_records');
    _lifeRecordsBox = await Hive.openBox('life_records');
    _workRecordsBox = await Hive.openBox('work_records');
    _threeViewsBox = await Hive.openBox('three_views');
    _settingsBox = await Hive.openBox('settings');
    _syncQueueBox = await Hive.openBox('sync_queue');

    _initialized = true;
  }

  // ============ 通用 CRUD ============

  /// 根据册子类型获取对应的 Box
  Box<String> _getBox(String bookType) {
    switch (bookType) {
      case 'family': return _familyRecordsBox;
      case 'learning': return _learningRecordsBox;
      case 'life': return _lifeRecordsBox;
      case 'work': return _workRecordsBox;
      case 'three_views': return _threeViewsBox;
      default:
        throw ArgumentError('未知的册子类型: $bookType');
    }
  }

  /// 添加记录
  Future<void> addRecord(String bookType, String id, Map<String, dynamic> data) async {
    final box = _getBox(bookType);
    data['id'] = id;
    data['createTime'] = data['createTime']?.toIso8601String() ?? DateTime.now().toIso8601String();
    data['updateTime'] = DateTime.now().toIso8601String();
    await box.put(id, jsonEncode(data));
  }

  /// 获取单条记录
  Map<String, dynamic>? getRecord(String bookType, String id) {
    final box = _getBox(bookType);
    final raw = box.get(id);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// 获取册子的所有记录（按时间倒序）
  List<Map<String, dynamic>> getAllRecords(String bookType, {String? subType, int? limit}) {
    final box = _getBox(bookType);
    final records = <Map<String, dynamic>>[];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      // 子类型筛选
      if (subType != null && subType.isNotEmpty && data['subType'] != subType) {
        continue;
      }
      records.add(data);
    }

    // 按时间倒序
    records.sort((a, b) {
      final aTime = a['createTime'] as String? ?? '';
      final bTime = b['createTime'] as String? ?? '';
      return bTime.compareTo(aTime);
    });

    if (limit != null && records.length > limit) {
      return records.sublist(0, limit);
    }
    return records;
  }

  /// 更新记录
  Future<void> updateRecord(String bookType, String id, Map<String, dynamic> data) async {
    final box = _getBox(bookType);
    final existing = getRecord(bookType, id);
    if (existing == null) return;

    existing.addAll(data);
    existing['updateTime'] = DateTime.now().toIso8601String();
    existing['isDirty'] = true;  // 标记需要同步
    await box.put(id, jsonEncode(existing));
  }

  /// 删除记录
  Future<void> deleteRecord(String bookType, String id) async {
    final box = _getBox(bookType);
    await box.delete(id);
  }

  /// 搜索记录
  List<Map<String, dynamic>> searchRecords(String bookType, String keyword) {
    final all = getAllRecords(bookType);
    final lower = keyword.toLowerCase();
    return all.where((r) {
      final title = (r['title'] as String? ?? '').toLowerCase();
      final content = (r['content'] as String? ?? '').toLowerCase();
      final tags = (r['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();
      return title.contains(lower) || content.contains(lower) || tags.contains(lower);
    }).toList();
  }

  // ============ 用户数据 ============

  /// 保存用户信息
  Future<void> saveUser(String userId, Map<String, dynamic> data) async {
    await _usersBox.put(userId, jsonEncode(data));
  }

  /// 获取用户信息
  Map<String, dynamic>? getUser(String userId) {
    final raw = _usersBox.get(userId);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ============ 设置 ============

  Future<void> setSetting(String key, String value) async {
    await _settingsBox.put(key, value);
  }

  String? getSetting(String key) {
    return _settingsBox.get(key);
  }

  // ============ 同步队列（离线优先） ============

  /// 将需要云端同步的操作加入队列
  Future<void> enqueueSync(String action, String bookType, String recordId, Map<String, dynamic> data) async {
    final key = '${DateTime.now().millisecondsSinceEpoch}_$recordId';
    final item = jsonEncode({
      'action': action,
      'bookType': bookType,
      'recordId': recordId,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _syncQueueBox.put(key, item);
  }

  /// 获取待同步队列
  List<Map<String, dynamic>> getPendingSyncItems() {
    final items = <Map<String, dynamic>>[];
    for (final key in _syncQueueBox.keys.toList()..sort()) {
      final raw = _syncQueueBox.get(key);
      if (raw != null) {
        items.add(jsonDecode(raw) as Map<String, dynamic>);
      }
    }
    return items;
  }

  /// 移除已同步的项目
  Future<void> removeSyncItem(String key) async {
    await _syncQueueBox.delete(key);
  }

  /// 获取所有脏记录（需要上传到云端的）
  List<Map<String, dynamic>> getDirtyRecords(String bookType) {
    final all = getAllRecords(bookType);
    return all.where((r) => r['isDirty'] == true).toList();
  }

  /// 清除记录的脏标记
  Future<void> clearDirtyFlag(String bookType, String id) async {
    final box = _getBox(bookType);
    final record = getRecord(bookType, id);
    if (record != null) {
      record['isDirty'] = false;
      await box.put(id, jsonEncode(record));
    }
  }

  // ============ 统计 ============

  /// 获取各册子记录数量
  Map<String, int> getRecordCounts() {
    return {
      'family': _familyRecordsBox.length,
      'learning': _learningRecordsBox.length,
      'life': _lifeRecordsBox.length,
      'work': _workRecordsBox.length,
      'three_views': _threeViewsBox.length,
    };
  }

  /// 获取今天新增的记录数
  int getTodayCount(String bookType) {
    final today = DateTime.now().toString().substring(0, 10);
    final records = getAllRecords(bookType);
    return records.where((r) {
      final time = r['createTime'] as String? ?? '';
      return time.startsWith(today);
    }).length;
  }

  /// 获取总记录数
  int get totalRecords {
    return _familyRecordsBox.length +
        _learningRecordsBox.length +
        _lifeRecordsBox.length +
        _workRecordsBox.length +
        _threeViewsBox.length;
  }
}
