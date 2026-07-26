import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/local_database.dart';
import 'pages/main_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地数据库（离线存储）
  await LocalDatabase().initialize();

  // 加载主题设置
  final prefs = await SharedPreferences.getInstance();
  final themeMode = prefs.getString('theme_mode') ?? 'system';
  ThemeMode initialThemeMode;
  switch (themeMode) {
    case 'light':
      initialThemeMode = ThemeMode.light;
      break;
    case 'dark':
      initialThemeMode = ThemeMode.dark;
      break;
    default:
      initialThemeMode = ThemeMode.system;
  }

  // TODO: Firebase 初始化（配置完成后取消注释）
  // await FirebaseService().initialize();

  runApp(LifeBookApp(key: LifeBookApp.globalKey, initialThemeMode: initialThemeMode));
}

class LifeBookApp extends StatefulWidget {
  const LifeBookApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  /// 全局 key，用于从外部获取 State 并切换主题
  static final GlobalKey<_LifeBookAppState> globalKey = GlobalKey<_LifeBookAppState>();

  /// 便捷方法：设置主题模式
  static void setThemeMode(ThemeMode mode) {
    globalKey.currentState?.setThemeMode(mode);
  }

  @override
  State<LifeBookApp> createState() => _LifeBookAppState();
}

class _LifeBookAppState extends State<LifeBookApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '人生五册',
      themeMode: _themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F4EC),
        primaryColor: const Color(0xFF5C4033),
        colorSchemeSeed: const Color(0xFF5C4033),
        useMaterial3: true,
        brightness: Brightness.light,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F4EC),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1210),
        primaryColor: const Color(0xFFD7CCC8),
        colorSchemeSeed: const Color(0xFFBCAAA4),
        useMaterial3: true,
        brightness: Brightness.dark,
        cardTheme: CardThemeData(
          color: const Color(0xFF2D2220),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1210),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      // 有本地缓存的用户信息时直接进入主页，否则显示登录
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final user = LocalDatabase().getUser('current');
    if (user != null) {
      return const MainPage();
    }
    return const LoginPage();
  }
}
