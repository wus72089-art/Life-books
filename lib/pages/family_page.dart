import 'package:flutter/material.dart';
import '../services/repository.dart';
import 'add_record_page.dart';

/// 家人册 - 记录亲情、家庭故事和重要回忆
class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});
  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  final _repo = DataRepository();
  int _tab = 0;
  final _tabs = ['家庭档案', '家庭日记', '家庭照片'];
  final _subTypes = ['archive', 'diary', 'photo_desc'];
  List<Map<String, dynamic>> _records = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _loading = true;
      _records = _repo.getRecords('family', subType: _subTypes[_tab]);
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    _loadRecords();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _goToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordPage(bookType: 'family', bookTitle: '家人册'),
      ),
    );
    if (result == true) _loadRecords();
  }

  void _openSearch() {
    showSearch(context: context, delegate: _FamilySearchDelegate(_repo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        title: const Row(
          children: [
            Text('👨‍👩‍👧 ', style: TextStyle(fontSize: 22)),
            Text('家人册', style: TextStyle(fontWeight: FontWeight.bold)),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_records.isEmpty) {
      return _buildEmpty();
    }
    return RefreshIndicator(
      color: const Color(0xFF5C4033),
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) => _buildRecordCard(_records[index]),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final title = record['title'] ?? '无标题';
    final content = record['content'] ?? '';
    final time = record['createTime'] ?? '';
    final date = time.length >= 10 ? time.substring(0, 10) : time;
    final tags = (record['tags'] as List<dynamic>?) ?? [];

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
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
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
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📝', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            '还没有${_tabs[_tab]}记录',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角 + 开始记录',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _FamilySearchDelegate extends SearchDelegate {
  final DataRepository _repo;
  _FamilySearchDelegate(this._repo);

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
    final results = _repo.searchRecords('family', query);
    return results.isEmpty
        ? const Center(child: Text('没有搜索到相关记录'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              return ListTile(
                title: Text(r['title'] ?? ''),
                subtitle: Text(r['content'] ?? ''),
              );
            },
          );
  }
}
