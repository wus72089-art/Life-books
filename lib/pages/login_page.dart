import 'package:flutter/material.dart';
import '../services/local_database.dart';
import 'main_page.dart';

/// 登录页面 - 支持邮箱登录/注册 + 离线体验模式
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _db = LocalDatabase();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text('🌏', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                '人生五册',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5C4033)),
              ),
              const SizedBox(height: 8),
              Text('记录今天，收藏人生', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 50),

              // 邮箱输入
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // 密码输入
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // 登录/注册按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5C4033),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(_isLogin ? '登录' : '注册', style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // 切换模式
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? '没有账号？立即注册' : '已有账号？返回登录',
                  style: const TextStyle(color: Color(0xFF5C4033)),
                ),
              ),

              const SizedBox(height: 20),

              // 体验模式
              OutlinedButton.icon(
                onPressed: _handleDemoLogin,
                icon: const Icon(Icons.visibility),
                label: const Text('体验模式（无需登录）'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5C4033),
                  side: const BorderSide(color: Color(0xFF5C4033)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '体验模式下数据仅保存在本地',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack('请填写邮箱和密码');
      return;
    }

    if (password.length < 6) {
      _showSnack('密码至少 6 位');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 保存用户信息到本地
      final userId = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      await _db.saveUser('current', {
        'userId': userId,
        'email': email,
        'displayName': email.split('@').first,
        'loginTime': DateTime.now().toIso8601String(),
        'isDemo': false,
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack('登录失败: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDemoLogin() async {
    // 保存体验用户到本地
    await _db.saveUser('current', {
      'userId': 'demo_user',
      'email': '',
      'displayName': '吴导',
      'loginTime': DateTime.now().toIso8601String(),
      'isDemo': true,
    });

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
