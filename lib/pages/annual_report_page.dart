import 'package:flutter/material.dart';
import '../services/repository.dart';

/// 年度报告页面
class AnnualReportPage extends StatelessWidget {
  const AnnualReportPage({super.key});

  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  static const _bookNames = {
    'family': '家人册',
    'learning': '学习册',
    'life': '生活册',
    'work': '工作册',
    'three_views': '三见册',
  };

  static const _monthLabels = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository();
    final year = DateTime.now().year;

    // 收集所有记录
    final allRecords = <Map<String, dynamic>>[];
    final counts = repo.getRecordCounts();
    for (final bookType in counts.keys) {
      allRecords.addAll(repo.getRecords(bookType).map((r) => {...r, '_bookType': bookType}));
    }

    // 按月统计（仅当年）
    final monthlyCounts = List.filled(12, 0);
    final bookTypeCounts = <String, int>{};
    final tagCounts = <String, int>{};

    for (final r in allRecords) {
      final timeStr = r['createTime'] as String? ?? '';
      final time = DateTime.tryParse(timeStr);
      if (time != null && time.year == year) {
        monthlyCounts[time.month - 1]++;
      }

      // 册子类型统计
      final bt = r['_bookType'] as String?;
      if (bt != null) {
        bookTypeCounts[bt] = (bookTypeCounts[bt] ?? 0) + 1;
      }

      // 标签统计
      final tags = r['tags'] as List<dynamic>?;
      if (tags != null) {
        for (final tag in tags) {
          final tagStr = tag.toString().trim();
          if (tagStr.isNotEmpty) {
            tagCounts[tagStr] = (tagCounts[tagStr] ?? 0) + 1;
          }
        }
      }
    }

    // 最活跃的册子
    String? mostActiveBook;
    int maxBookCount = 0;
    bookTypeCounts.forEach((k, v) {
      if (v > maxBookCount) {
        maxBookCount = v;
        mostActiveBook = k;
      }
    });

    // 最活跃月份
    int maxMonthIdx = 0;
    for (int i = 1; i < 12; i++) {
      if (monthlyCounts[i] > monthlyCounts[maxMonthIdx]) maxMonthIdx = i;
    }

    // 热门标签 Top 10
    final sortedTags = tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(10).toList();

    final yearTotal = monthlyCounts.fold(0, (sum, c) => sum + c);

    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: Text('$year 年度报告', style: const TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 年度概览
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
                Text('$year', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('$yearTotal', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const Text('条记录', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _miniStat('最活跃月份', _monthLabels[maxMonthIdx]),
                    _miniStat('最活跃册子', mostActiveBook != null ? (_bookNames[mostActiveBook!] ?? mostActiveBook!) : '-'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 月度柱状图
          const Text('月度记录分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 12),
          _buildMonthlyChart(monthlyCounts),
          const SizedBox(height: 24),

          // 最活跃的册子类型
          const Text('各册子记录占比', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 12),
          _buildBookTypeStats(bookTypeCounts),
          const SizedBox(height: 24),

          // 常用标签
          if (topTags.isNotEmpty) ...[
            const Text('热门标签', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown)),
            const SizedBox(height: 12),
            _buildTagsSection(topTags),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildMonthlyChart(List<int> monthlyCounts) {
    final maxVal = monthlyCounts.fold(0, (p, c) => p > c ? p : c);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final ratio = maxVal > 0 ? monthlyCounts[i] / maxVal : 0.0;
                final isMax = monthlyCounts[i] == maxVal && maxVal > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (monthlyCounts[i] > 0)
                          Text('${monthlyCounts[i]}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isMax ? _warmBrown : Colors.grey)),
                        const SizedBox(height: 2),
                        Container(
                          height: ratio * 85,
                          decoration: BoxDecoration(
                            color: isMax ? _warmBrown : _warmBrown.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(12, (i) => Expanded(
              child: Center(
                child: Text(_monthLabels[i], style: const TextStyle(fontSize: 9, color: Colors.grey)),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBookTypeStats(Map<String, int> bookTypeCounts) {
    final total = bookTypeCounts.values.fold(0, (s, c) => s + c);
    if (total == 0) {
      return _emptyCard('暂无数据');
    }

    final colors = [
      const Color(0xFF5C4033),
      const Color(0xFF8B6914),
      const Color(0xFFD4A574),
      const Color(0xFF6B8E6B),
      const Color(0xFF7B6BA5),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: bookTypeCounts.entries.toList().asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final name = _bookNames[entry.key] ?? entry.key;
          final pct = total > 0 ? entry.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[idx % colors.length], borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
                Text('${entry.value} 条', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _warmBrown)),
                const SizedBox(width: 6),
                SizedBox(
                  width: 60,
                  child: Text('${(pct * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTagsSection(List<MapEntry<String, int>> topTags) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: topTags.map((e) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _warmBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _warmBrown.withValues(alpha: 0.2)),
            ),
            child: Text(
              '#${e.key} (${e.value})',
              style: const TextStyle(fontSize: 12, color: _warmBrown, fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}



