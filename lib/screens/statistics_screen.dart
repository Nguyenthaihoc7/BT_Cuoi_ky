import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../logic/number_format.dart';
import '../models/problem_type.dart';
import '../widgets/section_card.dart';

/// Màn hình thống kê số lần sử dụng các công cụ của tài khoản hiện tại.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final history = AppScope.of(context).history;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final counts = history.countsByType;
        final total = history.totalCount;
        final usedTypes = counts.values.where((count) => count > 0).length;
        final latest = history.latestRecord;

        ProblemType? topType;
        var topCount = 0;
        for (final type in ProblemType.values) {
          final count = counts[type] ?? 0;
          if (count > topCount) {
            topType = type;
            topCount = count;
          }
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Thống kê')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: <Widget>[
                _TotalCard(total: total, topType: topType, topCount: topCount),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.widgets_rounded,
                        color: const Color(0xFF7C3AED),
                        label: 'Công cụ đã dùng',
                        value: '$usedTypes/6',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFF0F766E),
                        label: 'Lần gần nhất',
                        value: latest == null
                            ? 'Chưa có'
                            : formatDateTime(latest.createdAt),
                        smallValue: latest != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Số lần sử dụng từng loại',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Cập nhật ngay khi bạn thêm hoặc xóa lịch sử.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SectionCard(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Column(
                    children: <Widget>[
                      for (
                        var index = 0;
                        index < ProblemType.values.length;
                        index++
                      )
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == ProblemType.values.length - 1
                                ? 10
                                : 16,
                          ),
                          child: _TypeStatRow(
                            type: ProblemType.values[index],
                            count: counts[ProblemType.values[index]] ?? 0,
                            total: total,
                          ),
                        ),
                    ],
                  ),
                ),
                if (total == 0) ...<Widget>[
                  const SizedBox(height: 14),
                  SectionCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.insights_rounded,
                          size: 34,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Chưa có dữ liệu thống kê',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Thực hiện một phép tính thành công để bắt đầu theo '
                          'dõi mức độ sử dụng các công cụ.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: onStart,
                          icon: const Icon(Icons.calculate_rounded, size: 18),
                          label: const Text('Tính toán ngay'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Số liệu được tính từ các bản ghi lịch sử còn lưu của '
                        'tài khoản hiện tại.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.total,
    required this.topType,
    required this.topCount,
  });

  final int total;
  final ProblemType? topType;
  final int topCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0F766E),
            Color(0xFF2563EB),
            Color(0xFF4F46E5),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -22,
              top: -18,
              child: Icon(
                Icons.bar_chart_rounded,
                size: 150,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tổng số lần tính',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '$total',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'lượt',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      topType == null
                          ? 'Chưa có lượt sử dụng nào'
                          : 'Nhiều nhất: ${topType!.shortLabel} • $topCount lần',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.smallValue = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: smallValue
                ? theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  )
                : theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TypeStatRow extends StatelessWidget {
  const _TypeStatRow({
    required this.type,
    required this.count,
    required this.total,
  });

  final ProblemType type;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : count / total;
    final percent = (ratio * 100).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: type.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(type.icon, color: type.color, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      type.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count lần',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: type.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  color: type.color,
                  backgroundColor: type.color.withValues(alpha: 0.12),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$percent% tổng số lượt',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
