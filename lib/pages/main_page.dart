import 'package:flutter/material.dart';
import 'home_page.dart';
import 'record_page.dart';
import 'ai_page.dart';
import 'timeline_page.dart';
import 'mine_page.dart';
import '../services/network_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    RecordPage(),
    AIPage(),
    TimelinePage(),
    MinePage(),
  ];

  final _net = NetworkService();

  @override
  void initState() {
    super.initState();
    _net.initialize();
    _net.startPeriodicCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_index],
          // 离线状态横幅
          if (!_net.isOnline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: Colors.orange,
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      const Text(
                        '离线模式 · 数据已本地保存',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: const Color(0xFF5C4033),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_rounded), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_rounded), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_rounded), label: '时间轴'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: '我的'),
        ],
      ),
    );
  }
}
