import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 自媒体账号管理页面
class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({super.key});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  late Box<String> _settingsBox;

  static const _platforms = [
    {'name': '抖音', 'icon': '🎵', 'color': Color(0xFF000000)},
    {'name': '小红书', 'icon': '📕', 'color': Color(0xFFFF2442)},
    {'name': 'B站', 'icon': '📺', 'color': Color(0xFF00A1D6)},
    {'name': '微信公众号', 'icon': '💬', 'color': Color(0xFF07C160)},
    {'name': '微博', 'icon': '🔥', 'color': Color(0xFFFF8200)},
  ];

  // key: social_media_{platformName}, value: JSON list of accounts
  List<Map<String, String>> _getAccounts(String platform) {
    final raw = _settingsBox.get('social_media_$platform');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAccounts(String platform, List<Map<String, String>> accounts) async {
    await _settingsBox.put('social_media_$platform', jsonEncode(accounts));
  }

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box<String>('settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('自媒体账号管理', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _platforms.length,
        itemBuilder: (context, index) {
          final p = _platforms[index];
          final name = p['name']! as String;
          final icon = p['icon']! as String;
          final color = p['color']! as Color;
          final accounts = _getAccounts(name);
          return _buildPlatformCard(name, icon, color, accounts);
        },
      ),
    );
  }

  Widget _buildPlatformCard(String name, String icon, Color color, List<Map<String, String>> accounts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown)),
                const Spacer(),
                if (accounts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${accounts.length} 个账号', style: TextStyle(fontSize: 11, color: color)),
                  ),
              ],
            ),
          ),
          // 账号列表
          if (accounts.isNotEmpty) ...[
            ...accounts.asMap().entries.map((e) {
              final idx = e.key;
              final account = e.value;
              return Column(
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(account['name']?.substring(0, 1) ?? '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    title: Text(account['name'] ?? '未命名', style: const TextStyle(fontSize: 14)),
                    subtitle: Text(account['link'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: _warmBrown),
                          onPressed: () => _editAccount(name, accounts, idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () => _deleteAccount(name, accounts, idx),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
          // 添加按钮
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(Icons.add_circle_outline, color: color, size: 22),
            title: Text('添加${name}账号', style: TextStyle(fontSize: 14, color: color)),
            onTap: () => _addAccount(name, accounts),
          ),
        ],
      ),
    );
  }

  void _addAccount(String platform, List<Map<String, String>> accounts) {
    _showEditDialog(platform, accounts, null, null);
  }

  void _editAccount(String platform, List<Map<String, String>> accounts, int index) {
    _showEditDialog(platform, accounts, index, accounts[index]);
  }

  void _deleteAccount(String platform, List<Map<String, String>> accounts, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定删除账号「${accounts[index]['name']}」？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('删除')),
        ],
      ),
    );
    if (confirm == true) {
      accounts.removeAt(index);
      await _saveAccounts(platform, accounts);
      setState(() {});
    }
  }

  void _showEditDialog(String platform, List<Map<String, String>> accounts, int? editIndex, Map<String, String>? existing) {
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final linkController = TextEditingController(text: existing?['link'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editIndex != null ? '编辑账号' : '添加账号'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '账号名称', hintText: '如：我的小红书号'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(labelText: '链接', hintText: '如：https://...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final link = linkController.text.trim();
              if (name.isEmpty) return;

              final account = {'name': name, 'link': link};
              if (editIndex != null) {
                accounts[editIndex] = account;
              } else {
                accounts.add(account);
              }
              await _saveAccounts(platform, accounts);
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}


