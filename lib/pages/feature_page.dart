import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_data.dart';
import '../services/repository.dart';
import 'add_record_page.dart';

class FeaturePage extends StatelessWidget {
  final String bookTitle;
  final FeatureInfo feature;
  const FeaturePage({super.key, required this.bookTitle, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(feature.title),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (feature.title) {
      case '家庭档案':
        return const _FamilyArchiveContent();
      case '家庭日记':
        return const _FamilyDiaryContent();
      case '家庭照片':
        return const _FamilyPhotosContent();
      case '读书记录':
        return const _ReadingRecordsContent();
      case '知识库':
        return const _KnowledgeBaseContent();
      case '学习成长':
        return const _LearningGrowthContent();
      case '生活记录':
        return const _LifeRecordsContent();
      case '财务管理':
        return const _FinanceContent();
      case '旅行收藏':
        return const _TravelContent();
      case '导游事业':
        return const _TourGuideContent();
      case '自媒体':
        return const _SelfMediaContent();
      case 'AI助手':
        return const _AIAssistantContent();
      case '见天地':
        return const _SeeWorldContent();
      case '见众生':
        return const _SeeOthersContent();
      case '见自己':
        return const _SeeSelfContent();
      default:
        return _GenericContent(feature: feature);
    }
  }
}

// ========== 家人册 ==========

class _FamilyArchiveContent extends StatefulWidget {
  const _FamilyArchiveContent();
  @override
  State<_FamilyArchiveContent> createState() => _FamilyArchiveContentState();
}

class _FamilyArchiveContentState extends State<_FamilyArchiveContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('family', subType: 'archive');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.family_restroom, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无家庭成员', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('点击右下角 + 添加家庭成员', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('family_archive_${record['id'] ?? index}'),
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
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('family', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imagePaths[0] as String),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.brown.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.person, color: Colors.brown.withOpacity(0.5)),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.brown.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.person, color: Colors.brown.withOpacity(0.5)),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (content.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(content, style: TextStyle(color: Colors.grey[600])),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddRecordPage(bookType: 'family', bookTitle: '家庭档案'),
            ),
          );
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FamilyDiaryContent extends StatefulWidget {
  const _FamilyDiaryContent();
  @override
  State<_FamilyDiaryContent> createState() => _FamilyDiaryContentState();
}

class _FamilyDiaryContentState extends State<_FamilyDiaryContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('family', subType: 'diary');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无家庭日记', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 16 ? '${time.substring(0, 10)} ${time.substring(11, 16)}' : time;

                return Dismissible(
                  key: Key('family_diary_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('family', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Colors.brown),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date.isNotEmpty) Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(content.length > 60 ? '${content.substring(0, 60)}...' : content),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'family', bookTitle: '家庭日记')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FamilyPhotosContent extends StatefulWidget {
  const _FamilyPhotosContent();
  @override
  State<_FamilyPhotosContent> createState() => _FamilyPhotosContentState();
}

class _FamilyPhotosContentState extends State<_FamilyPhotosContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('family', subType: 'photo_desc');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Collect all image paths from records
    final allImages = <String>[];
    for (final record in _records) {
      final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];
      for (final p in imagePaths) {
        if (p is String && p.isNotEmpty) allImages.add(p);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: allImages.isEmpty && _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无家庭照片', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: allImages.isNotEmpty ? allImages.length : _records.length,
              itemBuilder: (context, index) {
                if (allImages.isNotEmpty) {
                  return Dismissible(
                    key: Key('photo_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE57373).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                    ),
                    onDismissed: (_) {
                      // Find which record contains this image and remove it
                      _loadRecords();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(allImages[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.photo, size: 40, color: Colors.brown.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Show placeholder from records without images
                  final record = _records[index];
                  final title = record['title'] ?? '照片';
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.brown.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 30, color: Colors.brown.withOpacity(0.5)),
                          const SizedBox(height: 4),
                          Text(title, style: TextStyle(fontSize: 10, color: Colors.brown.withOpacity(0.6))),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'family', bookTitle: '家庭照片')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========== 学习册 ==========

class _ReadingRecordsContent extends StatefulWidget {
  const _ReadingRecordsContent();
  @override
  State<_ReadingRecordsContent> createState() => _ReadingRecordsContentState();
}

class _ReadingRecordsContentState extends State<_ReadingRecordsContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('learning', subType: 'book');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无读书记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('reading_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('learning', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imagePaths[0] as String),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.menu_book, color: Colors.brown, size: 28),
                              ),
                            )
                          else
                            const Icon(Icons.menu_book, color: Colors.brown, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (content.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(content.length > 80 ? '${content.substring(0, 80)}...' : content,
                                      style: TextStyle(color: Colors.grey[600])),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'learning', bookTitle: '读书记录')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _KnowledgeBaseContent extends StatefulWidget {
  const _KnowledgeBaseContent();
  @override
  State<_KnowledgeBaseContent> createState() => _KnowledgeBaseContentState();
}

class _KnowledgeBaseContentState extends State<_KnowledgeBaseContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('learning', subType: 'knowledge');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无知识库内容', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('点击右下角 + 添加', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('knowledge_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('learning', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(imagePaths[0] as String),
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.book, color: Colors.brown.withOpacity(0.5)),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.book, color: Colors.brown.withOpacity(0.5)),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (content.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(content.length > 60 ? '${content.substring(0, 60)}...' : content,
                                      style: TextStyle(color: Colors.grey[600])),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'learning', bookTitle: '知识库')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _LearningGrowthContent extends StatefulWidget {
  const _LearningGrowthContent();
  @override
  State<_LearningGrowthContent> createState() => _LearningGrowthContentState();
}

class _LearningGrowthContentState extends State<_LearningGrowthContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('learning', subType: 'skill');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无学习成长记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;

                return Dismissible(
                  key: Key('learning_growth_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('learning', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(content, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'learning', bookTitle: '学习成长')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========== 生活册 ==========

class _LifeRecordsContent extends StatefulWidget {
  const _LifeRecordsContent();
  @override
  State<_LifeRecordsContent> createState() => _LifeRecordsContentState();
}

class _LifeRecordsContentState extends State<_LifeRecordsContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('life', subType: 'daily');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无生活记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 16 ? '${time.substring(5, 10)} ${time.substring(11, 16)}' : time;
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('life_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('life', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(imagePaths[0] as String), width: 48, height: 48, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.note, color: Colors.brown.withOpacity(0.5), size: 32)),
                            )
                          else
                            Icon(Icons.note, color: Colors.brown.withOpacity(0.5), size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (content.isNotEmpty) Text(content.length > 60 ? '${content.substring(0, 60)}...' : content, style: TextStyle(color: Colors.grey[600])),
                                if (date.isNotEmpty) Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'life', bookTitle: '生活记录')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FinanceContent extends StatefulWidget {
  const _FinanceContent();
  @override
  State<_FinanceContent> createState() => _FinanceContentState();
}

class _FinanceContentState extends State<_FinanceContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('life', subType: 'finance');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无财务记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;

                return Dismissible(
                  key: Key('finance_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('life', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(Icons.attach_money, color: Colors.brown, size: 28),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (content.isNotEmpty) Text(content),
                          if (date.isNotEmpty) Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'life', bookTitle: '财务管理')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TravelContent extends StatefulWidget {
  const _TravelContent();
  @override
  State<_TravelContent> createState() => _TravelContentState();
}

class _TravelContentState extends State<_TravelContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('life', subType: 'travel');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无旅行记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('travel_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('life', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(imagePaths[0] as String), width: 60, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 60, height: 60,
                                      decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                      child: Icon(Icons.flight, color: Colors.brown.withOpacity(0.5)))),
                            )
                          else
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.flight, color: Colors.brown.withOpacity(0.5)),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (date.isNotEmpty) Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                if (content.isNotEmpty) Text(content.length > 40 ? '${content.substring(0, 40)}...' : content,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'life', bookTitle: '旅行收藏')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========== 工作册 ==========

class _TourGuideContent extends StatefulWidget {
  const _TourGuideContent();
  @override
  State<_TourGuideContent> createState() => _TourGuideContentState();
}

class _TourGuideContentState extends State<_TourGuideContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('work', subType: 'tour_guide');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无导游记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;

                return Dismissible(
                  key: Key('tour_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('work', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.map, color: Colors.brown, size: 24),
                              const SizedBox(width: 8),
                              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            ],
                          ),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ]),
                          ],
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(content, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'work', bookTitle: '导游事业')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SelfMediaContent extends StatefulWidget {
  const _SelfMediaContent();
  @override
  State<_SelfMediaContent> createState() => _SelfMediaContentState();
}

class _SelfMediaContentState extends State<_SelfMediaContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('work', subType: 'self_media');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无自媒体内容', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('media_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('work', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: imagePaths.isNotEmpty && imagePaths[0] is String
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(imagePaths[0] as String), width: 48, height: 48, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.video_library, size: 32, color: Colors.brown.withOpacity(0.5))),
                            )
                          : Icon(Icons.video_library, size: 32, color: Colors.brown.withOpacity(0.5)),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: content.isNotEmpty ? Text(content) : null,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'work', bookTitle: '自媒体')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AIAssistantContent extends StatefulWidget {
  const _AIAssistantContent();
  @override
  State<_AIAssistantContent> createState() => _AIAssistantContentState();
}

class _AIAssistantContentState extends State<_AIAssistantContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('work', subType: 'ai_assistant');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.smart_toy, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('暂无AI助手记录', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';

                return Dismissible(
                  key: Key('ai_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('work', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(Icons.smart_toy, size: 32, color: Colors.brown.withOpacity(0.5)),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: content.isNotEmpty ? Text(content) : null,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'work', bookTitle: 'AI助手')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========== 人生三见 ==========

class _SeeWorldContent extends StatefulWidget {
  const _SeeWorldContent();
  @override
  State<_SeeWorldContent> createState() => _SeeWorldContentState();
}

class _SeeWorldContentState extends State<_SeeWorldContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('three_views', subType: 'world');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('记录你对世界的观察与感悟', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('world_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('three_views', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(imagePaths[0] as String), height: 150, width: double.infinity, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                            )
                          else
                            const SizedBox.shrink(),
                          if (imagePaths.isNotEmpty && imagePaths[0] is String) const SizedBox(height: 12),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(content, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'three_views', bookTitle: '见天地')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SeeOthersContent extends StatefulWidget {
  const _SeeOthersContent();
  @override
  State<_SeeOthersContent> createState() => _SeeOthersContentState();
}

class _SeeOthersContentState extends State<_SeeOthersContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('three_views', subType: 'people');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('记录你对人的理解与共情', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('others_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('three_views', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(imagePaths[0] as String), height: 150, width: double.infinity, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                            )
                          else
                            const SizedBox.shrink(),
                          if (imagePaths.isNotEmpty && imagePaths[0] is String) const SizedBox(height: 12),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(content, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'three_views', bookTitle: '见众生')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SeeSelfContent extends StatefulWidget {
  const _SeeSelfContent();
  @override
  State<_SeeSelfContent> createState() => _SeeSelfContentState();
}

class _SeeSelfContentState extends State<_SeeSelfContent> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords('three_views', subType: 'self');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('记录你的自我反思与内心对话', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;
                final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

                return Dismissible(
                  key: Key('self_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord('three_views', record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePaths.isNotEmpty && imagePaths[0] is String)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(imagePaths[0] as String), height: 150, width: double.infinity, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                            )
                          else
                            const SizedBox.shrink(),
                          if (imagePaths.isNotEmpty && imagePaths[0] is String) const SizedBox(height: 12),
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(content, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: 'three_views', bookTitle: '见自己')));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ========== 通用内容 ==========

class _GenericContent extends StatefulWidget {
  final FeatureInfo feature;
  const _GenericContent({required this.feature});
  @override
  State<_GenericContent> createState() => _GenericContentState();
}

class _GenericContentState extends State<_GenericContent> {
  List<Map<String, dynamic>> _records = [];
  // Map feature title to bookType/subType for data loading
  late final String _bookType;
  late final String _subType;

  static const Map<String, List<String>> _featureMapping = {
    '家庭档案': ['family', 'archive'],
    '家庭日记': ['family', 'diary'],
    '家庭照片': ['family', 'photo_desc'],
    '读书记录': ['learning', 'book'],
    '知识库': ['learning', 'knowledge'],
    '学习成长': ['learning', 'skill'],
    '生活记录': ['life', 'daily'],
    '财务管理': ['life', 'finance'],
    '旅行收藏': ['life', 'travel'],
    '导游事业': ['work', 'tour_guide'],
    '自媒体': ['work', 'self_media'],
    'AI助手': ['work', 'ai_assistant'],
    '见天地': ['three_views', 'world'],
    '见众生': ['three_views', 'people'],
    '见自己': ['three_views', 'self'],
  };

  @override
  void initState() {
    super.initState();
    final mapping = _featureMapping[widget.feature.title] ?? ['general', 'default'];
    _bookType = mapping[0];
    _subType = mapping[1];
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = DataRepository().getRecords(_bookType, subType: _subType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction, size: 80, color: Colors.brown.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(widget.feature.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('点击右下角 + 添加内容', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final title = record['title'] ?? '未命名';
                final content = record['content'] ?? '';
                final time = (record['createTime'] ?? '').toString();
                final date = time.length >= 10 ? time.substring(0, 10) : time;

                return Dismissible(
                  key: Key('generic_${record['id'] ?? index}'),
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
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('确认删除'),
                        content: Text('确定要删除「$title」吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Color(0xFFE57373)))),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) async {
                    if (record['id'] != null) {
                      await DataRepository().deleteRecord(_bookType, record['id'] as String);
                    }
                    _loadRecords();
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                          if (content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(content, style: TextStyle(color: Colors.grey[700])),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecordPage(bookType: _bookType, bookTitle: widget.feature.title)));
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
