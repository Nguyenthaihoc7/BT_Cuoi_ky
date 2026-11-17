import 'package:flutter/material.dart';

import '../../logic/math_engine.dart';
import '../../models/problem_type.dart';
import '../../widgets/calculator_page.dart';
import 'calculator_state_mixin.dart';

/// Giải phương trình bậc nhất ax + b = 0 hoặc bậc hai ax² + bx + c = 0.
class EquationScreen extends StatefulWidget {
  const EquationScreen({super.key, required this.initialType});

  final ProblemType initialType;

  @override
  State<EquationScreen> createState() => _EquationScreenState();
}

class _EquationScreenState extends State<EquationScreen>
    with CalculatorStateMixin<EquationScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _cController = TextEditingController();
  late ProblemType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialType == ProblemType.quadraticEquation
        ? ProblemType.quadraticEquation
        : ProblemType.linearEquation;
  }

  bool get _isQuadratic => _selected == ProblemType.quadraticEquation;

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    super.dispose();
  }

  Future<void> _calculate() {
    final isLinear = !_isQuadratic;
    final aText = _aController.text;
    final bText = _bController.text;
    final cText = _cController.text;
    return runCalculation(
      type: _selected,
      compute: () => isLinear
          ? MathEngine.solveLinear(aText, bText)
          : MathEngine.solveQuadratic(aText, bText, cText),
      inputBuilder: () => isLinear
          ? 'a = ${aText.trim()}, b = ${bText.trim()}'
          : 'a = ${aText.trim()}, b = ${bText.trim()}, '
                'c = ${cText.trim()}',
    );
  }

  void _reset() {
    _aController.clear();
    _bController.clear();
    _cController.clear();
    resetOutcome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
          'Dạng phương trình',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ProblemType>(
          segments: const <ButtonSegment<ProblemType>>[
            ButtonSegment<ProblemType>(
              value: ProblemType.linearEquation,
              label: Text('Bậc nhất'),
            ),
            ButtonSegment<ProblemType>(
              value: ProblemType.quadraticEquation,
              label: Text('Bậc hai'),
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.functions_rounded, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                _isQuadratic ? 'ax² + bx + c = 0' : 'ax + b = 0',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _CoefficientField(
                controller: _aController,
                label: 'Hệ số a',
                hint: 'Ví dụ: 1',
                enabled: !isProcessing,
                onChanged: (_) => clearOutcome(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CoefficientField(
                controller: _bController,
                label: 'Hệ số b',
                hint: 'Ví dụ: -5',
                enabled: !isProcessing,
                onChanged: (_) => clearOutcome(),
                onSubmitted: _isQuadratic ? null : (_) => _calculate(),
                isLast: !_isQuadratic,
              ),
            ),
          ],
        ),
        if (_isQuadratic) ...<Widget>[
          const SizedBox(height: 12),
          _CoefficientField(
            controller: _cController,
            label: 'Hệ số c',
            hint: 'Ví dụ: 6',
            enabled: !isProcessing,
            onChanged: (_) => clearOutcome(),
            onSubmitted: (_) => _calculate(),
            isLast: true,
          ),
        ],
        const SizedBox(height: 10),
        Text(
          _isQuadratic
              ? 'Nhập a, b, c. Nếu a = 0, ứng dụng tự chuyển sang giải '
                    'phương trình bậc nhất bx + c = 0.'
              : 'Nhập a, b để giải ax + b = 0. Hệ số trong khoảng '
                    '±1.000.000.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _CoefficientField extends StatelessWidget {
  const _CoefficientField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    this.onSubmitted,
    this.isLast = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
