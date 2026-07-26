class BookInfo {
  final String title;
  final String icon;
  final String desc;
  final List<FeatureInfo> features;

  const BookInfo({
    required this.title,
    required this.icon,
    required this.desc,
    required this.features,
  });
}

class FeatureInfo {
  final String title;
  final String icon;
  final String desc;

  const FeatureInfo({
    required this.title,
    required this.icon,
    required this.desc,
  });
}

const List<BookInfo> allBooks = [
  BookInfo(
    title: '家人册',
    icon: '👨‍👩‍👧',
    desc: '记录亲情与家庭故事',
    features: [
      FeatureInfo(title: '家庭档案', icon: '📋', desc: '管理家庭成员信息'),
      FeatureInfo(title: '家庭日记', icon: '📔', desc: '记录每一天家庭故事'),
      FeatureInfo(title: '家庭照片', icon: '📸', desc: '珍藏家庭美好瞬间'),
    ],
  ),
  BookInfo(
    title: '学习册',
    icon: '📚',
    desc: '收藏知识与成长记录',
    features: [
      FeatureInfo(title: '读书记录', icon: '📖', desc: '读书笔记与心得'),
      FeatureInfo(title: '知识库', icon: '🧠', desc: '上传图书、管理阅读进度'),
      FeatureInfo(title: '学习成长', icon: '🌱', desc: '学习轨迹与成长记录'),
    ],
  ),
  BookInfo(
    title: '生活册',
    icon: '🌿',
    desc: '保存人生美好瞬间',
    features: [
      FeatureInfo(title: '生活记录', icon: '📝', desc: '日常生活点滴'),
      FeatureInfo(title: '财务管理', icon: '💰', desc: '收支记录与理财规划'),
      FeatureInfo(title: '旅行收藏', icon: '✈️', desc: '旅途记忆与攻略'),
    ],
  ),
  BookInfo(
    title: '工作册',
    icon: '💼',
    desc: '管理事业与作品',
    features: [
      FeatureInfo(title: '导游事业', icon: '🗺️', desc: '带团记录与线路管理'),
      FeatureInfo(title: '自媒体', icon: '🎬', desc: '内容创作与发布管理'),
      FeatureInfo(title: 'AI助手', icon: '🤖', desc: '智能工作辅助工具'),
    ],
  ),
  BookInfo(
    title: '人生三见',
    icon: '🌏',
    desc: '见天地、见众生、见自己',
    features: [
      FeatureInfo(title: '见天地', icon: '🏔️', desc: '对世界的观察与感悟'),
      FeatureInfo(title: '见众生', icon: '👥', desc: '对人的理解与共情'),
      FeatureInfo(title: '见自己', icon: '🪞', desc: '自我反思与内心对话'),
    ],
  ),
];
