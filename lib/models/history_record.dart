import 'problem_type.dart';

/// Một bản ghi lịch sử tính toán.
class HistoryRecord {
  const HistoryRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.input,
    required this.result,
    required this.explanation,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final ProblemType type;

  /// Dữ liệu đầu vào đã được chuẩn hóa để hiển thị/tìm kiếm.
  final String input;

  /// Kết quả đầy đủ (dòng đầu là kết luận chính, các dòng sau là chi tiết).
  final String result;

  /// Giải thích ngắn.
  final String explanation;

  final DateTime createdAt;

  String get headline {
    final firstLine = result.split('\n').first.trim();
    return firstLine.isEmpty ? result : firstLine;
  }

  List<String> get detailLines {
    final lines = result.split('\n');
    if (lines.length <= 1) return const <String>[];
    return lines
        .skip(1)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'userId': userId,
      'type': type.storageKey,
      'input': input,
      'result': result,
      'explanation': explanation,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory HistoryRecord.fromMap(Map<dynamic, dynamic> map) {
    return HistoryRecord(
      id: map['id'] as String,
      userId: map['userId'] as String,
      type: ProblemType.fromStorage(map['type']),
      input: (map['input'] as String?) ?? '',
      result: (map['result'] as String?) ?? '',
      explanation: (map['explanation'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num).toInt(),
      ),
    );
  }
}
