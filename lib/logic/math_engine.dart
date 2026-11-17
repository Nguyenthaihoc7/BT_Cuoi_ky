import 'dart:math' as math;

import 'calculation_result.dart';
import 'number_format.dart';

/// Toàn bộ logic tính toán, tách biệt hoàn toàn khỏi giao diện.
///
/// Mọi hàm đều kiểm tra dữ liệu đầu vào và ném [MathInputException] với thông
/// điệp tiếng Việt khi dữ liệu không hợp lệ. Nhờ vậy lỗi nhập liệu không làm
/// dừng ứng dụng.
class MathEngine {
  MathEngine._();

  /// Giới hạn để tránh tính toán quá lâu hoặc tràn số.
  static const int maxSequenceLength = 50;
  static const double maxSequenceValue = 1000000;
  static const int maxInteger = 1000000000;
  static const double maxCoefficient = 1000000;

  // ---------------------------------------------------------------------------
  // a. Tính toán với dãy số
  // ---------------------------------------------------------------------------

  /// Tính tổng, tích và trung bình cộng của dãy số trong [raw].
  ///
  /// Các số cách nhau bởi một hoặc nhiều khoảng trắng. Chấp nhận dấu chấm hoặc
  /// dấu phẩy làm dấu thập phân.
  static CalculationResult calculateSequence(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const MathInputException(
        'Dãy số đang trống. Vui lòng nhập ít nhất một số.',
      );
    }

    final tokens = trimmed.split(RegExp(r'\s+'));
    if (tokens.length > maxSequenceLength) {
      throw const MathInputException(
        'Dãy số vượt quá giới hạn $maxSequenceLength số.',
      );
    }

    final numbers = <double>[];
    for (var index = 0; index < tokens.length; index++) {
      final token = tokens[index];
      final normalized = token.replaceAll(',', '.');
      final value = double.tryParse(normalized);
      if (value == null || !value.isFinite) {
        throw MathInputException(
          'Phần tử thứ ${index + 1} ("$token") không phải là số hợp lệ.',
        );
      }
      if (value.abs() > maxSequenceValue) {
        throw MathInputException(
          'Phần tử "$token" vượt giới hạn ±${formatNumber(maxSequenceValue)}.',
        );
      }
      numbers.add(value);
    }

    var sum = 0.0;
    var product = 1.0;
    for (final number in numbers) {
      sum += number;
      product *= number;
    }
    final average = sum / numbers.length;

    if (!sum.isFinite || !product.isFinite) {
      throw const MathInputException(
        'Kết quả quá lớn để biểu diễn. Vui lòng dùng ít số hơn hoặc số nhỏ hơn.',
      );
    }

    final detailLines = <String>[
      'Tích: ${formatNumber(product)}',
      'Trung bình cộng: ${formatNumber(average)}',
    ];

    final explanationBuffer = StringBuffer('Dãy có ${numbers.length} số. ');
    if (numbers.length <= 8) {
      explanationBuffer.write(
        'Tổng = ${_sumExpression(numbers)} = ${formatNumber(sum)}; ',
      );
    }
    explanationBuffer.write(
      'trung bình cộng = tổng / ${numbers.length} = ${formatNumber(average)}.',
    );

    return CalculationResult(
      headline: 'Tổng: ${formatNumber(sum)}',
      details: detailLines,
      explanation: explanationBuffer.toString(),
    );
  }

  // ---------------------------------------------------------------------------
  // b. Số nguyên tố và số hoàn hảo
  // ---------------------------------------------------------------------------

  /// Kiểm tra [raw] có phải số nguyên tố hay không.
  static CalculationResult checkPrime(String raw) {
    final number = _parseInteger(raw, 'Số cần kiểm tra');

    if (number < 2) {
      return CalculationResult(
        headline: '$number không phải là số nguyên tố',
        explanation:
            'Số nguyên tố phải là số nguyên lớn hơn 1, chỉ có hai ước dương '
            'là 1 và chính nó. Vì $number < 2 nên không phải số nguyên tố.',
      );
    }

    if (!_isPrime(number)) {
      final divisor = _smallestDivisor(number);
      return CalculationResult(
        headline: '$number không phải là số nguyên tố',
        details: <String>['$number chia hết cho $divisor'],
        explanation:
            '$number lớn hơn 1 nhưng chia hết cho $divisor (ngoài 1 và chính '
            'nó), nên $number không phải là số nguyên tố.',
      );
    }

    final limit = math.sqrt(number).floor();
    return CalculationResult(
      headline: '$number là số nguyên tố',
      details: <String>['Đã kiểm tra các ước từ 2 đến $limit'],
      explanation: number == 2
          ? '2 lớn hơn 1 và chỉ có hai ước dương là 1 và 2, nên 2 là số '
                'nguyên tố.'
          : '$number lớn hơn 1 và không chia hết cho số nguyên nào từ 2 đến '
                '$limit (√$number ≈ ${formatNumber(math.sqrt(number))}). '
                'Do đó $number chỉ có hai ước dương là 1 và chính nó.',
    );
  }

  /// Kiểm tra [raw] có phải số hoàn hảo hay không.
  static CalculationResult checkPerfect(String raw) {
    final number = _parseInteger(raw, 'Số cần kiểm tra');

    if (number <= 0) {
      return CalculationResult(
        headline: '$number không phải là số hoàn hảo',
        explanation:
            'Số hoàn hảo phải là số nguyên dương. Vì $number không dương nên '
            'không phải số hoàn hảo.',
      );
    }

    final divisors = _properDivisors(number);
    final sum = divisors.fold<int>(0, (total, divisor) => total + divisor);
    final isPerfect = sum == number;
    final expression = divisors.length <= 15
        ? divisors.map((divisor) => '$divisor').join(' + ')
        : null;

    final details = <String>[
      'Tổng các ước dương nhỏ hơn $number: $sum',
      if (expression != null && expression.isNotEmpty) 'Các ước: $expression',
    ];

    if (isPerfect) {
      return CalculationResult(
        headline: '$number là số hoàn hảo',
        details: details,
        explanation: expression == null
            ? 'Tổng các ước dương nhỏ hơn $number bằng chính $number, nên '
                  '$number là số hoàn hảo.'
            : 'Vì $expression = $number, đúng bằng tổng các ước dương nhỏ hơn '
                  'nó, nên $number là số hoàn hảo.',
      );
    }

    return CalculationResult(
      headline: '$number không phải là số hoàn hảo',
      details: details,
      explanation:
          'Tổng các ước dương nhỏ hơn $number là $sum, khác $number, nên '
          '$number không phải là số hoàn hảo.',
    );
  }

  // ---------------------------------------------------------------------------
  // c. UCLN và BCNN
  // ---------------------------------------------------------------------------

  /// Tính UCLN và BCNN của hai số nguyên dương.
  static CalculationResult calculateGcdLcm(String rawA, String rawB) {
    final first = _parsePositiveInteger(rawA, 'Số thứ nhất');
    final second = _parsePositiveInteger(rawB, 'Số thứ hai');

    final gcd = _gcd(first, second);
    final lcm = BigInt.from(first) * BigInt.from(second) ~/ BigInt.from(gcd);

    return CalculationResult(
      headline: 'UCLN = $gcd',
      details: <String>[
        'BCNN = ${formatBigInt(lcm)}',
        'Kiểm tra: $first × $second = ${formatBigInt(BigInt.from(first) * BigInt.from(second))}',
      ],
      explanation:
          'Dùng thuật toán Euclid tìm được UCLN($first, $second) = $gcd. '
          'Khi đó BCNN = ($first × $second) / $gcd = ${formatBigInt(lcm)}.',
    );
  }

  // ---------------------------------------------------------------------------
  // d. Phương trình bậc nhất và bậc hai
  // ---------------------------------------------------------------------------

  /// Giải phương trình ax + b = 0.
  static CalculationResult solveLinear(String rawA, String rawB) {
    final a = _parseCoefficient(rawA, 'a');
    final b = _parseCoefficient(rawB, 'b');
    return _solveLinear(a, b);
  }

  /// Giải phương trình ax² + bx + c = 0 trên tập số thực.
  ///
  /// Nếu a = 0, phương trình được chuyển về dạng bậc nhất bx + c = 0.
  static CalculationResult solveQuadratic(
    String rawA,
    String rawB,
    String rawC,
  ) {
    final a = _parseCoefficient(rawA, 'a');
    final b = _parseCoefficient(rawB, 'b');
    final c = _parseCoefficient(rawC, 'c');

    if (a == 0) {
      final linearResult = _solveLinear(b, c);
      return CalculationResult(
        headline: linearResult.headline,
        details: <String>[
          'Vì a = 0 nên phương trình trở thành ${_linearEquation(b, c)}.',
          ...linearResult.details,
        ],
        explanation:
            'Hệ số a = 0 nên phương trình bậc hai suy biến thành phương trình '
            'bậc nhất. ${linearResult.explanation}',
      );
    }

    final delta = b * b - 4 * a * c;
    final deltaLine =
        'Δ = b² - 4ac = (${formatNumber(b)})² - 4 × '
        '(${formatNumber(a)}) × (${formatNumber(c)}) = '
        '${formatNumber(delta)}';

    if (delta.abs() < 1e-9) {
      final x = -b / (2 * a);
      return CalculationResult(
        headline: 'Nghiệm kép x = ${formatNumber(x)}',
        details: <String>[
          deltaLine,
          'x = -b / (2a) = ${formatNumber(-b)} / '
              '${formatNumber(2 * a)} = ${formatNumber(x)}',
        ],
        explanation:
            'Δ = 0 nên phương trình có nghiệm kép x = -b / (2a) = '
            '${formatNumber(x)}.',
      );
    }

    if (delta > 0) {
      final sqrtDelta = math.sqrt(delta);
      final x1 = (-b + sqrtDelta) / (2 * a);
      final x2 = (-b - sqrtDelta) / (2 * a);
      return CalculationResult(
        headline: 'x₁ = ${formatNumber(x1)}, x₂ = ${formatNumber(x2)}',
        details: <String>[
          deltaLine,
          '√Δ = ${formatNumber(sqrtDelta)}',
          'x₁ = (-b + √Δ) / (2a) = ${formatNumber(x1)}',
          'x₂ = (-b - √Δ) / (2a) = ${formatNumber(x2)}',
        ],
        explanation:
            'Δ = ${formatNumber(delta)} > 0 nên phương trình có hai nghiệm '
            'thực phân biệt x₁ và x₂.',
      );
    }

    return CalculationResult(
      headline: 'Phương trình vô nghiệm trên tập số thực',
      details: <String>[deltaLine],
      explanation:
          'Δ = ${formatNumber(delta)} < 0 nên phương trình không có nghiệm '
          'thực.',
    );
  }

  // ---------------------------------------------------------------------------
  // Hàm hỗ trợ nội bộ
  // ---------------------------------------------------------------------------

  static CalculationResult _solveLinear(double a, double b) {
    if (a == 0) {
      if (b == 0) {
        return const CalculationResult(
          headline: 'Phương trình có vô số nghiệm',
          details: <String>['0x + 0 = 0 đúng với mọi x'],
          explanation:
              'Vì a = 0 và b = 0 nên phương trình là hằng đẳng thức đúng với '
              'mọi số thực x.',
        );
      }
      return CalculationResult(
        headline: 'Phương trình vô nghiệm',
        details: <String>['0x + ${formatNumber(b)} = 0 là điều vô lý'],
        explanation:
            'Vì a = 0 và b = ${formatNumber(b)} ≠ 0 nên không có giá trị x nào '
            'thỏa mãn phương trình.',
      );
    }

    final x = -b / a;
    return CalculationResult(
      headline: 'x = ${formatNumber(x)}',
      details: <String>[
        'Phương trình: ${_linearEquation(a, b)}',
        'Chuyển vế: ${formatNumber(a)}x = ${formatNumber(-b)}',
        'Chia hai vế cho ${formatNumber(a)}: x = '
            '${formatNumber(-b)} / ${formatNumber(a)} = ${formatNumber(x)}',
      ],
      explanation:
          'Vì a = ${formatNumber(a)} ≠ 0, phương trình có nghiệm duy nhất '
          'x = -b / a = ${formatNumber(x)}.',
    );
  }

  static String _linearEquation(double a, double b) {
    final aText = formatNumber(a);
    final bText = b == 0
        ? ''
        : b > 0
        ? ' + ${formatNumber(b)}'
        : ' - ${formatNumber(-b)}';
    return '${aText}x$bText = 0';
  }

  static String _sumExpression(List<double> numbers) {
    if (numbers.isEmpty) return '0';
    final buffer = StringBuffer(formatNumber(numbers.first));
    for (final number in numbers.skip(1)) {
      if (number < 0) {
        buffer.write(' - ${formatNumber(-number)}');
      } else {
        buffer.write(' + ${formatNumber(number)}');
      }
    }
    return buffer.toString();
  }

  static int _parseInteger(String raw, String fieldName) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw MathInputException('$fieldName đang trống.');
    }
    final value = int.tryParse(trimmed);
    if (value == null) {
      throw MathInputException('$fieldName phải là một số nguyên hợp lệ.');
    }
    if (value.abs() > maxInteger) {
      throw MathInputException(
        '$fieldName phải nằm trong khoảng ±${formatNumber(maxInteger.toDouble())}.',
      );
    }
    return value;
  }

  static int _parsePositiveInteger(String raw, String fieldName) {
    final value = _parseInteger(raw, fieldName);
    if (value <= 0) {
      throw MathInputException('$fieldName phải là số nguyên dương.');
    }
    return value;
  }

  static double _parseCoefficient(String raw, String fieldName) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw MathInputException('Hệ số $fieldName đang trống.');
    }
    final value = double.tryParse(trimmed.replaceAll(',', '.'));
    if (value == null || !value.isFinite) {
      throw MathInputException('Hệ số $fieldName phải là một số hợp lệ.');
    }
    if (value.abs() > maxCoefficient) {
      throw MathInputException(
        'Hệ số $fieldName phải nằm trong khoảng '
        '±${formatNumber(maxCoefficient)}.',
      );
    }
    return value;
  }

  static bool _isPrime(int number) {
    if (number < 2) return false;
    if (number % 2 == 0) return number == 2;
    for (var divisor = 3; divisor * divisor <= number; divisor += 2) {
      if (number % divisor == 0) return false;
    }
    return true;
  }

  static int _smallestDivisor(int number) {
    if (number % 2 == 0) return 2;
    for (var divisor = 3; divisor * divisor <= number; divisor += 2) {
      if (number % divisor == 0) return divisor;
    }
    return number;
  }

  static List<int> _properDivisors(int number) {
    if (number <= 1) return <int>[];
    final divisors = <int>[1];
    for (var divisor = 2; divisor * divisor <= number; divisor++) {
      if (number % divisor == 0) {
        divisors.add(divisor);
        final paired = number ~/ divisor;
        if (paired != divisor) divisors.add(paired);
      }
    }
    divisors.sort();
    return divisors;
  }

  static int _gcd(int a, int b) {
    var first = a;
    var second = b;
    while (second != 0) {
      final remainder = first % second;
      first = second;
      second = remainder;
    }
    return first;
  }
}
