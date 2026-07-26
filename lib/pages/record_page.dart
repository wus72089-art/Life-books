import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/repository.dart';
import 'add_record_page.dart';
import 'record_detail_page.dart';

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

  /// 查找"那年今日"记录
  List<Map<String, dynamic>> get _todayInHistory {
    final now = DateTime.now();
    final todayMonth = now.month;
    final todayDay = now.day;
    final thisYear = now.year;

    return _allRecords.where((r) {
      final timeStr = (r['createTime'] as String?) ?? '';
      if (timeStr.length < 10) return false;
      final dt = DateTime.tryParse(timeStr.substring(0, 10));
      if (dt == null) return false;
      return dt.month == todayMonth && dt.day == todayDay && dt.year != thisYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    final todayHistory = _todayInHistory;

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

                  // ===== 那年今日横幅 =====
                  if (todayHistory.isNotEmpty)
                    _buildTodayInHistoryCard(todayHistory),

                  // 记录计数
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
                    return _RecordCard(
                      record: record,
                      onDelete: _loadAllRecords,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => RecordDetailPage(
                            record: record,
                            bookType: record['_bookType'] ?? '',
                            bookTitle: record['_label'] ?? '记录',
                          ),
                        )).then((_) => _loadAllRecords());
                      },
                    );
                  },
                  childCount: records.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 快速记一笔按钮
          FloatingActionButton.small(
            heroTag: 'quick_record',
            backgroundColor: Colors.white,
            onPressed: _showQuickRecord,
            child: const Icon(Icons.flash_on_rounded, color: Color(0xFF5C4033)),
          ),
          const SizedBox(height: 12),
          // 选册子添加按钮
          FloatingActionButton(
            heroTag: 'add_record',
            backgroundColor: const Color(0xFF5C4033),
            onPressed: _showAddOptions,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// 构建"那年今日"卡片
  Widget _buildTodayInHistoryCard(List<Map<String, dynamic>> records) {
    return GestureDetector(
      onTap: () {
        // 点击展开查看所有那年今日记录
        _showTodayInHistoryDialog(records);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5C4033),
              Color(0xFF8B6914),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C4033).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📅 去年今日',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            ...records.take(2).map((r) {
              final title = (r['title'] ?? '无标题') as String;
              final content = (r['content'] ?? '') as String;
              final time = (r['createTime'] ?? '').toString();
              final year = time.length >= 4 ? time.substring(0, 4) : '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    if (year.isNotEmpty) ...[
                      Text(
                        '$year年  ',
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (records.length > 2)
              Text(
                '还有 ${records.length - 2} 条记录...',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
          ],
        ),
      ),
    );
  }

  /// 显示那年今日详情弹窗
  void _showTodayInHistoryDialog(List<Map<String, dynamic>> records) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF8F4EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📅 那年今日',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final r = records[index];
                    final title = (r['title'] ?? '无标题') as String;
                    final content = (r['content'] ?? '') as String;
                    final time = (r['createTime'] ?? '').toString();
                    final year = time.length >= 4 ? time.substring(0, 4) : '';
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (year.isNotEmpty) Text('$year年', style: const TextStyle(fontSize: 12, color: Color(0xFF5C4033))),
                            if (content.isNotEmpty)
                              Text(
                                content.length > 80 ? '${content.substring(0, 80)}...' : content,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) => RecordDetailPage(
                              record: r,
                              bookType: r['_bookType'] ?? '',
                              bookTitle: r['_label'] ?? '记录',
                            ),
                          )).then((_) => _loadAllRecords());
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 快速记录弹窗
  void _showQuickRecord() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final picker = ImagePicker();
    String? imagePath;
    bool isPicking = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('⚡ 快速记一笔', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '标题...',
                  filled: true,
                  fillColor: const Color(0xFFF8F4EC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '此刻在想什么...',
                  filled: true,
                  fillColor: const Color(0xFFF8F4EC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // 拍照按钮
                  OutlinedButton.icon(
                    onPressed: isPicking ? null : () async {
                      setModalState(() => isPicking = true);
                      try {
                        final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (file != null) {
                          setModalState(() => imagePath = file.path);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('拍照失败: $e')),
                          );
                        }
                      } finally {
                        if (context.mounted) setModalState(() => isPicking = false);
                      }
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(imagePath != null ? '已拍照 ✓' : '拍照'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF5C4033),
                      side: const BorderSide(color: Color(0xFF5C4033)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Spacer(),
                  // 保存到生活册
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('请填写标题和内容')),
                        );
                        return;
                      }
                      try {
                        await DataRepository().addRecord('life', {
                          'title': title,
                          'content': content,
                          'subType': 'daily',
                          'tags': [],
                          'imagePaths': imagePath != null ? [imagePath!] : [],
                          'attachments': [],
                          'isFavorite': false,
                        });
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          _loadAllRecords();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('记录成功 ✓'),
                              backgroundColor: const Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('保存失败: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4033),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('保存到生活册'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  const _RecordCard({required this.record, this.onDelete, this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = record['_icon'] ?? '';
    final title = record['title'] ?? '无标题';
    final content = record['content'] ?? '';
    final tags = (record['tags'] as List<dynamic>?) ?? [];
    final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];
    final bookType = record['_bookType'] ?? '';
    final time = (record['createTime'] ?? '').toString();
    final date = time.length >= 16 ? '${time.substring(5, 10)} ${time.substring(11, 16)}' : time;

    return Dismissible(
      key: Key('record_${record['id'] ?? '$title$date'}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE57373),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除「$title」吗？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('删除', style: TextStyle(color: Color(0xFFE57373))),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) async {
        if (bookType.isNotEmpty && record['id'] != null) {
          await DataRepository().deleteRecord(bookType, record['id'] as String);
        }
        onDelete?.call();
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
              if (imagePaths.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imagePaths.length,
                    itemBuilder: (ctx, idx) {
                      final path = imagePaths[idx] as String;
                      return Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FileImage(File(path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
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
        ),
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
