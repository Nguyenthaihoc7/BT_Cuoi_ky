/// Định dạng số để hiển thị: tối đa 4 chữ số sau dấu phẩy.
///
/// Chỉ làm tròn khi hiển thị, giá trị gốc vẫn được giữ nguyên trong tính toán.
/// Số rất lớn hoặc rất nhỏ được hiển thị dạng khoa học để tránh chuỗi quá dài.
String formatNumber(double value) {
  if (value.isNaN) return 'không xác định';
  if (value.isInfinite) return value.isNegative ? '-∞' : '∞';
  if (value == 0) return '0';

  final abs = value.abs();
  if (abs >= 1e15 || abs < 1e-4) {
    var text = value.toStringAsExponential(4);
    // 1.2300e+15 -> 1.23e15, 1.0000e-5 -> 1e-5
    text = text.replaceFirst(RegExp(r'\.?0+e'), 'e');
    text = text.replaceFirst('e+', 'e');
    return text;
  }

  var text = value.toStringAsFixed(4);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  if (text == '-0') return '0';
  return text;
}

/// Định dạng số nguyên lớn (không làm tròn).
String formatBigInt(BigInt value) => value.toString();

/// Định dạng thời điểm theo kiểu Việt Nam: dd/MM/yyyy HH:mm.
String formatDateTime(DateTime time) {
  final day = time.day.toString().padLeft(2, '0');
  final month = time.month.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$day/$month/${time.year} $hour:$minute';
}

/// Định dạng ngày: dd/MM/yyyy.
String formatDate(DateTime time) {
  final day = time.day.toString().padLeft(2, '0');
  final month = time.month.toString().padLeft(2, '0');
  return '$day/$month/${time.year}';
}
