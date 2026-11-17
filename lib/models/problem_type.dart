import 'package:flutter/material.dart';

/// Các loại bài toán được hỗ trợ trong ứng dụng.
///
/// Mỗi loại có nhãn hiển thị, biểu tượng, màu sắc và mô tả ngắn.
/// Tên enum được dùng làm khóa lưu trong Hive (xem [storageKey]).
enum ProblemType {
  sequence(
    label: 'Tính dãy số',
    shortLabel: 'Dãy số',
    icon: Icons.functions_rounded,
    color: Color(0xFF4F46E5),
    description: 'Tính tổng, tích và trung bình cộng của một dãy số.',
  ),
  prime(
    label: 'Kiểm tra số nguyên tố',
    shortLabel: 'Số nguyên tố',
    icon: Icons.verified_rounded,
    color: Color(0xFF0F766E),
    description: 'Kiểm tra một số nguyên có phải số nguyên tố hay không.',
  ),
  perfect(
    label: 'Kiểm tra số hoàn hảo',
    shortLabel: 'Số hoàn hảo',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFB45309),
    description: 'Kiểm tra số nguyên dương có bằng tổng các ước nhỏ hơn nó.',
  ),
  gcdLcm(
    label: 'UCLN & BCNN',
    shortLabel: 'UCLN & BCNN',
    icon: Icons.hub_rounded,
    color: Color(0xFF2563EB),
    description: 'Tìm ước chung lớn nhất và bội chung nhỏ nhất của hai số.',
  ),
  linearEquation(
    label: 'Phương trình bậc nhất',
    shortLabel: 'Bậc nhất',
    icon: Icons.trending_flat_rounded,
    color: Color(0xFF7C3AED),
    description: 'Giải phương trình ax + b = 0 kèm các bước tính.',
  ),
  quadraticEquation(
    label: 'Phương trình bậc hai',
    shortLabel: 'Bậc hai',
    icon: Icons.show_chart_rounded,
    color: Color(0xFFDB2777),
    description: 'Giải phương trình ax² + bx + c = 0 trên tập số thực.',
  );

  const ProblemType({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
    required this.description,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;
  final String description;

  /// Khóa lưu bền vững trong Hive.
  String get storageKey => name;

  /// Chuyển khóa lưu trữ thành [ProblemType], mặc định là [sequence]
  /// nếu dữ liệu cũ hoặc không hợp lệ.
  static ProblemType fromStorage(Object? value) {
    return ProblemType.values.firstWhere(
      (type) => type.storageKey == value,
      orElse: () => ProblemType.sequence,
    );
  }
}
