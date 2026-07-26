import 'dart:io';
import 'package:flutter/material.dart';
import '../services/repository.dart';
import 'add_record_page.dart';

/// 记录详情页
class RecordDetailPage extends StatelessWidget {
  final Map<String, dynamic> record;
  final String bookType;
  final String bookTitle;

  const RecordDetailPage({
    super.key,
    required this.record,
    required this.bookType,
    required this.bookTitle,
  });

  @override
  Widget build(BuildContext context) {
    final title = (record['title'] ?? '无标题') as String;
    final content = (record['content'] ?? '') as String;
    final time = (record['createTime'] ?? '').toString();
    final tags = (record['tags'] as List<dynamic>?) ?? [];
    final imagePaths = (record['imagePaths'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4EC),
        title: Text(bookTitle, style: const TextStyle(color: Color(0xFF5C4033))),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF5C4033)),
            tooltip: '编辑',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => AddRecordPage(
                  bookType: bookType,
                  bookTitle: bookTitle,
                  existingRecord: record,
                ),
              )).then((result) {
                if (result == true && context.mounted) {
                  Navigator.of(context).pop(true);
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C4033),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // 时间
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF5C4033)),
                const SizedBox(width: 6),
                Text(
                  _formatTime(time),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF5C4033)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 分割线
            Container(height: 1, color: const Color(0xFF5C4033).withOpacity(0.1)),
            const SizedBox(height: 24),

            // 正文内容
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
                height: 1.8,
              ),
            ),
            const SizedBox(height: 24),

            // 图片区域
            if (imagePaths.isNotEmpty) ...[
              _buildSectionTitle('图片'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  final path = imagePaths[index] as String;
                  return GestureDetector(
                    onTap: () => _showFullScreenImage(context, path, imagePaths.map((e) => e.toString()).toList(), index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // 标签区域
            if (tags.isNotEmpty) ...[
              _buildSectionTitle('标签'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C4033).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5C4033),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 40),

            // 删除按钮
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFE57373)),
                label: const Text(
                  '删除此记录',
                  style: TextStyle(color: Color(0xFFE57373), fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE57373)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    if (time.length >= 16) {
      return '${time.substring(0, 10)} ${time.substring(11, 16)}';
    }
    return time;
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5C4033),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String path, List<String> allPaths, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImagePage(imagePaths: allPaths, initialIndex: index),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${record['title'] ?? '无标题'}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              final id = record['id'];
              if (id != null) {
                await DataRepository().deleteRecord(bookType, id as String);
                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              }
            },
            child: const Text('删除', style: TextStyle(color: Color(0xFFE57373))),
          ),
        ],
      ),
    );
  }
}

/// 全屏图片查看器
class _FullScreenImagePage extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _FullScreenImagePage({required this.imagePaths, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(imagePaths[index]),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
