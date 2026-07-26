import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 隐私设置页面
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  late Box<String> _settingsBox;

  bool _appLock = false;
  bool _fingerprint = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box<String>('settings');
    _loadSettings();
  }

  void _loadSettings() {
    _appLock = _settingsBox.get('privacy_app_lock') == 'true';
    _fingerprint = _settingsBox.get('privacy_fingerprint') == 'true';
  }

  Future<void> _toggleAppLock(bool value) async {
    if (value) {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('设置应用锁密码'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(hintText: '请输入4-8位密码'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            TextButton(
              onPressed: () {
                if (controller.text.length >= 4) Navigator.pop(ctx, true);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await _settingsBox.put('privacy_app_lock_password', controller.text);
    } else {
      await _settingsBox.delete('privacy_app_lock_password');
      _fingerprint = false;
      await _settingsBox.put('privacy_fingerprint', 'false');
    }
    _appLock = value;
    await _settingsBox.put('privacy_app_lock', value.toString());
    setState(() {});
  }

  Future<void> _toggleFingerprint(bool value) async {
    _fingerprint = value;
    await _settingsBox.put('privacy_fingerprint', value.toString());
    setState(() {});
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ 清除所有本地数据'),
        content: const Text('此操作将删除所有记录数据且无法恢复！\n\n建议先导出备份后再执行。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
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
    const boxes = ['family_records', 'learning_records', 'life_records', 'work_records', 'three_views', 'sync_queue'];
    for (final name in boxes) {
      try {
        Hive.box<String>(name).clear();
      } catch (_) {}
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('本地数据已清除'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('隐私设置', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 应用安全
          _buildSectionTitle('应用安全'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('应用锁', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('打开应用时需要输入密码', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  secondary: const Icon(Icons.lock, color: _warmBrown, size: 22),
                  value: _appLock,
                  activeColor: _warmBrown,
                  onChanged: _toggleAppLock,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('指纹解锁', style: TextStyle(fontSize: 15)),
                  subtitle: Text(
                    _appLock ? '使用指纹快速解锁' : '需先开启应用锁',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  secondary: Icon(Icons.fingerprint, color: _appLock ? _warmBrown : Colors.grey, size: 22),
                  value: _appLock ? _fingerprint : false,
                  activeColor: _warmBrown,
                  onChanged: _appLock ? _toggleFingerprint : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 数据管理
          _buildSectionTitle('数据管理'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_sweep, color: Colors.red, size: 22),
                  title: const Text('清除本地数据', style: TextStyle(fontSize: 15, color: Colors.red)),
                  subtitle: const Text('删除所有记录和缓存数据', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: _confirmClearData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 关于
          _buildSectionTitle('关于'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: _warmBrown, size: 22),
                  title: Text('版本', style: TextStyle(fontSize: 15)),
                  subtitle: Text('V4.1.0 (Build 20260726)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.favorite_outline, color: Colors.red, size: 22),
                  title: const Text('人生五册', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('记录今天，收藏人生', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: '人生五册',
                      applicationVersion: '4.1.0',
                      applicationIcon: const Text('📚', style: TextStyle(fontSize: 40)),
                      children: [
                        const SizedBox(height: 12),
                        const Text('人生五册是一个个人数字生命管理工具，帮助你记录和家人、学习、生活、工作以及人生三见相关的每一条重要记录。'),
                        const SizedBox(height: 8),
                        const Text('Made with ❤️ by 吴导', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.shield, color: _warmBrown, size: 22),
                  title: Text('隐私政策', style: TextStyle(fontSize: 15)),
                  subtitle: Text('数据仅存储在本地设备', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
}
