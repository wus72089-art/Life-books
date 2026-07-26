import 'package:flutter/material.dart';
import '../services/repository.dart';
import '../services/local_database.dart';
import '../services/network_service.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _repo = DataRepository();
  final _db = LocalDatabase();
  final _net = NetworkService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // 网络与同步
          _buildSectionHeader('数据同步'),
          _buildSyncCard(),
          const SizedBox(height: 16),

          // 存储管理
          _buildSectionHeader('存储管理'),
          _buildStorageCard(),
          const SizedBox(height: 16),

          // 显示设置
          _buildSectionHeader('显示设置'),
          _buildDisplaySettings(),
          const SizedBox(height: 16),

          // 关于
          _buildSectionHeader('关于'),
          _buildAboutCard(),
          const SizedBox(height: 16),

          // 退出
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: _confirmClearData,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('清除本地数据'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildSyncCard() {
    final pending = _repo.pendingSyncCount;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.cloud_sync_rounded,
            iconColor: _net.isOnline ? Colors.green : Colors.orange,
            title: '同步状态',
            subtitle: _net.isOnline ? '已连接云端' : '当前离线，数据已本地保存',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _net.isOnline ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _net.isOnline ? '在线' : '离线',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _net.isOnline ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.pending_actions_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '待同步记录',
            subtitle: pending > 0 ? '$pending 条记录等待上传' : '全部已同步',
            trailing: pending > 0
                ? TextButton(
                    onPressed: _syncNow,
                    child: const Text('立即同步'),
                  )
                : const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    final counts = _repo.getRecordCounts();
    final total = _repo.totalRecords;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.storage_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '本地数据总量',
            subtitle: '共 $total 条记录',
          ),
          const Divider(height: 1),
          _buildSubStat('家人册', counts['family'] ?? 0),
          _buildSubStat('学习册', counts['learning'] ?? 0),
          _buildSubStat('生活册', counts['life'] ?? 0),
          _buildSubStat('工作册', counts['work'] ?? 0),
          _buildSubStat('人生三鉴', counts['three_views'] ?? 0),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.download_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '导出数据',
            subtitle: '将所有数据导出为 JSON 文件',
            onTap: _exportData,
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String name, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text('$count 条', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '深色模式',
            subtitle: '暂未开放',
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.text_fields_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '字体大小',
            subtitle: '标准',
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '语言',
            subtitle: '简体中文',
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildListTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF5C4033),
            title: '版本',
            subtitle: 'V3.0.0 (Build 20260726)',
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Icons.favorite_outline_rounded,
            iconColor: Colors.red,
            title: '人生五册',
            subtitle: '记录今天，收藏人生',
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing ?? const SizedBox(),
      onTap: onTap,
    );
  }

  void _syncNow() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在同步数据...'),
          ],
        ),
      ),
    );

    _repo.syncPendingItems().then((result) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.failed == 0 ? Colors.green : Colors.orange,
          ),
        );
        setState(() {});
      }
    });
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据导出功能开发中...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('将清除所有本地数据，此操作不可恢复。建议先导出数据备份。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('清除功能开发中...')),
    );
  }
}
