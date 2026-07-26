import 'package:flutter/material.dart';
import '../services/repository.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final _repo = DataRepository();
  List<_TimelineGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  void _loadTimeline() {
    // 从所有册子加载记录，合并后按日期分组
    final all = <Map<String, dynamic>>[];
    const bookIcons = {
      'family': '👨‍👩‍👧',
      'learning': '📚',
      'life': '🌱',
      'work': '💼',
      'three_views': '🌏',
    };
    const bookNames = {
      'family': '家人册',
      'learning': '学习册',
      'life': '生活册',
      'work': '工作册',
      'three_views': '人生三鉴',
    };

    for (final type in bookIcons.keys) {
      final records = _repo.getRecords(type);
      for (final r in records) {
        r['_icon'] = bookIcons[type];
        r['_bookName'] = bookNames[type];
        r['_bookType'] = type;
        all.add(r);
      }
    }

    // 按时间倒序
    all.sort((a, b) {
      final ta = (a['createTime'] as String?) ?? '';
      final tb = (b['createTime'] as String?) ?? '';
      return tb.compareTo(ta);
    });

    // 按日期分组
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final r in all) {
      final time = (r['createTime'] as String?) ?? '';
      final date = time.length >= 10 ? time.substring(0, 10) : '未知日期';
      grouped.putIfAbsent(date, () => []).add(r);
    }

    final groups = grouped.entries.map((e) {
      return _TimelineGroup(date: e.key, records: e.value);
    }).toList();

    setState(() => _groups = groups);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF8F4EC),
            title: const Text(
              '时间轴',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
            ),
          ),
          if (_groups.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    Text('时间轴还是空的', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Text('开始记录，这里会按时间展示', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final childIndex = index ~/ 2;
                    if (childIndex >= _groups.length) return const SizedBox();
                    final group = _groups[childIndex];
                    if (index.isOdd) {
                      // 日期头
                      return _DateHeader(date: group.date, count: group.records.length);
                    } else {
                      // 记录卡片
                      return _TimelineCard(record: group.records[index ~/ 2]);
                    }
                    return const SizedBox();
                  },
                  childCount: _groups.fold(0, (sum, g) => sum + 1 + g.records.length),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _TimelineGroup {
  final String date;
  final List<Map<String, dynamic>> records;
  _TimelineGroup({required this.date, required this.records});
}

class _DateHeader extends StatelessWidget {
  final String date;
  final int count;
  const _DateHeader({required this.date, required this.count});

  String _formatDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(d).inDays;
      if (diff == 0) return '今天';
      if (diff == 1) return '昨天';
      if (diff < 7) return '$diff 天前';
      return '$dateStr · ${_weekday(d)}';
    } catch (_) {
      return dateStr;
    }
  }

  String _weekday(DateTime d) {
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF5C4033),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C4033),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count 条记录',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _TimelineCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final icon = record['_icon'] ?? '📝';
    final bookName = record['_bookType'] ?? '';
    final title = record['title'] ?? '无标题';
    final content = record['content'] ?? '';
    final time = (record['createTime'] ?? '').toString();
    final timeShort = time.length >= 16 ? time.substring(11, 16) : '';

    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间线竖线
          Column(
            children: [
              Container(
                width: 2,
                height: 8,
                color: const Color(0xFF5C4033).withValues(alpha: 0.3),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF5C4033), width: 1.5),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: const Color(0xFF5C4033).withValues(alpha: 0.15),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // 卡片
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      if (timeShort.isNotEmpty)
                        Text(timeShort, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      content.length > 80 ? '${content.substring(0, 80)}...' : content,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
