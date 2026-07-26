import 'package:flutter/material.dart';
import '../services/repository.dart';

/// 成就勋章页面
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository();
    final counts = repo.getRecordCounts();
    final total = repo.totalRecords;

    // 统计有图片的记录数
    int imageRecordCount = 0;
    for (final bookType in counts.keys) {
      final records = repo.getRecords(bookType);
      for (final r in records) {
        final images = r['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          imageRecordCount++;
        }
      }
    }

    // 检查每个册子是否至少有1条
    final allBooksHaveRecords = counts.values.every((c) => c > 0);

    final achievements = [
      _Achievement(
        emoji: '🌱',
        title: '新手上路',
        description: '记录满 10 条',
        unlocked: total >= 10,
        progress: total >= 10 ? 1.0 : (total / 10).clamp(0.0, 1.0),
      ),
      _Achievement(
        emoji: '📝',
        title: '记录达人',
        description: '记录满 50 条',
        unlocked: total >= 50,
        progress: total >= 50 ? 1.0 : (total / 50).clamp(0.0, 1.0),
      ),
      _Achievement(
        emoji: '📚',
        title: '知识渊博',
        description: '记录满 100 条',
        unlocked: total >= 100,
        progress: total >= 100 ? 1.0 : (total / 100).clamp(0.0, 1.0),
      ),
      _Achievement(
        emoji: '🌟',
        title: '人生作家',
        description: '记录满 500 条',
        unlocked: total >= 500,
        progress: total >= 500 ? 1.0 : (total / 500).clamp(0.0, 1.0),
      ),
      _Achievement(
        emoji: '💎',
        title: '五册齐全',
        description: '每个册子至少 1 条记录',
        unlocked: allBooksHaveRecords,
        progress: allBooksHaveRecords ? 1.0 : (counts.values.where((c) => c > 0).length / 5),
      ),
      _Achievement(
        emoji: '📸',
        title: '影像收藏家',
        description: '有图片的记录达 10 条',
        unlocked: imageRecordCount >= 10,
        progress: imageRecordCount >= 10 ? 1.0 : (imageRecordCount / 10).clamp(0.0, 1.0),
      ),
    ];

    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('成就勋章', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 顶部汇总
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_warmBrown, Color(0xFF8B6914)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: _warmBrown.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              children: [
                const Text('已解锁', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('$unlockedCount / ${achievements.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('枚成就勋章', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 成就列表
          ...achievements.map((a) => _buildAchievementCard(a)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(_Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: achievement.unlocked
                ? const Color(0xFF8B6914).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: achievement.unlocked
                  ? const Color(0xFF8B6914).withValues(alpha: 0.12)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  achievement.emoji,
                  style: TextStyle(
                    fontSize: 28,
                    color: achievement.unlocked ? null : Colors.grey,
                  ),
                ),
                if (!achievement.unlocked)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lock, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: achievement.unlocked ? _warmBrown : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      achievement.unlocked ? const Color(0xFF8B6914) : Colors.grey.shade400,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (achievement.unlocked)
            const Icon(Icons.check_circle, color: Color(0xFF8B6914), size: 24),
        ],
      ),
    );
  }
}

class _Achievement {
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;
  final double progress;

  const _Achievement({
    required this.emoji,
    required this.title,
    required this.description,
    required this.unlocked,
    required this.progress,
  });
}
