import 'package:flutter/material.dart';
import '../services/repository.dart';
import 'add_record_page.dart';

/// 生活册 - 生活记录、财务管理、旅行收藏
class LifePage extends StatefulWidget {
  const LifePage({super.key});
  @override
  State<LifePage> createState() => _LifePageState();
}

class _LifePageState extends State<LifePage> {
  final _repo = DataRepository();
  int _tab = 0;
  final _tabs = ['生活记录', '财务管理', '旅行收藏'];
  final _subTypes = ['daily', 'finance', 'travel'];
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() => _records = _repo.getRecords('life', subType: _subTypes[_tab]));
  }

  Future<void> _refresh() async {
    _loadRecords();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _goToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordPage(bookType: 'life', bookTitle: '生活册'),
      ),
    );
    if (result == true) _loadRecords();
  }

  void _openSearch() {
    showSearch(context: context, delegate: _LifeSearchDelegate(_repo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🌱 ', style: TextStyle(fontSize: 22)),
            Text('生活册', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _openSearch),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C4033),
        onPressed: _goToAdd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _tab = i);
                _loadRecords();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _tab == i ? const Color(0xFF5C4033) : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontWeight: _tab == i ? FontWeight.bold : FontWeight.normal,
                      color: _tab == i ? const Color(0xFF5C4033) : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('还没有${_tabs[_tab]}记录', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('点击右下角 + 开始记录', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF5C4033),
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final r = _records[index];
          final title = r['title'] ?? '无标题';
          final content = r['content'] ?? '';
          final time = (r['createTime'] ?? '').toString();
          final date = time.length >= 10 ? time.substring(0, 10) : time;
          final tags = (r['tags'] as List<dynamic>?) ?? [];

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
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    content.length > 100 ? '${content.substring(0, 100)}...' : content,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C4033).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('#$t', style: const TextStyle(fontSize: 11, color: Color(0xFF5C4033))),
                    )).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LifeSearchDelegate extends SearchDelegate {
  final DataRepository _repo;
  _LifeSearchDelegate(this._repo);

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
    final results = _repo.searchRecords('life', query);
    return results.isEmpty
        ? const Center(child: Text('没有搜索到相关记录'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              return ListTile(title: Text(r['title'] ?? ''), subtitle: Text(r['content'] ?? ''));
            },
          );
  }
}
