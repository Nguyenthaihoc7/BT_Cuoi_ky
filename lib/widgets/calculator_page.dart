import 'package:flutter/material.dart';

import '../logic/calculation_result.dart';
import '../models/problem_type.dart';
import 'calculation_result_view.dart';
import 'error_banner.dart';
import 'page_intro.dart';
import 'section_card.dart';

/// Khung màn hình tính toán dùng chung cho cả bốn công cụ.
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({
    super.key,
    required this.type,
    required this.fields,
    required this.isProcessing,
    required this.onCalculate,
    required this.onReset,
    this.errorMessage,
    this.result,
    this.savedToHistory = false,
  });

  final ProblemType type;
  final List<Widget> fields;
  final bool isProcessing;
  final VoidCallback onCalculate;
  final VoidCallback onReset;
  final String? errorMessage;
  final CalculationResult? result;
  final bool savedToHistory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type.shortLabel)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: <Widget>[
            PageIntro(
              icon: type.icon,
              title: type.label,
              description: type.description,
              color: type.color,
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ...fields,
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isProcessing ? null : onCalculate,
                          icon: isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.calculate_rounded, size: 20),
                          label: Text(
                            isProcessing ? 'Đang tính...' : 'Tính toán',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: isProcessing ? null : onReset,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Làm mới'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isProcessing) ...<Widget>[
              const SizedBox(height: 16),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 16),
              ErrorBanner(message: errorMessage!),
            ],
            if (result != null) ...<Widget>[
              const SizedBox(height: 16),
              CalculationResultView(
                result: result!,
                savedToHistory: savedToHistory,
              ),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Kết quả được lưu tự động vào lịch sử của bạn',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
