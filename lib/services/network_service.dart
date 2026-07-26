import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 网络连接状态服务
class NetworkService extends ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// 初始化网络检测（简单实现，可替换为 connectivity_plus）
  Future<void> initialize() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _isOnline = false;
    }
    _controller.add(_isOnline);
    notifyListeners();
  }

  void setOnline(bool online) {
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
      notifyListeners();
    }
  }

  /// 定时检测网络状态
  Timer? _timer;
  void startPeriodicCheck({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await initialize();
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
    super.dispose();
  }
}
