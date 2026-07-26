import 'package:flutter/material.dart';
import '../models/book_data.dart';

class FeaturePage extends StatelessWidget {
  final String bookTitle;
  final FeatureInfo feature;
  const FeaturePage({super.key, required this.bookTitle, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(feature.title),
      ),
      body: _buildContent(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (feature.title) {
      case '家庭档案':
        return const _FamilyArchiveContent();
      case '家庭日记':
        return const _FamilyDiaryContent();
      case '家庭照片':
        return const _FamilyPhotosContent();
      case '读书记录':
        return const _ReadingRecordsContent();
      case '知识库':
        return const _KnowledgeBaseContent();
      case '学习成长':
        return const _LearningGrowthContent();
      case '生活记录':
        return const _LifeRecordsContent();
      case '财务管理':
        return const _FinanceContent();
      case '旅行收藏':
        return const _TravelContent();
      case '导游事业':
        return const _TourGuideContent();
      case '自媒体':
        return const _SelfMediaContent();
      case 'AI助手':
        return const _AIAssistantContent();
      case '见天地':
        return const _SeeWorldContent();
      case '见众生':
        return const _SeeOthersContent();
      case '见自己':
        return const _SeeSelfContent();
      default:
        return _GenericContent(feature: feature);
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('添加${feature.title}'),
        content: TextField(
          decoration: InputDecoration(
            hintText: '请输入内容...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已添加${feature.title}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// ========== 家人册 ==========
class _FamilyArchiveContent extends StatelessWidget {
  const _FamilyArchiveContent();
  @override
  Widget build(BuildContext context) {
    final members = [
      {'name': '爸爸', 'role': '家庭支柱', 'icon': '👨'},
      {'name': '妈妈', 'role': '家庭温暖', 'icon': '👩'},
      {'name': '我', 'role': '家庭成员', 'icon': '🧑'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(member['icon']!, style: const TextStyle(fontSize: 36)),
            title: Text(member['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(member['role']!),
            trailing: const Icon(Icons.edit, color: Colors.brown),
          ),
        );
      },
    );
  }
}

class _FamilyDiaryContent extends StatelessWidget {
  const _FamilyDiaryContent();
  @override
  Widget build(BuildContext context) {
    final diaries = [
      {'date': '2026-07-26', 'title': '周末家庭聚餐', 'preview': '今天全家一起做了火锅...'},
      {'date': '2026-07-25', 'title': '孩子的第一次游泳', 'preview': '今天带宝宝去了游泳馆...'},
      {'date': '2026-07-23', 'title': '家庭电影之夜', 'preview': '一起看了《流浪地球3》...'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diaries.length,
      itemBuilder: (context, index) {
        final diary = diaries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.brown),
            title: Text(diary['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(diary['date']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(diary['preview']!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FamilyPhotosContent extends StatelessWidget {
  const _FamilyPhotosContent();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.photo, size: 40, color: Colors.brown.withOpacity(0.5)),
          ),
        );
      },
    );
  }
}

// ========== 学习册 ==========
class _ReadingRecordsContent extends StatelessWidget {
  const _ReadingRecordsContent();
  @override
  Widget build(BuildContext context) {
    final books = [
      {'title': '《人类简史》', 'author': '尤瓦尔·赫拉利', 'progress': 75, 'rating': 4.5},
      {'title': '《思考，快与慢》', 'author': '丹尼尔·卡尼曼', 'progress': 40, 'rating': 0},
      {'title': '《原则》', 'author': '瑞·达利欧', 'progress': 100, 'rating': 5.0},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.brown, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(book['author'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    if (book['rating'] != 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(' ${book['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (book['progress'] as int) / 100,
                    minHeight: 8,
                    backgroundColor: Colors.brown.withOpacity(0.2),
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text('阅读进度 ${book['progress']}%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KnowledgeBaseContent extends StatelessWidget {
  const _KnowledgeBaseContent();
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': '技术笔记', 'count': 24, 'icon': '💻'},
      {'name': '读书笔记', 'count': 18, 'icon': '📝'},
      {'name': '工作资料', 'count': 12, 'icon': '📊'},
      {'name': '生活技巧', 'count': 8, 'icon': '💡'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(cat['icon'] as String, style: const TextStyle(fontSize: 32)),
            title: Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${cat['count']} 条笔记'),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _LearningGrowthContent extends StatelessWidget {
  const _LearningGrowthContent();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.brown.withOpacity(0.5)),
          const SizedBox(height: 20),
          const Text('学习成长轨迹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('记录你的学习里程碑', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 30),
          const _MilestoneItem(date: '2026-07', title: '完成Flutter入门', desc: '掌握了基础UI开发'),
          const _MilestoneItem(date: '2026-06', title: '读完10本书', desc: '本月阅读目标达成'),
          const _MilestoneItem(date: '2026-05', title: '获得新技能认证', desc: '通过AI应用开发认证'),
        ],
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final String date;
  final String title;
  final String desc;
  const _MilestoneItem({required this.date, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            child: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          const SizedBox(width: 12),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.brown,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== 生活册 ==========
class _LifeRecordsContent extends StatelessWidget {
  const _LifeRecordsContent();
  @override
  Widget build(BuildContext context) {
    final records = [
      {'date': '今天 06:28', 'content': '早起跑步5公里，感觉很好', 'mood': '😊'},
      {'date': '昨天 21:00', 'content': '和朋友一起吃了火锅', 'mood': '🥰'},
      {'date': '昨天 14:00', 'content': '下午在家整理书房', 'mood': '😌'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record['mood']!, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record['content']!, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 6),
                      Text(record['date']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FinanceContent extends StatelessWidget {
  const _FinanceContent();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('本月收支概览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FinanceItem(label: '收入', amount: '¥15,000', color: Colors.green),
                      _FinanceItem(label: '支出', amount: '¥8,500', color: Colors.red),
                      _FinanceItem(label: '结余', amount: '¥6,500', color: Colors.brown),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('最近交易', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _TransactionItem(icon: '🛒', desc: '超市购物', amount: '-¥230', date: '今天'),
          _TransactionItem(icon: '💰', desc: '工资收入', amount: '+¥15,000', date: '7月25日'),
          _TransactionItem(icon: '🍽️', desc: '餐厅聚餐', amount: '-¥180', date: '7月24日'),
          _TransactionItem(icon: '⛽', desc: '加油', amount: '-¥350', date: '7月23日'),
        ],
      ),
    );
  }
}

class _FinanceItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  const _FinanceItem({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String icon;
  final String desc;
  final String amount;
  final String date;
  const _TransactionItem({required this.icon, required this.desc, required this.amount, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 28)),
        title: Text(desc),
        subtitle: Text(date, style: TextStyle(fontSize: 12)),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: amount.startsWith('+') ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}

class _TravelContent extends StatelessWidget {
  const _TravelContent();
  @override
  Widget build(BuildContext context) {
    final travels = [
      {'name': '云南大理', 'date': '2026-05', 'photos': 128, 'icon': '🏔️'},
      {'name': '日本东京', 'date': '2026-03', 'photos': 256, 'icon': '🗼'},
      {'name': '海南三亚', 'date': '2026-01', 'photos': 89, 'icon': '🏖️'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: travels.length,
      itemBuilder: (context, index) {
        final travel = travels[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.brown.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(travel['icon'] as String, style: const TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(travel['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(travel['date'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      Text('${travel['photos']} 张照片', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ========== 工作册 ==========
class _TourGuideContent extends StatelessWidget {
  const _TourGuideContent();
  @override
  Widget build(BuildContext context) {
    final tours = [
      {'route': '丽江-大理-香格里拉', 'date': '2026-08-01', 'tourists': 15, 'status': '待出发'},
      {'route': '北京-西安-成都', 'date': '2026-07-20', 'tourists': 20, 'status': '已完成'},
      {'route': '桂林-阳朔-龙脊', 'date': '2026-07-10', 'tourists': 12, 'status': '已完成'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tours.length,
      itemBuilder: (context, index) {
        final tour = tours[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(tour['route'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (tour['status'] as String) == '已完成' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tour['status'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: (tour['status'] as String) == '已完成' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(tour['date'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(width: 16),
                    Icon(Icons.people, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${tour['tourists']}人', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelfMediaContent extends StatelessWidget {
  const _SelfMediaContent();
  @override
  Widget build(BuildContext context) {
    final contents = [
      {'title': '云南旅行Vlog', 'platform': '抖音', 'views': '12.5万', 'icon': '🎵'},
      {'title': '西安美食攻略', 'platform': '小红书', 'views': '8.2万', 'icon': '📕'},
      {'title': '旅行摄影技巧分享', 'platform': 'B站', 'views': '5.6万', 'icon': '📺'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contents.length,
      itemBuilder: (context, index) {
        final content = contents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(content['icon']!, style: const TextStyle(fontSize: 32)),
            title: Text(content['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(content['platform']!),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility, size: 16, color: Colors.grey),
                Text(content['views']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AIAssistantContent extends StatelessWidget {
  const _AIAssistantContent();
  @override
  Widget build(BuildContext context) {
    final tools = [
      {'name': '行程规划助手', 'desc': '智能规划旅游路线', 'icon': '🗺️'},
      {'name': '文案生成器', 'desc': '自动生成自媒体文案', 'icon': '✍️'},
      {'name': '客户管理', 'desc': '管理客户信息和跟进', 'icon': '👥'},
      {'name': '数据分析', 'desc': '分析运营数据和趋势', 'icon': '📊'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Text(tool['icon']!, style: const TextStyle(fontSize: 32)),
            title: Text(tool['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(tool['desc']!),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('使用'),
            ),
          ),
        );
      },
    );
  }
}

// ========== 人生三鉴 ==========
class _SeeWorldContent extends StatelessWidget {
  const _SeeWorldContent();
  @override
  Widget build(BuildContext context) {
    final entries = [
      {'title': '站在玉龙雪山脚下的感悟', 'date': '2026-05-15', 'excerpt': '面对自然的壮丽，感受到人类的渺小...'},
      {'title': '沙漠星空下的思考', 'date': '2026-03-20', 'excerpt': '仰望银河，思考宇宙的无限...'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(entry['date']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Text(entry['excerpt']!, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeeOthersContent extends StatelessWidget {
  const _SeeOthersContent();
  @override
  Widget build(BuildContext context) {
    final entries = [
      {'title': '理解父母的不易', 'date': '2026-07-20', 'excerpt': '今天和爸爸聊了很多，才理解他年轻时的艰辛...'},
      {'title': '旅途中遇到的人', 'date': '2026-06-10', 'excerpt': '在青旅认识了一位环球旅行者...'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(entry['date']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Text(entry['excerpt']!, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeeSelfContent extends StatelessWidget {
  const _SeeSelfContent();
  @override
  Widget build(BuildContext context) {
    final entries = [
      {'title': '30岁的自己', 'date': '2026-07-25', 'excerpt': '回顾这一年，成长了很多，也迷茫过...'},
      {'title': '关于职业方向的思考', 'date': '2026-07-18', 'excerpt': '导游和自媒体之间的平衡...'},
      {'title': '给未来自己的一封信', 'date': '2026-07-01', 'excerpt': '希望三年后的我，已经实现了...'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(entry['date']!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Text(entry['excerpt']!, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ========== 通用内容 ==========
class _GenericContent extends StatelessWidget {
  final FeatureInfo feature;
  const _GenericContent({required this.feature});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.brown.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(feature.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('点击右下角 + 添加内容', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
