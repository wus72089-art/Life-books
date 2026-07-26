import 'package:flutter/material.dart';
import '../services/repository.dart';

/// 数据统计页面
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  static const _bookNames = {
    'family': '家人册',
    'learning': '学习册',
    'life': '生活册',
    'work': '工作册',
    'three_views': '三见册',
  };

  static const _bookColors = [
    Color(0xFF5C4033),
    Color(0xFF8B6914),
    Color(0xFFD4A574),
    Color(0xFF6B8E6B),
    Color(0xFF7B6BA5),
  ];

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository();
    final counts = repo.getRecordCounts();
    final total = repo.totalRecords;

    // 各册子名称与数量
    final entries = counts.entries.toList();

    // 统计本周/本月新增
    int weekCount = 0;
    int monthCount = 0;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthStart = DateTime(now.year, now.month, 1);

    for (final bookType in _bookNames.keys) {
      final records = repo.getRecords(bookType);
      for (final r in records) {
        final timeStr = r['createTime'] as String? ?? '';
        final time = DateTime.tryParse(timeStr);
        if (time != null) {
          if (time.isAfter(monthStart)) monthCount++;
          if (time.isAfter(weekAgo)) weekCount++;
        }
      }
    }

    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('数据统计', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 总览卡片
          _buildOverviewCard(total),
          const SizedBox(height: 16),

          // 本周 / 本月
          Row(
            children: [
              Expanded(child: _buildStatCard('本周新增', '$weekCount 条', Icons.trending_up)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('本月新增', '$monthCount 条', Icons.calendar_month)),
            ],
          ),
          const SizedBox(height: 20),

          // 各册子统计 + 柱状图
          const Text('各册子记录数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 12),
          _buildBarChart(entries, total),
          const SizedBox(height: 16),

          // 列表
          ...entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            final name = _bookNames[entry.key] ?? entry.key;
            final pct = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
            return _buildBookRow(name, entry.value, pct, _bookColors[idx % _bookColors.length]);
          }),

          const SizedBox(height: 20),

          // 占比饼图（简化版 - 用环形色块表示）
          const Text('占比分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 12),
          _buildPieChart(entries, total),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(int total) {
    return Container(
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
          const Text('总记录数', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('$total', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('条人生记录', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _warmBrown, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<MapEntry<String, int>> entries, int total) {
    final maxVal = entries.fold(0, (prev, e) => prev > e.value ? prev : e.value);
    if (maxVal == 0) {
      return Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: const Text('暂无数据', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.asMap().entries.map((e) {
                final idx = e.key;
                final entry = e.value;
                final ratio = maxVal > 0 ? entry.value / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${entry.value}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _warmBrown)),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          height: ratio * 100,
                          decoration: BoxDecoration(
                            color: _bookColors[idx % _bookColors.length],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: entries.asMap().entries.map((e) {
              final idx = e.key;
              final name = _bookNames[e.value.key] ?? e.value.key;
              return Expanded(
                child: Center(
                  child: Text(
                    name.length > 3 ? name.substring(0, 3) : name,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(List<MapEntry<String, int>> entries, int total) {
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.center,
        child: const Text('暂无数据', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final pct = total > 0 ? entry.value / total : 0.0;
          final name = _bookNames[entry.key] ?? entry.key;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _bookColors[idx % _bookColors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(name, style: const TextStyle(fontSize: 13)),
                ),
                Text('${(pct * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _warmBrown)),
                const SizedBox(width: 8),
                // 比例条
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(_bookColors[idx % _bookColors.length]),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookRow(String name, int count, String pct, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Text('$count 条', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(width: 8),
          Text('$pct%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}


