import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 提醒设置页面
class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  static const _warmBrown = Color(0xFF5C4033);
  static const _creamBg = Color(0xFFF8F4EC);

  late Box<String> _settingsBox;

  bool _dailyReminder = false;
  TimeOfDay _dailyTime = const TimeOfDay(hour: 21, minute: 0);
  bool _weeklySummary = false;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box<String>('settings');
    _loadSettings();
  }

  void _loadSettings() {
    final daily = _settingsBox.get('reminder_daily');
    _dailyReminder = daily == 'true';

    final timeStr = _settingsBox.get('reminder_daily_time');
    if (timeStr != null) {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        _dailyTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 21,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final weekly = _settingsBox.get('reminder_weekly');
    _weeklySummary = weekly == 'true';
  }

  Future<void> _saveDailyReminder(bool value) async {
    _dailyReminder = value;
    await _settingsBox.put('reminder_daily', value.toString());
    setState(() {});
  }

  Future<void> _saveDailyTime(TimeOfDay time) async {
    _dailyTime = time;
    await _settingsBox.put('reminder_daily_time', '${time.hour}:${time.minute}');
    setState(() {});
  }

  Future<void> _saveWeeklySummary(bool value) async {
    _weeklySummary = value;
    await _settingsBox.put('reminder_weekly', value.toString());
    setState(() {});
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      appBar: AppBar(
        title: const Text('提醒设置', style: TextStyle(color: _warmBrown, fontWeight: FontWeight.bold)),
        backgroundColor: _creamBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _warmBrown),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 每日提醒
          _buildSectionTitle('每日提醒'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('开启每日记录提醒', style: TextStyle(fontSize: 15)),
                  subtitle: const Text('每天提醒你记录生活', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  value: _dailyReminder,
                  activeColor: _warmBrown,
                  onChanged: _saveDailyReminder,
                ),
                if (_dailyReminder) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.schedule, color: _warmBrown, size: 22),
                    title: const Text('提醒时间', style: TextStyle(fontSize: 15)),
                    trailing: Text(
                      _formatTime(_dailyTime),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _warmBrown),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _dailyTime,
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(primary: _warmBrown),
                          ),
                          child: child!,
                        ),
                      );
                      if (time != null) {
                        _saveDailyTime(time);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 每周总结
          _buildSectionTitle('每周总结'),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('开启每周总结提醒', style: TextStyle(fontSize: 15)),
              subtitle: const Text('每周日提醒你回顾本周记录', style: TextStyle(fontSize: 12, color: Colors.grey)),
              value: _weeklySummary,
              activeColor: _warmBrown,
              onChanged: _saveWeeklySummary,
            ),
          ),
          const SizedBox(height: 20),

          // 说明
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warmBrown.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: _warmBrown, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '提醒功能需要应用在前台或后台运行时才会触发通知。',
                    style: TextStyle(fontSize: 12, color: _warmBrown.withValues(alpha: 0.7)),
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
}
