import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../services/repository.dart';

/// 导出与分享页面
class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  static const _bookNames = {
    'family': '家人册',
    'learning': '学习册',
    'life': '生活册',
    'work': '工作册',
    'three_views': '三见册',
  };

  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository();
    final counts = repo.getRecordCounts();
    final total = repo.totalRecords;

    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('导出与分享', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 概览
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
                const Text('可导出数据总量', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text('$total', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                const Text('条人生记录', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 导出选项
          _buildSectionTitle('导出格式'),

          // 导出为文本
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.article, color: _warmBrown, size: 22),
                  title: const Text('导出为文本文件', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('可读的纯文本格式，方便查看', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: _isExporting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: _isExporting ? null : () => _exportAsText(repo),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.data_object, color: _warmBrown, size: 22),
                  title: const Text('导出为 JSON 文件', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('结构化数据，适合备份和迁移', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: _isExporting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: _isExporting ? null : () => _exportAsJson(repo),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 分册子导出
          _buildSectionTitle('按册子导出'),
          ..._bookNames.entries.map((e) {
            final count = counts[e.key] ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(e.value, style: const TextStyle(fontSize: 14)),
                subtitle: Text('$count 条记录', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                onTap: count > 0 ? () => _exportSingleBook(repo, e.key, e.value) : null,
              ),
            );
          }),
          const SizedBox(height: 20),

          // 分享
          _buildSectionTitle('分享'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.copy, color: _warmBrown, size: 22),
                  title: const Text('复制摘要到剪贴板', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('复制数据概览文字', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () => _copySummaryToClipboard(repo, counts, total),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warmBrown.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: _warmBrown, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '导出的文件保存在应用文档目录中，可通过文件管理器访问。',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _warmBrown)),
    );
  }

  Future<void> _exportAsText(DataRepository repo) async {
    setState(() => _isExporting = true);
    try {
      final buffer = StringBuffer();
      buffer.writeln('═══════════════════════════════════');
      buffer.writeln('         人生五册 - 数据导出');
      buffer.writeln('         ${DateTime.now().toString().substring(0, 10)}');
      buffer.writeln('═══════════════════════════════════\n');

      for (final entry in _bookNames.entries) {
        final records = repo.getRecords(entry.key);
        buffer.writeln('━━━ ${entry.value} (${records.length} 条) ━━━\n');
        for (final r in records) {
          final title = r['title'] ?? '(无标题)';
          final content = r['content'] ?? '';
          final time = (r['createTime'] ?? '').toString().substring(0, 10);
          buffer.writeln('【$time】$title');
          if (content.toString().isNotEmpty) {
            buffer.writeln('  $content');
          }
          final tags = r['tags'] as List<dynamic>?;
          if (tags != null && tags.isNotEmpty) {
            buffer.writeln('  标签: ${tags.join(', ')}');
          }
          buffer.writeln('');
        }
        buffer.writeln('');
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'life_books_export_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导出文本文件：$fileName'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportAsJson(DataRepository repo) async {
    setState(() => _isExporting = true);
    try {
      final data = <String, dynamic>{
        'version': '4.1.0',
        'exportTime': DateTime.now().toIso8601String(),
      };
      for (final bt in _bookNames.keys) {
        data[bt] = repo.getRecords(bt);
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'life_books_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导出JSON文件：$fileName'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportSingleBook(DataRepository repo, String bookType, String bookName) async {
    setState(() => _isExporting = true);
    try {
      final records = repo.getRecords(bookType);
      final buffer = StringBuffer();
      buffer.writeln('━━━ $bookName (${records.length} 条) ━━━\n');
      for (final r in records) {
        final title = r['title'] ?? '(无标题)';
        final content = r['content'] ?? '';
        final time = (r['createTime'] ?? '').toString().substring(0, 10);
        buffer.writeln('【$time】$title');
        if (content.toString().isNotEmpty) {
          buffer.writeln('  $content');
        }
        buffer.writeln('');
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${bookType}_export_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导出：$fileName'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.red),
        );
      }
    }
  }

  void _copySummaryToClipboard(DataRepository repo, Map<String, int> counts, int total) {
    final buffer = StringBuffer();
    buffer.writeln('📚 人生五册 - 数据摘要');
    buffer.writeln('📅 ${DateTime.now().toString().substring(0, 10)}');
    buffer.writeln('');
    buffer.writeln('总记录数：$total');
    buffer.writeln('');
    for (final entry in counts.entries) {
      final name = _bookNames[entry.key] ?? entry.key;
      buffer.writeln('  $name：${entry.value} 条');
    }
    buffer.writeln('');
    buffer.writeln('— 由人生五册APP导出');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), behavior: SnackBarBehavior.floating),
    );
  }
}
