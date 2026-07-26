/// 通用记录数据模型
/// 支持文字、图片、视频、语音等多种类型
/// 对应 Firestore 集合: family_records / learning_records / life_records / work_records / three_views
class RecordModel {
  final String id;
  final String userId;
  final String bookType;      // family / learning / life / work / three_views
  final String subType;       // 子类型，如 diary / photo / finance 等
  final RecordContentType contentType; // 内容类型
  final String title;
  final String content;
  final List<String> mediaUrls;   // 图片/视频 URL 列表
  final String? audioUrl;         // 语音 URL
  final List<String> tags;
  final String location;
  final DateTime createTime;
  final DateTime updateTime;
  final bool isFavorite;

  const RecordModel({
    required this.id,
    required this.userId,
    required this.bookType,
    required this.subType,
    required this.contentType,
    required this.title,
    this.content = '',
    this.mediaUrls = const [],
    this.audioUrl,
    this.tags = const [],
    this.location = '',
    required this.createTime,
    required this.updateTime,
    this.isFavorite = false,
  });

  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      bookType: map['bookType'] ?? '',
      subType: map['subType'] ?? '',
      contentType: RecordContentType.values.firstWhere(
        (e) => e.name == map['contentType'],
        orElse: () => RecordContentType.text,
      ),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      audioUrl: map['audioUrl'],
      tags: List<String>.from(map['tags'] ?? []),
      location: map['location'] ?? '',
      createTime: (map['createTime'] as dynamic).toDate() as DateTime,
      updateTime: (map['updateTime'] as dynamic).toDate() as DateTime,
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookType': bookType,
      'subType': subType,
      'contentType': contentType.name,
      'title': title,
      'content': content,
      'mediaUrls': mediaUrls,
      'audioUrl': audioUrl,
      'tags': tags,
      'location': location,
      'createTime': createTime,
      'updateTime': updateTime,
      'isFavorite': isFavorite,
    };
  }
}

enum RecordContentType {
  text,       // 纯文字
  image,      // 图片
  video,      // 视频
  audio,      // 语音
  mixed,      // 混合（文字+媒体）
}
