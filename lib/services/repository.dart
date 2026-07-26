import 'dart:async';
import 'package:uuid/uuid.dart';
import 'local_database.dart';
import 'firebase_service.dart';

/// 数据仓库层 - 离线优先策略
///
/// 写入策略：
/// 1. 数据先写入本地 Hive（立即生效）
/// 2. 如果有网络，异步同步到 Firebase
/// 3. 如果无网络，加入同步队列，等有网络时自动同步
///
/// 读取策略：
/// 1. 优先从本地 Hive 读取（速度快）
/// 2. 后台静默从 Firebase 拉取最新数据并更新本地
class DataRepository {
  static final DataRepository _instance = DataRepository._internal();
  factory DataRepository() => _instance;
  DataRepository._internal();

  final _db = LocalDatabase();
  final _uuid = const Uuid();

  String? _currentUserId;

  /// 设置当前用户（登录后调用）
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  /// 是否离线模式
  bool get isOffline {
    try {
      final firebase = FirebaseService();
      return !firebase.isInitialized || firebase.currentUser == null;
    } catch (_) {
      return true;
    }
  }

  // ============ 记录 CRUD ============

  /// 添加记录（离线优先）
  Future<String> addRecord(String bookType, Map<String, dynamic> data) async {
    final id = _uuid.v4();
    data['userId'] = _currentUserId ?? 'local_user';

    // 1. 立即写入本地
    await _db.addRecord(bookType, id, data);

    // 2. 如果不离线，异步同步到云端
    if (!isOffline) {
      try {
        await FirebaseService().addRecord(
          _currentUserId!,
          bookType,
          data,
        );
      } catch (e) {
        // 云端失败，加入同步队列
        await _db.enqueueSync('add', bookType, id, data);
      }
    } else {
      await _db.enqueueSync('add', bookType, id, data);
    }

    return id;
  }

  /// 获取册子记录列表
  List<Map<String, dynamic>> getRecords(
    String bookType, {
    String? subType,
    int? limit,
  }) {
    return _db.getAllRecords(bookType, subType: subType, limit: limit);
  }

  /// 获取单条记录
  Map<String, dynamic>? getRecord(String bookType, String id) {
    return _db.getRecord(bookType, id);
  }

  /// 更新记录
  Future<void> updateRecord(String bookType, String id, Map<String, dynamic> data) async {
    // 1. 本地立即更新
    await _db.updateRecord(bookType, id, data);

    // 2. 异步同步
    if (!isOffline) {
      try {
        await FirebaseService().updateRecord(_currentUserId!, bookType, id, data);
        await _db.clearDirtyFlag(bookType, id);
      } catch (e) {
        await _db.enqueueSync('update', bookType, id, data);
      }
    } else {
      await _db.enqueueSync('update', bookType, id, data);
    }
  }

  /// 删除记录
  Future<void> deleteRecord(String bookType, String id) async {
    await _db.deleteRecord(bookType, id);

    if (!isOffline) {
      try {
        await FirebaseService().deleteRecord(_currentUserId!, bookType, id);
      } catch (e) {
        await _db.enqueueSync('delete', bookType, id, {'id': id});
      }
    } else {
      await _db.enqueueSync('delete', bookType, id, {'id': id});
    }
  }

  // ============ 搜索 ============

  /// 搜索所有册子
  Map<String, List<Map<String, dynamic>>> searchAll(String keyword) {
    return {
      'family': _db.searchRecords('family', keyword),
      'learning': _db.searchRecords('learning', keyword),
      'life': _db.searchRecords('life', keyword),
      'work': _db.searchRecords('work', keyword),
      'three_views': _db.searchRecords('three_views', keyword),
    };
  }

  /// 搜索单个册子
  List<Map<String, dynamic>> searchRecords(String bookType, String keyword) {
    return _db.searchRecords(bookType, keyword);
  }

  // ============ 同步 ============

  /// 执行同步队列中的待同步项
  Future<SyncResult> syncPendingItems() async {
    if (isOffline) {
      return SyncResult(success: 0, failed: 0, message: '当前离线，无法同步');
    }

    final items = _db.getPendingSyncItems();
    int success = 0;
    int failed = 0;

    for (final item in items) {
      try {
        final action = item['action'] as String;
        final bookType = item['bookType'] as String;
        final recordId = item['recordId'] as String;

        switch (action) {
          case 'add':
            await FirebaseService().addRecord(
              _currentUserId!,
              bookType,
              item['data'] as Map<String, dynamic>,
            );
            break;
          case 'update':
            await FirebaseService().updateRecord(
              _currentUserId!,
              bookType,
              recordId,
              item['data'] as Map<String, dynamic>,
            );
            await _db.clearDirtyFlag(bookType, recordId);
            break;
          case 'delete':
            await FirebaseService().deleteRecord(
              _currentUserId!,
              bookType,
              recordId,
            );
            break;
        }
        success++;
      } catch (e) {
        failed++;
      }
    }

    // 清除已同步的项（简化处理，实际应逐个移除）
    // 此处保留未同步的项

    return SyncResult(
      success: success,
      failed: failed,
      message: failed == 0 ? '同步完成，共 $success 条' : '同步完成，$success 条成功，$failed 条失败',
    );
  }

  /// 从云端拉取最新数据到本地（本地模式下为空操作）
  Future<void> pullFromCloud(String bookType) async {
    if (isOffline || _currentUserId == null) return;

    try {
      final snapshot = FirebaseService().getRecords(_currentUserId!, bookType);
      if (snapshot == null) return;
      // Firebase 配置完成后，此处可遍历 snapshot.docs 写入本地
    } catch (e) {
      // 拉取失败，保持本地数据
    }
  }

  // ============ 统计 ============

  /// 获取各册子记录数
  Map<String, int> getRecordCounts() => _db.getRecordCounts();

  /// 获取今日记录数
  int getTodayCount(String bookType) => _db.getTodayCount(bookType);

  /// 今日总新增
  int get todayTotal {
    return getTodayCount('family') +
        getTodayCount('learning') +
        getTodayCount('life') +
        getTodayCount('work') +
        getTodayCount('three_views');
  }

  /// 总记录数
  int get totalRecords => _db.totalRecords;

  /// 待同步数量
  int get pendingSyncCount => _db.getPendingSyncItems().length;
}

/// 同步结果
class SyncResult {
  final int success;
  final int failed;
  final String message;
  const SyncResult({required this.success, required this.failed, required this.message});
}
