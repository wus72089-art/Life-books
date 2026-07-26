import 'local_database.dart';

/// Firebase 服务层（离线模式）
/// 当前为纯本地版本，Firebase 云端同步功能待配置后启用
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// 初始化（本地模式，直接标记完成）
  Future<void> initialize() async {
    if (_initialized) return;
    // Firebase 配置完成后，在此处添加 Firebase.initializeApp()
    // 当前为纯离线模式
    _initialized = true;
  }

  String? get currentUser => LocalDatabase().getUser('current')?['userId'] as String?;

  /// 模拟 Firestore 操作（本地模式）
  Future<void> addRecord(String userId, String collection, Map<String, dynamic> data) async {
    // 本地模式下数据已由 Repository 写入 Hive
  }

  Future<void> updateRecord(String userId, String collection, String id, Map<String, dynamic> data) async {
    // 本地模式下数据已由 Repository 写入 Hive
  }

  Future<void> deleteRecord(String userId, String collection, String id) async {
    // 本地模式下数据已由 Repository 从 Hive 删除
  }

  /// 获取记录快照（本地模式返回空）
  dynamic getRecords(String userId, String collection) {
    return null;
  }
}
