import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../logic/number_format.dart';
import '../models/history_record.dart';
import '../models/problem_type.dart';
import '../services/history_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import 'history_detail_screen.dart';

/// Màn hình lịch sử: tìm kiếm, lọc, xem chi tiết và xóa.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.onOpenTools});

  final VoidCallback onOpenTools;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  ProblemType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _clearAll(HistoryService history) async {
    final count = history.totalCount;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa toàn bộ lịch sử?',
      message:
          'Tất cả $count bản ghi của tài khoản hiện tại sẽ bị xóa vĩnh viễn. '
          'Hành động này không thể hoàn tác.',
      confirmLabel: 'Xóa tất cả',
    );
    if (!confirmed || !mounted) return;

    try {
      await history.clearAll();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa toàn bộ lịch sử.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa lịch sử. Vui lòng thử lại.'),
        ),
      );
    }
  }

  Future<void> _deleteOne(HistoryService history, HistoryRecord record) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Xóa bản ghi?',
      message:
          'Bản ghi "${record.type.shortLabel}" với đầu vào '
          '"${record.input}" sẽ bị xóa khỏi lịch sử.',
    );
    if (!confirmed || !mounted) return;

    try {
      await history.delete(record.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bản ghi khỏi lịch sử.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa bản ghi. Vui lòng thử lại.'),
        ),
      );
    }
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() => _selectedType = null);
  }

  void _openDetail(HistoryRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryDetailScreen(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = AppScope.of(context).history;
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final filtered = history.query(
          search: _searchController.text,
          type: _selectedType,
        );
        final hasHistory = history.totalCount > 0;
        final hasFilters =
            _searchController.text.trim().isNotEmpty || _selectedType != null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lịch sử'),
            actions: <Widget>[
              IconButton(
                onPressed: hasHistory ? () => _clearAll(history) : null,
                tooltip: 'Xóa toàn bộ lịch sử',
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            child: !hasHistory
                ? EmptyState(
                    icon: Icons.history_rounded,
                    title: 'Chưa có lịch sử',
                    message:
                        'Mỗi lần tính toán thành công sẽ được lưu tự động tại '
                        'đây. Hãy bắt đầu với một công cụ bất kỳ.',
                    action: OutlinedButton.icon(
                      onPressed: widget.onOpenTools,
                      icon: const Icon(Icons.calculate_rounded, size: 18),
                      label: const Text('Bắt đầu tính toán'),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Tìm theo nội dung đầu vào...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    tooltip: 'Xóa tìm kiếm',
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: <Widget>[
                            _FilterChip(
                              label: 'Tất cả',
                              selected: _selectedType == null,
                              color: theme.colorScheme.primary,
                              onSelected: () =>
                                  setState(() => _selectedType = null),
                            ),
                            ...ProblemType.values.map(
                              (type) => _FilterChip(
                                label: type.shortLabel,
                                selected: _selectedType == type,
                                color: type.color,
                                onSelected: () =>
                                    setState(() => _selectedType = type),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 6, 10, 2),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '${filtered.length} bản ghi',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            if (hasFilters)
                              TextButton(
                                onPressed: _resetFilters,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                                child: const Text('Bỏ lọc'),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? EmptyState(
                                icon: Icons.search_off_rounded,
                                title: 'Không tìm thấy bản ghi',
                                message:
                                    'Thử từ khóa khác hoặc bỏ bộ lọc để xem '
                                    'toàn bộ lịch sử.',
                                action: TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(
                                    Icons.filter_alt_off_rounded,
                                  ),
                                  label: const Text('Xóa bộ lọc'),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  24,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final record = filtered[index];
                                  return _HistoryTile(
                                    record: record,
                                    onTap: () => _openDetail(record),
                                    onDelete: () => _deleteOne(history, record),
                                  );
                                },
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: color.withValues(alpha: 0.15),
        side: BorderSide(
          color: selected
              ? color.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? color : null,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryRecord record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF181A2F) : Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: record.type.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  record.type.icon,
                  color: record.type.color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            record.type.shortLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: record.type.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatDateTime(record.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Đầu vào: ${record.input}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 14,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            record.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Xóa bản ghi',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
