import 'package:flutter/material.dart';
import '../services/repository.dart';
import 'add_record_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final _repo = DataRepository();
  int _selectedFilter = -1; // -1 = 全部

  final List<_FilterType> _filters = [
    _FilterType(icon: '📝', label: '日记', bookType: 'family', color: const Color(0xFF8B4513)),
    _FilterType(icon: '📚', label: '学习', bookType: 'learning', color: const Color(0xFF9C27B0)),
    _FilterType(icon: '🌱', label: '生活', bookType: 'life', color: const Color(0xFF4CAF50)),
    _FilterType(icon: '💼', label: '工作', bookType: 'work', color: const Color(0xFF2196F3)),
    _FilterType(icon: '🌏', label: '三鉴', bookType: 'three_views', color: const Color(0xFFFF9800)),
  ];

  List<Map<String, dynamic>> _allRecords = [];

  @override
  void initState() {
    super.initState();
    _loadAllRecords();
  }

  void _loadAllRecords() {
    final all = <Map<String, dynamic>>[];
    for (final f in _filters) {
      final records = _repo.getRecords(f.bookType);
      for (final r in records) {
        r['_bookType'] = f.bookType;
        r['_icon'] = f.icon;
        r['_label'] = f.label;
      }
      all.addAll(records);
    }
    // 按时间倒序
    all.sort((a, b) {
      final ta = (a['createTime'] as String?) ?? '';
      final tb = (b['createTime'] as String?) ?? '';
      return tb.compareTo(ta);
    });
    setState(() => _allRecords = all);
  }

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedFilter == -1) return _allRecords;
    final bookType = _filters[_selectedFilter].bookType;
    return _allRecords.where((r) => r['_bookType'] == bookType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF8F4EC),
            title: const Text(
              '记录',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _showSearch(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 筛选类型
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isAll = _selectedFilter == -1;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = -1),
                            child: Container(
                              width: 70,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isAll ? const Color(0xFF5C4033).withValues(alpha: 0.15) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isAll ? const Color(0xFF5C4033).withValues(alpha: 0.5) : Colors.grey.withOpacity(0.2),
                                  width: isAll ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🗂️', style: TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '全部',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isAll ? FontWeight.bold : FontWeight.normal,
                                      color: isAll ? const Color(0xFF5C4033) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final f = _filters[index - 1];
                        final isSelected = _selectedFilter == index - 1;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = index - 1),
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? f.color.withOpacity(0.15) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? f.color.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(f.icon, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  f.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? f.color : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_selectedFilter == -1 ? '全部' : _filters[_selectedFilter].label}记录 (${records.length})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
                  ),
                ],
              ),
            ),
          ),
          if (records.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 60)),
                    const SizedBox(height: 16),
                    Text(
                      '还没有记录',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击右下角 + 开始记录',
                      style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                    ),
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
                    final record = records[index];
                    return _RecordCard(record: record);
                  },
                  childCount: records.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C4033),
        onPressed: _showAddOptions,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('新建记录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._filters.map((f) => ListTile(
                leading: Text(f.icon, style: const TextStyle(fontSize: 28)),
                title: Text('记录到${f.label}册'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AddRecordPage(
                      bookType: f.bookType,
                      bookTitle: '${f.label}册',
                    ),
                  )).then((_) => _loadAllRecords());
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _AllSearchDelegate(_repo),
    );
  }
}

class _FilterType {
  final String icon;
  final String label;
  final String bookType;
  final Color color;
  _FilterType({required this.icon, required this.label, required this.bookType, required this.color});
}

class _RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final icon = record['_icon'] ?? '📝';
    final title = record['title'] ?? '无标题';
    final content = record['content'] ?? '';
    final tags = (record['tags'] as List<dynamic>?) ?? [];
    final time = (record['createTime'] ?? '').toString();
    final date = time.length >= 16 ? '${time.substring(5, 10)} ${time.substring(11, 16)}' : time;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              content.length > 120 ? '${content.substring(0, 120)}...' : content,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C4033).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('#$tag', style: const TextStyle(fontSize: 12, color: Color(0xFF5C4033))),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllSearchDelegate extends SearchDelegate {
  final DataRepository _repo;
  _AllSearchDelegate(this._repo);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = _repo.searchAll(query);
    final all = <Map<String, dynamic>>[];
    results.forEach((key, value) {
      for (final r in value) {
        r['_bookType'] = key;
        all.add(r);
      }
    });

    return all.isEmpty
        ? const Center(child: Text('没有搜索到相关记录'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: all.length,
            itemBuilder: (context, index) {
              final r = all[index];
              return ListTile(
                title: Text(r['title'] ?? ''),
                subtitle: Text(r['content'] ?? ''),
                trailing: Text(r['_bookType'] ?? ''),
              );
            },
          );
  }
}
