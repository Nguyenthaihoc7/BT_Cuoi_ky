import 'package:flutter/material.dart';

import '../../logic/math_engine.dart';
import '../../models/problem_type.dart';
import '../../widgets/calculator_page.dart';
import 'calculator_state_mixin.dart';

/// Tìm ước chung lớn nhất và bội chung nhỏ nhất của hai số nguyên dương.
class GcdLcmScreen extends StatefulWidget {
  const GcdLcmScreen({super.key});

  @override
  State<GcdLcmScreen> createState() => _GcdLcmScreenState();
}

class _GcdLcmScreenState extends State<GcdLcmScreen>
    with CalculatorStateMixin<GcdLcmScreen> {
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  Future<void> _calculate() {
    return runCalculation(
      type: ProblemType.gcdLcm,
      compute: () => MathEngine.calculateGcdLcm(
        _firstController.text,
        _secondController.text,
      ),
      inputBuilder: () =>
          'a = ${_firstController.text.trim()}, '
          'b = ${_secondController.text.trim()}',
    );
  }

  void _reset() {
    _firstController.clear();
    _secondController.clear();
    resetOutcome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CalculatorPage(
      type: ProblemType.gcdLcm,
      isProcessing: isProcessing,
      errorMessage: errorMessage,
      result: result,
      savedToHistory: savedToHistory,
      onCalculate: _calculate,
      onReset: _reset,
      fields: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _firstController,
                enabled: !isProcessing,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                onChanged: (_) => clearOutcome(),
                decoration: const InputDecoration(
                  labelText: 'Số thứ nhất',
                  hintText: 'Ví dụ: 12',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _secondController,
                enabled: !isProcessing,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                onSubmitted: (_) => _calculate(),
                onChanged: (_) => clearOutcome(),
                decoration: const InputDecoration(
                  labelText: 'Số thứ hai',
                  hintText: 'Ví dụ: 18',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Hai số phải là số nguyên dương, tối đa 1.000.000.000. '
          'Ví dụ: 12 và 18 → UCLN = 6, BCNN = 36.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
