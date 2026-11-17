import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_scope.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_shell.dart';
import 'services/auth_service.dart';
import 'services/history_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    final auth = AuthService();
    final history = HistoryService();
    await auth.init();
    await history.init();

    runApp(MathAssistantApp(auth: auth, history: history));
  } catch (_) {
    runApp(const _StartupErrorApp());
  }
}

class MathAssistantApp extends StatefulWidget {
  const MathAssistantApp({
    super.key,
    required this.auth,
    required this.history,
  });

  final AuthService auth;
  final HistoryService history;

  @override
  State<MathAssistantApp> createState() => _MathAssistantAppState();
}

class _MathAssistantAppState extends State<MathAssistantApp> {
  @override
  void initState() {
    super.initState();
    // Khi đăng nhập/đăng xuất, nạp lại lịch sử của đúng tài khoản.
    widget.auth.addListener(_handleAuthChanged);
    widget.history.loadForUser(widget.auth.currentUser?.id);
  }

  void _handleAuthChanged() {
    widget.history.loadForUser(widget.auth.currentUser?.id);
  }

  @override
  void dispose() {
    widget.auth.removeListener(_handleAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      auth: widget.auth,
      history: widget.history,
      child: MaterialApp(
        title: 'Trợ lý Toán học',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AuthGate(),
      ),
    );
  }
}

/// Chuyển giữa màn hình đăng nhập và ứng dụng dựa trên trạng thái đăng nhập.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: auth.isLoggedIn
              ? const HomeShell(key: ValueKey<String>('home'))
              : const LoginScreen(key: ValueKey<String>('login')),
        );
      },
    );
  }
}

/// Màn hình dự phòng khi không khởi tạo được bộ nhớ cục bộ.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trợ lý Toán học',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 54,
                    color: Color(0xFFB91C1C),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể khởi tạo dữ liệu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ứng dụng không mở được bộ nhớ cục bộ. Vui lòng khởi động '
                    'lại ứng dụng hoặc kiểm tra dung lượng thiết bị.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
