import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../logic/calculation_result.dart';
import '../models/history_record.dart';
import '../models/problem_type.dart';
import 'key_value_store.dart';

/// Quản lý lịch sử tính toán theo từng tài khoản, lưu bền vững trong Hive.
///
/// Mọi thay đổi (thêm/xóa) đều gọi [notifyListeners] để màn hình lịch sử và
/// thống kê tự cập nhật.
class HistoryService extends ChangeNotifier {
  HistoryService({KeyValueStore? store}) : _storeOverride = store;

  static const String boxName = 'history';

  final KeyValueStore? _storeOverride;

  late KeyValueStore _box;
  String? _userId;
  List<HistoryRecord> _records = <HistoryRecord>[];

  String? get userId => _userId;

  /// Lịch sử của tài khoản hiện tại, mới nhất trước.
  List<HistoryRecord> get records => List<HistoryRecord>.unmodifiable(_records);

  int get totalCount => _records.length;

  HistoryRecord? get latestRecord => _records.isEmpty ? null : _records.first;

  Future<void> init() async {
    _box =
        _storeOverride ??
        HiveKeyValueStore(await Hive.openBox<dynamic>(boxName));
  }

  /// Đọc lại lịch sử khi đăng nhập/đăng xuất.
  Future<void> loadForUser(String? userId) async {
    _userId = userId;
    if (userId == null) {
      _records = <HistoryRecord>[];
      notifyListeners();
      return;
    }

    final loaded = <HistoryRecord>[];
    for (final value in _box.values) {
      if (value is! Map) continue;
      if (value['userId'] != userId) continue;
      try {
        loaded.add(HistoryRecord.fromMap(Map<dynamic, dynamic>.from(value)));
      } catch (_) {
        // Bỏ qua bản ghi hỏng để ứng dụng vẫn hoạt động.
      }
    }
    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _records = loaded;
    notifyListeners();
  }

  /// Tự động lưu một lần tính thành công.
  Future<HistoryRecord> add({
    required ProblemType type,
    required String input,
    required CalculationResult result,
  }) async {
    final currentUserId = _userId;
    if (currentUserId == null) {
      throw StateError('Chưa đăng nhập, không thể lưu lịch sử.');
    }

    final now = DateTime.now();
    final random = Random().nextInt(0xFFFFFF);
    final record = HistoryRecord(
      id: 'h_${now.microsecondsSinceEpoch}_${random.toRadixString(16)}',
      userId: currentUserId,
      type: type,
      input: input,
      result: result.resultText,
      explanation: result.explanation,
      createdAt: now,
    );
    await _box.put(record.id, record.toMap());
    _records = <HistoryRecord>[record, ..._records];
    notifyListeners();
    return record;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _records = _records.where((record) => record.id != id).toList();
    notifyListeners();
  }

  /// Xóa toàn bộ lịch sử của tài khoản hiện tại.
  Future<void> clearAll() async {
    final currentUserId = _userId;
    if (currentUserId == null) return;
    final keysToDelete = <dynamic>[];
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value is Map && value['userId'] == currentUserId) {
        keysToDelete.add(key);
      }
    }
    if (keysToDelete.isNotEmpty) {
      await _box.deleteAll(keysToDelete);
    }
    _records = <HistoryRecord>[];
    notifyListeners();
  }

  /// Tìm kiếm theo nội dung đầu vào và lọc theo loại bài toán.
  List<HistoryRecord> query({String search = '', ProblemType? type}) {
    final keyword = search.trim().toLowerCase();
    return _records
        .where((record) {
          final matchesType = type == null || record.type == type;
          final matchesKeyword =
              keyword.isEmpty || record.input.toLowerCase().contains(keyword);
          return matchesType && matchesKeyword;
        })
        .toList(growable: false);
  }

  /// Số lần sử dụng của từng loại bài toán (luôn có đủ mọi loại).
  Map<ProblemType, int> get countsByType {
    final counts = <ProblemType, int>{
      for (final type in ProblemType.values) type: 0,
    };
    for (final record in _records) {
      counts[record.type] = (counts[record.type] ?? 0) + 1;
    }
    return counts;
  }
}
