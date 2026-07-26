import 'package:uuid/uuid.dart';

/// 文件上传服务（本地模式）
/// 当前为离线版本，文件存储在本地路径
class UploadService {
  static final UploadService _instance = UploadService._internal();
  factory UploadService() => _instance;
  UploadService._internal();

  final _uuid = const Uuid();

  /// 上传文件（本地模式，返回本地路径）
  Future<String> uploadFile(String localFilePath, String folder) async {
    // 本地模式下，直接使用原始文件路径
    // Firebase Storage 配置完成后，此处改为上传到云端并返回 URL
    return localFilePath;
  }

  /// 上传图片
  Future<String> uploadImage(String localFilePath) {
    return uploadFile(localFilePath, 'images');
  }

  /// 上传视频
  Future<String> uploadVideo(String localFilePath) {
    return uploadFile(localFilePath, 'videos');
  }

  /// 上传语音
  Future<String> uploadAudio(String localFilePath) {
    return uploadFile(localFilePath, 'audio');
  }
}
