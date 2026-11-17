import 'package:flutter/material.dart';

import '../../logic/math_engine.dart';
import '../../models/problem_type.dart';
import '../../widgets/calculator_page.dart';
import 'calculator_state_mixin.dart';

/// Kiểm tra số nguyên tố hoặc số hoàn hảo.
class NumberCheckScreen extends StatefulWidget {
  const NumberCheckScreen({super.key, required this.initialType});

  final ProblemType initialType;

  @override
  State<NumberCheckScreen> createState() => _NumberCheckScreenState();
}

class _NumberCheckScreenState extends State<NumberCheckScreen>
    with CalculatorStateMixin<NumberCheckScreen> {
  final TextEditingController _controller = TextEditingController();
  late ProblemType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialType == ProblemType.perfect
        ? ProblemType.perfect
        : ProblemType.prime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _calculate() {
    final isPrime = _selected == ProblemType.prime;
    return runCalculation(
      type: _selected,
      compute: () => isPrime
          ? MathEngine.checkPrime(_controller.text)
          : MathEngine.checkPerfect(_controller.text),
      inputBuilder: () => _controller.text.trim(),
    );
  }

  void _reset() {
    _controller.clear();
    resetOutcome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CalculatorPage(
      type: _selected,
      isProcessing: isProcessing,
      errorMessage: errorMessage,
      result: result,
      savedToHistory: savedToHistory,
      onCalculate: _calculate,
      onReset: _reset,
      fields: <Widget>[
        Text(
          'Loại kiểm tra',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ProblemType>(
          segments: const <ButtonSegment<ProblemType>>[
            ButtonSegment<ProblemType>(
              value: ProblemType.prime,
              label: Text('Nguyên tố'),
            ),
            ButtonSegment<ProblemType>(
              value: ProblemType.perfect,
              label: Text('Hoàn hảo'),
            ),
          ],
          selected: <ProblemType>{_selected},
          onSelectionChanged: isProcessing
              ? null
              : (selection) {
                  setState(() => _selected = selection.first);
                  clearOutcome();
                },
          expandedInsets: EdgeInsets.zero,
          showSelectedIcon: false,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _controller,
          enabled: !isProcessing,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _calculate(),
          onChanged: (_) => clearOutcome(),
          decoration: const InputDecoration(
            labelText: 'Số nguyên cần kiểm tra',
            hintText: 'Ví dụ: 17',
            prefixIcon: Icon(Icons.tag_rounded),
            helperText: 'Số nguyên trong khoảng ±1.000.000.000.',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _selected == ProblemType.prime
              ? 'Số nguyên tố là số lớn hơn 1, chỉ có hai ước dương là 1 và '
                    'chính nó.'
              : 'Số hoàn hảo là số nguyên dương bằng tổng các ước dương nhỏ '
                    'hơn chính nó. Ví dụ: 1 + 2 + 3 = 6.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
