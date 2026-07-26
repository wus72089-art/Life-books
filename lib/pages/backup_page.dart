import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/repository.dart';

/// 数据备份页面
class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  String? _lastBackupTime;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadLastBackupTime();
  }

  void _loadLastBackupTime() {
    final repo = DataRepository();
    _lastBackupTime = repo.getLastBackupTime();
  }

  Future<void> _performBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final repo = DataRepository();
      final allData = repo.exportAllData();
      final jsonString = jsonEncode(allData);

      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${backupDir.path}/backup_$timestamp.json');
      await file.writeAsString(jsonString);

      // 更新最后备份时间
      repo.setLastBackupTime(DateTime.now().toIso8601String());
      _lastBackupTime = DateTime.now().toIso8601String();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('备份成功！文件：backup_$timestamp.json'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('备份失败：$e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreBackup() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复备份'),
        content: const Text('选择要恢复的备份文件（功能开发中）'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定')),
        ],
      ),
    );
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '从未备份';
    try {
      final time = DateTime.parse(isoTime);
      return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('数据备份', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 最后备份时间
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
                const Icon(Icons.cloud_done, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text('上次备份', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _formatTime(_lastBackupTime),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 备份操作
          _buildActionCard(
            icon: Icons.backup,
            title: '立即备份',
            subtitle: '将所有数据备份到本地文件',
            onTap: _isBackingUp ? null : _performBackup,
            isLoading: _isBackingUp,
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            icon: Icons.restore,
            title: '恢复备份',
            subtitle: '从本地备份文件恢复数据',
            onTap: _restoreBackup,
          ),
          const SizedBox(height: 20),

          // 说明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warmBrown.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: _warmBrown, size: 18),
                    const SizedBox(width: 10),
                    Text('备份说明', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _warmBrown)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• 备份文件保存在应用本地目录\n• 更换设备时需要手动迁移备份文件\n• 建议定期备份以防数据丢失',
                  style: TextStyle(fontSize: 12, color: _warmBrown.withValues(alpha: 0.7), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: onTap == null ? Colors.grey : _warmBrown, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: onTap == null ? Colors.grey : _warmBrown)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _warmBrown),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
