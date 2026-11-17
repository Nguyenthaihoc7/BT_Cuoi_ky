/// Kết quả của một lần tính toán.
///
/// [headline] là kết luận chính, [details] là các dòng chi tiết (các bước
/// tính, từng giá trị...), [explanation] là phần giải thích ngắn.
class CalculationResult {
  const CalculationResult({
    required this.headline,
    this.details = const <String>[],
    required this.explanation,
  });

  final String headline;
  final List<String> details;
  final String explanation;

  /// Chuỗi nhiều dòng để lưu vào lịch sử: dòng đầu là kết luận chính.
  String get resultText {
    return <String>[headline, ...details].join('\n');
  }
}

/// Lỗi dữ liệu đầu vào. Thông điệp được hiển thị trực tiếp cho người dùng.
class MathInputException implements Exception {
  const MathInputException(this.message);

  final String message;

  @override
  String toString() => message;
}
