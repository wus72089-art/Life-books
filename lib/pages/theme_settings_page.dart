import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题与外观页面
class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  /// 当前主题模式（供 main.dart 读取）
  static ThemeMode currentThemeMode = ThemeMode.system;

  /// 从 SharedPreferences 恢复主题设置
  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString('theme_mode') ?? 'system';
      switch (mode) {
        case 'light':
          currentThemeMode = ThemeMode.light;
          break;
        case 'dark':
          currentThemeMode = ThemeMode.dark;
          break;
        default:
          currentThemeMode = ThemeMode.system;
      }
    } catch (_) {
      currentThemeMode = ThemeMode.system;
    }
  }

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = ThemeSettingsPage.currentThemeMode;
  }

  Future<void> _selectTheme(ThemeMode mode) async {
    _selectedMode = mode;
    ThemeSettingsPage.currentThemeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString('theme_mode', 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString('theme_mode', 'dark');
        break;
      default:
        await prefs.setString('theme_mode', 'system');
    }

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('主题已切换，重启应用后生效'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('主题与外观', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('选择主题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 12),

          _buildThemeOption(
            title: '浅色模式',
            subtitle: '温暖的奶白色界面',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            previewColors: [const Color(0xFFF8F4EC), const Color(0xFF5C4033), Colors.white],
          ),
          const SizedBox(height: 10),
          _buildThemeOption(
            title: '深色模式',
            subtitle: '夜间舒适的深色界面',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            previewColors: [const Color(0xFF1A1A2E), const Color(0xFFE0D5C1), const Color(0xFF2D2D44)],
          ),
          const SizedBox(height: 10),
          _buildThemeOption(
            title: '跟随系统',
            subtitle: '自动适配系统主题设置',
            icon: Icons.settings_suggest,
            mode: ThemeMode.system,
            previewColors: [const Color(0xFFF8F4EC), const Color(0xFF1A1A2E), const Color(0xFF5C4033)],
          ),

          const SizedBox(height: 24),

          // 当前选择提示
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warmBrown.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: _warmBrown, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '当前：${_modeName(_selectedMode)}',
                    style: const TextStyle(fontSize: 13, color: _warmBrown),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 配色预览
          const Text('当前配色方案', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _warmBrown)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    _colorSwatch(const Color(0xFFF8F4EC), '奶白底'),
                    const SizedBox(width: 12),
                    _colorSwatch(const Color(0xFF5C4033), '暖棕主色'),
                    const SizedBox(width: 12),
                    _colorSwatch(const Color(0xFF8B6914), '金色强调'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _colorSwatch(const Color(0xFFD4A574), '浅棕辅助'),
                    const SizedBox(width: 12),
                    _colorSwatch(const Color(0xFF6B8E6B), '自然绿'),
                    const SizedBox(width: 12),
                    _colorSwatch(const Color(0xFF7B6BA5), '淡紫点缀'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required List<Color> previewColors,
  }) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => _selectTheme(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _warmBrown : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? _warmBrown.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _warmBrown : Colors.grey, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? _warmBrown : Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // 预览色块
            Row(
              children: previewColors.map((c) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(width: 16, height: 16, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.grey.shade300))),
              )).toList(),
            ),
            const SizedBox(width: 8),
            if (isSelected) const Icon(Icons.check_circle, color: _warmBrown, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _colorSwatch(Color color, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  String _modeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      default:
        return '跟随系统';
    }
  }
}
