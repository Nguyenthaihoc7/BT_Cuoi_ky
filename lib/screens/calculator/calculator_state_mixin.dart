import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../logic/calculation_result.dart';
import '../../models/problem_type.dart';

/// Xử lý trạng thái chung cho các màn hình tính toán:
/// đang xử lý, lỗi đầu vào, kết quả và lưu lịch sử tự động.
mixin CalculatorStateMixin<T extends StatefulWidget> on State<T> {
  bool isProcessing = false;
  String? errorMessage;
  CalculationResult? result;
  bool savedToHistory = false;

  /// Chạy tính toán trên một tác vụ nhỏ để giao diện kịp hiển thị trạng thái
  /// "Đang tính...", sau đó tự lưu kết quả vào lịch sử nếu thành công.
  Future<void> runCalculation({
    required ProblemType type,
    required CalculationResult Function() compute,
    required String Function() inputBuilder,
  }) async {
    FocusScope.of(context).unfocus();
    final history = AppScope.of(context).history;

    setState(() {
      isProcessing = true;
      errorMessage = null;
      savedToHistory = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    late final CalculationResult calculated;
    try {
      calculated = compute();
    } on MathInputException catch (error) {
      _showError(error.message);
      return;
    } catch (_) {
      _showError('Đã xảy ra lỗi khi tính toán. Vui lòng kiểm tra dữ liệu.');
      return;
    }

    var saved = false;
    try {
      await history.add(type: type, input: inputBuilder(), result: calculated);
      saved = true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã tính xong nhưng chưa lưu được lịch sử. Vui lòng thử lại.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      result = calculated;
      isProcessing = false;
      savedToHistory = saved;
    });
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      isProcessing = false;
      errorMessage = message;
      result = null;
      savedToHistory = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Xóa kết quả cũ khi người dùng sửa dữ liệu.
  void clearOutcome() {
    if (!mounted) return;
    if (errorMessage == null && result == null && !savedToHistory) return;
    setState(() {
      errorMessage = null;
      result = null;
      savedToHistory = false;
    });
  }

  /// Đưa màn hình về trạng thái ban đầu.
  void resetOutcome() {
    if (!mounted) return;
    setState(() {
      isProcessing = false;
      errorMessage = null;
      result = null;
      savedToHistory = false;
    });
  }
}
