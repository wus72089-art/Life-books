import 'package:flutter/material.dart';
import '../services/repository.dart';
import 'settings_page.dart';
import 'statistics_page.dart';
import 'achievements_page.dart';
import 'annual_report_page.dart';
import 'social_media_page.dart';
import 'reminder_settings_page.dart';
import 'theme_settings_page.dart';
import 'privacy_settings_page.dart';
import 'backup_page.dart';
import 'export_page.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DataRepository();
    final counts = repo.getRecordCounts();
    final total = repo.totalRecords;
    final pendingSync = repo.pendingSyncCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF8F4EC),
            title: const Text(
              '我的',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Color(0xFF5C4033)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ));
                    },
                  ),
                  if (pendingSync > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ],
          ),
          // 个人信息卡
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5C4033), Color(0xFF8B6914)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5C4033).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white24,
                            child: Text('🧑', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '吴导',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '共 $total 条人生记录',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ProfileStat(value: '${counts['family'] ?? 0}', label: '家人'),
                        _ProfileStat(value: '${counts['learning'] ?? 0}', label: '学习'),
                        _ProfileStat(value: '${counts['life'] ?? 0}', label: '生活'),
                        _ProfileStat(value: '${counts['work'] ?? 0}', label: '工作'),
                        _ProfileStat(value: '${counts['three_views'] ?? 0}', label: '三见'),
                      ],
                    ),
                    if (pendingSync > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_sync, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '$pendingSync 条待同步',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // 功能菜单
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final section = _MenuSection.all[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            section.title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: _buildMenuItems(context, section.items),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: _MenuSection.all.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, List<_MenuItem> items) {
    return items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final isLast = i == items.length - 1;
      return Column(
        children: [
          ListTile(
            leading: Text(item.icon, style: const TextStyle(fontSize: 24)),
            title: Text(item.title),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            onTap: () => _handleMenuTap(context, item.title),
          ),
          if (!isLast) Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.1)),
        ],
      );
    }).toList();
  }

  void _handleMenuTap(BuildContext context, String title) {
    Widget? page;
    switch (title) {
      case '数据统计':
        page = const StatisticsPage();
        break;
      case '成就勋章':
        page = const AchievementsPage();
        break;
      case '年度报告':
        page = const AnnualReportPage();
        break;
      case '自媒体账号管理':
        page = const SocialMediaPage();
        break;
      case '提醒设置':
        page = const ReminderSettingsPage();
        break;
      case '主题与外观':
        page = const ThemeSettingsPage();
        break;
      case '隐私设置':
        page = const PrivacySettingsPage();
        break;
      case '数据备份':
        page = const BackupPage();
        break;
      case '导出与分享':
        page = const ExportPage();
        break;
      default:
        break;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title 功能开发中...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }
}

class _MenuItem {
  final String icon;
  final String title;
  const _MenuItem({required this.icon, required this.title});
}

class _MenuSection {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  static const List<_MenuSection> all = [
    _MenuSection(
      title: '人生数据',
      items: [
        _MenuItem(icon: '📊', title: '数据统计'),
        _MenuItem(icon: '🏆', title: '成就勋章'),
        _MenuItem(icon: '📅', title: '年度报告'),
      ],
    ),
    _MenuSection(
      title: '工具与设置',
      items: [
        _MenuItem(icon: '📱', title: '自媒体账号管理'),
        _MenuItem(icon: '🔔', title: '提醒设置'),
        _MenuItem(icon: '🎨', title: '主题与外观'),
      ],
    ),
    _MenuSection(
      title: '安全与隐私',
      items: [
        _MenuItem(icon: '🔒', title: '隐私设置'),
        _MenuItem(icon: '💾', title: '数据备份'),
        _MenuItem(icon: '📤', title: '导出与分享'),
      ],
    ),
  ];
}

extension on List<_MenuItem> {
  Map<int, _MenuItem> asMap() => {for (int i = 0; i < length; i++) i: this[i]};
}
