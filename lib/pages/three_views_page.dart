import 'package:flutter/material.dart';
import '../services/repository.dart';
import 'add_record_page.dart';

/// 人生三鉴 - 见天地、见众生、见自己
class ThreeViewsPage extends StatefulWidget {
  const ThreeViewsPage({super.key});
  @override
  State<ThreeViewsPage> createState() => _ThreeViewsPageState();
}

class _ThreeViewsPageState extends State<ThreeViewsPage> {
  final _repo = DataRepository();
  int _tab = 0;
  final _tabs = ['见天地', '见众生', '见自己'];
  final _subTypes = ['world', 'people', 'self'];
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() => _records = _repo.getRecords('three_views', subType: _subTypes[_tab]));
  }

  Future<void> _refresh() async {
    _loadRecords();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _goToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordPage(bookType: 'three_views', bookTitle: '人生三鉴'),
      ),
    );
    if (result == true) _loadRecords();
  }

  void _openSearch() {
    showSearch(context: context, delegate: _ViewsSearchDelegate(_repo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🌏 ', style: TextStyle(fontSize: 22)),
            Text('人生三鉴', style: TextStyle(fontWeight: FontWeight.bold)),
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
    // 三鉴的特殊展示：卡片式，有引言风格
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_getTabEmoji(), style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '还没有${_tabs[_tab]}的感悟',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _getTabHint(),
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _goToAdd,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('写下感悟'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C4033),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border(
                left: BorderSide(
                  color: _getTabColor(),
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: _getTabColor(),
                  ),
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800],
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getTabEmoji() {
    switch (_tab) {
      case 0: return '🌄';
      case 1: return '🤝';
      case 2: return '🪞';
      default: return '🌍';
    }
  }

  String _getTabHint() {
    switch (_tab) {
      case 0: return '观察自然、感受世界，记录你对天地的思考';
      case 1: return '理解他人、体察众生，记录你对人心的感悟';
      case 2: return '认识自我、修炼内心，记录你对自己的觉察';
      default: return '点击右下角 + 开始记录';
    }
  }

  Color _getTabColor() {
    switch (_tab) {
      case 0: return const Color(0xFF2E7D32); // 绿-天地
      case 1: return const Color(0xFF1565C0); // 蓝-众生
      case 2: return const Color(0xFF6A1B9A); // 紫-自己
      default: return const Color(0xFF5C4033);
    }
  }
}

class _ViewsSearchDelegate extends SearchDelegate {
  final DataRepository _repo;
  _ViewsSearchDelegate(this._repo);

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
    final results = _repo.searchRecords('three_views', query);
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
