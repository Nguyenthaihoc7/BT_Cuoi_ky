import 'package:flutter/material.dart';

import '../../logic/math_engine.dart';
import '../../models/problem_type.dart';
import '../../widgets/calculator_page.dart';
import 'calculator_state_mixin.dart';

/// Màn hình tính tổng, tích và trung bình cộng của một dãy số.
class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key});

  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen>
    with CalculatorStateMixin<SequenceScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _calculate() {
    return runCalculation(
      type: ProblemType.sequence,
      compute: () => MathEngine.calculateSequence(_controller.text),
      inputBuilder: () =>
          _controller.text.trim().split(RegExp(r'\s+')).join(' '),
    );
  }

  void _reset() {
    _controller.clear();
    resetOutcome();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorPage(
      type: ProblemType.sequence,
      isProcessing: isProcessing,
      errorMessage: errorMessage,
      result: result,
      savedToHistory: savedToHistory,
      onCalculate: _calculate,
      onReset: _reset,
      fields: <Widget>[
        TextField(
          controller: _controller,
          enabled: !isProcessing,
          minLines: 2,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) => clearOutcome(),
          decoration: const InputDecoration(
            labelText: 'Dãy số',
            hintText: 'Ví dụ: 2 3 4',
            alignLabelWithHint: true,
            helperText:
                'Các số cách nhau bởi một hoặc nhiều khoảng trắng. '
                'Tối đa 50 số, mỗi số trong khoảng ±1.000.000.',
            helperMaxLines: 3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ví dụ: nhập 2 3 4 → tổng 9, tích 24, trung bình cộng 3.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
