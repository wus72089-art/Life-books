import 'package:flutter/material.dart';
import 'services/local_database.dart';
import 'pages/main_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地数据库（离线存储）
  await LocalDatabase().initialize();

  // TODO: Firebase 初始化（配置完成后取消注释）
  // await FirebaseService().initialize();

  runApp(const LifeBookApp());
}

class LifeBookApp extends StatelessWidget {
  const LifeBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '人生五册',
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
