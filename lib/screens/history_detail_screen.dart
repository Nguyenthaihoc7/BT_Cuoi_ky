import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../logic/calculation_result.dart';
import '../logic/number_format.dart';
import '../models/history_record.dart';
import '../widgets/calculation_result_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/section_card.dart';

/// Xem chi tiết một bản ghi lịch sử.
class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.record});

  final HistoryRecord record;

  Future<void> _delete(BuildContext context) async {
    final history = AppScope.of(context).history;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa bản ghi này?',
      message:
          'Bản ghi "${record.type.shortLabel}" sẽ bị xóa khỏi lịch sử. '
          'Hành động này không thể hoàn tác.',
    );
    if (!confirmed) return;
    try {
      await history.delete(record.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã xóa bản ghi khỏi lịch sử.')),
      );
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa bản ghi. Vui lòng thử lại.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final result = CalculationResult(
      headline: record.headline,
      details: record.detailLines,
      explanation: record.explanation,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch sử'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _delete(context),
            tooltip: 'Xóa bản ghi',
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            SectionCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: record.type.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      record.type.icon,
                      color: record.type.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          record.type.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: record.type.color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                formatDateTime(record.createdAt),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.keyboard_alt_outlined,
                        size: 17,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đầu vào',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  SelectableText(
                    record.input,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CalculationResultView(result: result, savedToHistory: true),
            const SizedBox(height: 14),
            Text(
              'Thời điểm tính: ${formatDateTime(record.createdAt)}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
