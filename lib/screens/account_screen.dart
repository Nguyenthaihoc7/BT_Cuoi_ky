import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../logic/number_format.dart';
import '../models/problem_type.dart';
import '../services/auth_service.dart';
import '../services/history_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/section_card.dart';

/// Màn hình tài khoản: thông tin, dữ liệu và đăng xuất.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _clearHistory(
    BuildContext context,
    HistoryService history,
  ) async {
    final count = history.totalCount;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa toàn bộ lịch sử?',
      message:
          'Tất cả $count bản ghi của tài khoản hiện tại sẽ bị xóa vĩnh viễn. '
          'Hành động này không thể hoàn tác.',
      confirmLabel: 'Xóa tất cả',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await history.clearAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa toàn bộ lịch sử.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa lịch sử. Vui lòng thử lại.'),
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context, AuthService auth) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Đăng xuất?',
      message:
          'Bạn sẽ cần đăng nhập lại để tiếp tục. Lịch sử vẫn được giữ trên '
          'thiết bị cho tài khoản này.',
      confirmLabel: 'Đăng xuất',
      icon: Icons.logout_rounded,
      destructive: false,
    );
    if (!confirmed) return;
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scope = AppScope.of(context);
    final auth = scope.auth;
    final history = scope.history;
    final user = auth.currentUser;

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final total = history.totalCount;
        final counts = history.countsByType;
        final usedTools = counts.values.where((count) => count > 0).length;

        return Scaffold(
          appBar: AppBar(title: const Text('Tài khoản')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Color(0xFF4338CA), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user?.initial ?? '?',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user?.username ?? 'Người dùng',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user == null
                                  ? ''
                                  : 'Thành viên từ ${formatDate(user.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Đã đăng nhập',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.history_rounded,
                        color: const Color(0xFF0F766E),
                        label: 'Tổng lượt tính',
                        value: '$total',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        icon: Icons.widgets_rounded,
                        color: const Color(0xFF7C3AED),
                        label: 'Công cụ đã dùng',
                        value: '$usedTools/${ProblemType.values.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Dữ liệu & bảo mật',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SectionCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: <Widget>[
                      const _InfoRow(
                        icon: Icons.storage_rounded,
                        color: Color(0xFF2563EB),
                        title: 'Lưu trữ trên thiết bị',
                        subtitle:
                            'Hive • Dữ liệu vẫn còn sau khi đóng ứng dụng',
                      ),
                      Divider(
                        height: 1,
                        indent: 64,
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      const _InfoRow(
                        icon: Icons.lock_rounded,
                        color: Color(0xFF0F766E),
                        title: 'Mật khẩu được bảo vệ',
                        subtitle:
                            'Băm SHA-256 kèm salt riêng cho từng tài khoản',
                      ),
                      Divider(
                        height: 1,
                        indent: 64,
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      const _InfoRow(
                        icon: Icons.privacy_tip_rounded,
                        color: Color(0xFFB45309),
                        title: 'Lịch sử riêng tư',
                        subtitle: 'Mỗi tài khoản chỉ xem lịch sử của mình',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quản lý tài khoản',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SectionCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: <Widget>[
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          onTap: total == 0
                              ? null
                              : () => _clearHistory(context, history),
                          leading: _LeadingIcon(
                            icon: Icons.delete_sweep_outlined,
                            color: scheme.error,
                          ),
                          title: Text(
                            'Xóa toàn bộ lịch sử',
                            style: TextStyle(
                              color: total == 0 ? null : scheme.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            total == 0
                                ? 'Chưa có bản ghi nào'
                                : '$total bản ghi sẽ bị xóa vĩnh viễn',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 64,
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          onTap: () => _logout(context, auth),
                          leading: _LeadingIcon(
                            icon: Icons.logout_rounded,
                            color: scheme.error,
                          ),
                          title: Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: scheme.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Trợ lý Toán học • Phiên bản 1.0.0',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Được xây dựng với Flutter và Hive',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}
