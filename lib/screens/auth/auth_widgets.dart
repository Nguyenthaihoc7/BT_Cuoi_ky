import 'package:flutter/material.dart';

/// Khung nền dùng chung cho màn hình đăng nhập/đăng ký.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.children, this.showBack = false});

  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const <Color>[
                          Color(0xFF171833),
                          Color(0xFF0F1020),
                          Color(0xFF1A1024),
                        ]
                      : const <Color>[
                          Color(0xFFEEF0FF),
                          Color(0xFFF7F6FC),
                          Color(0xFFFDF1F6),
                        ],
                  stops: const <double>[0, 0.55, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -70,
            child: _GlowCircle(
              size: 240,
              color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.09),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -90,
            child: _GlowCircle(
              size: 280,
              color: const Color(0xFFDB2777)
                  .withValues(alpha: isDark ? 0.1 : 0.06),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (showBack)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: IconButton.filledTonal(
                              onPressed: () => Navigator.of(context).maybePop(),
                              tooltip: 'Quay lại',
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                        ),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Logo và tên ứng dụng.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = compact ? 62.0 : 78.0;
    return Column(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
                Color(0xFFDB2777),
              ],
            ),
            borderRadius: BorderRadius.circular(compact ? 20 : 25),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.calculate_rounded,
            color: Colors.white,
            size: compact ? 34 : 42,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Trợ lý Toán học',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tính nhanh • Hiểu sâu • Lưu lại',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
