import 'package:flutter/material.dart';
import '../models/book_data.dart';
import '../widgets/book_card.dart';
import '../services/repository.dart';
import 'family_page.dart';
import 'learning_page.dart';
import 'life_page.dart';
import 'work_page.dart';
import 'three_views_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = DataRepository();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 9) return '早上好';
    if (hour < 12) return '上午好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  static const List<Widget> _bookPages = [
    FamilyPage(),
    LearningPage(),
    LifePage(),
    WorkPage(),
    ThreeViewsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF5C4033),
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 问候
                  Text(
                    '${_getGreeting()}，吴导',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '记录今天，收藏人生',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  // 今日统计卡片（从本地数据库读取）
                  _TodayStatsCard(repo: _repo),
                  const SizedBox(height: 24),
                  const Text(
                    '人生五册',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C4033),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 五册入口
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allBooks.length,
                    itemBuilder: (context, index) {
                      final book = allBooks[index];
                      final count = (_repo.getRecordCounts()[_bookTypeKey(index)] ?? 0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BookCard(
                          title: '${book.icon} ${book.title}',
                          icon: book.icon,
                          description: book.desc,
                          recordCount: count,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => _bookPages[index],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _bookTypeKey(int index) {
    switch (index) {
      case 0: return 'family';
      case 1: return 'learning';
      case 2: return 'life';
      case 3: return 'work';
      case 4: return 'three_views';
      default: return '';
    }
  }
}

class _TodayStatsCard extends StatelessWidget {
  final DataRepository repo;
  const _TodayStatsCard({required this.repo});

  @override
  Widget build(BuildContext context) {
    final familyToday = repo.getTodayCount('family');
    final lifeToday = repo.getTodayCount('life');
    final learningToday = repo.getTodayCount('learning');
    final workToday = repo.getTodayCount('work');
    final viewsToday = repo.getTodayCount('three_views');
    final total = familyToday + lifeToday + learningToday + workToday + viewsToday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C4033), Color(0xFF8B6914)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C4033).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 今日记录',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '$familyToday', label: '家人', icon: '👨‍👩‍👧'),
              _StatItem(value: '$lifeToday', label: '生活', icon: '🌱'),
              _StatItem(value: '$learningToday', label: '学习', icon: '📚'),
              _StatItem(value: '$workToday', label: '工作', icon: '💼'),
              _StatItem(value: '$viewsToday', label: '三鉴', icon: '🌏'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '今日共 $total 条记录',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
      ],
    );
  }
}
