/// 用户数据模型
/// 对应 Firestore 集合: users
class UserModel {
  final String userId;
  final String name;
  final String avatar;
  final String createTime;
  final String? phone;
  final String? email;
  final String? bio;

  const UserModel({
    required this.userId,
    required this.name,
    this.avatar = '',
    required this.createTime,
    this.phone,
    this.email,
    this.bio,
  });

  /// 从 Firestore 文档创建
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      createTime: map['createTime'] ?? '',
      phone: map['phone'],
      email: map['email'],
      bio: map['bio'],
    );
  }

  /// 转为 Firestore 文档
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'createTime': createTime,
      'phone': phone,
      'email': email,
      'bio': bio,
    };
  }

  /// 复制并修改
  UserModel copyWith({
    String? userId,
    String? name,
    String? avatar,
    String? createTime,
    String? phone,
    String? email,
    String? bio,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      createTime: createTime ?? this.createTime,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      bio: bio ?? this.bio,
    );
  }
}
