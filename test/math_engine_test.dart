import 'package:flutter_test/flutter_test.dart';
import 'package:math_assistant/logic/calculation_result.dart';
import 'package:math_assistant/logic/math_engine.dart';
import 'package:math_assistant/logic/number_format.dart';

void main() {
  group('Tính toán với dãy số', () {
    test('tính đúng tổng, tích và trung bình cộng', () {
      final result = MathEngine.calculateSequence('2 3 4');

      expect(result.headline, 'Tổng: 9');
      expect(result.details, contains('Tích: 24'));
      expect(result.details, contains('Trung bình cộng: 3'));
      expect(result.explanation, contains('Dãy có 3 số'));
    });

    test('chấp nhận nhiều khoảng trắng, xuống dòng và số thập phân', () {
      final result = MathEngine.calculateSequence(' 1,5   2.5\n 3 ');

      expect(result.headline, 'Tổng: 7');
      expect(result.details, contains('Tích: 11.25'));
      expect(
        result.details,
        contains('Trung bình cộng: ${formatNumber(7 / 3)}'),
      );
    });

    test('báo lỗi khi dãy rỗng', () {
      expect(
        () => MathEngine.calculateSequence('   '),
        throwsA(isA<MathInputException>()),
      );
    });

    test('báo lỗi khi có phần tử không phải số', () {
      expect(
        () => MathEngine.calculateSequence('2 x 4'),
        throwsA(
          isA<MathInputException>().having(
            (error) => error.message,
            'message',
            contains('Phần tử thứ 2'),
          ),
        ),
      );
    });

    test('báo lỗi khi vượt quá số lượng hoặc giới hạn giá trị', () {
      final tooMany = List<String>.generate(51, (index) => '1').join(' ');
      expect(
        () => MathEngine.calculateSequence(tooMany),
        throwsA(isA<MathInputException>()),
      );
      expect(
        () => MathEngine.calculateSequence('1000001 2'),
        throwsA(isA<MathInputException>()),
      );
    });
  });

  group('Số nguyên tố', () {
    test('nhận diện số nguyên tố', () {
      expect(MathEngine.checkPrime('17').headline, '17 là số nguyên tố');
      expect(MathEngine.checkPrime('2').headline, '2 là số nguyên tố');
      expect(
        MathEngine.checkPrime('999983').headline,
        '999983 là số nguyên tố',
      );
    });

    test('nhận diện hợp số và số nhỏ hơn 2', () {
      final composite = MathEngine.checkPrime('6');
      expect(composite.headline, '6 không phải là số nguyên tố');
      expect(composite.explanation, contains('chia hết cho 2'));

      expect(
        MathEngine.checkPrime('1').headline,
        '1 không phải là số nguyên tố',
      );
      expect(
        MathEngine.checkPrime('-7').headline,
        '-7 không phải là số nguyên tố',
      );
    });

    test('báo lỗi khi không phải số nguyên', () {
      expect(
        () => MathEngine.checkPrime('12.5'),
        throwsA(isA<MathInputException>()),
      );
    });
  });

  group('Số hoàn hảo', () {
    test('nhận diện các số hoàn hảo', () {
      for (final number in <int>[6, 28, 496, 8128]) {
        expect(
          MathEngine.checkPerfect('$number').headline,
          '$number là số hoàn hảo',
        );
      }
    });

    test('giải thích 6 là số hoàn hảo', () {
      final result = MathEngine.checkPerfect('6');
      expect(result.explanation, contains('1 + 2 + 3 = 6'));
    });

    test('nhận diện số không hoàn hảo và số không dương', () {
      expect(
        MathEngine.checkPerfect('12').headline,
        '12 không phải là số hoàn hảo',
      );
      expect(
        MathEngine.checkPerfect('0').headline,
        '0 không phải là số hoàn hảo',
      );
      expect(
        MathEngine.checkPerfect('-6').headline,
        '-6 không phải là số hoàn hảo',
      );
    });
  });

  group('UCLN và BCNN', () {
    test('tính đúng ví dụ 12 và 18', () {
      final result = MathEngine.calculateGcdLcm('12', '18');
      expect(result.headline, 'UCLN = 6');
      expect(result.details, contains('BCNN = 36'));
    });

    test('tính đúng hai số nguyên tố cùng nhau', () {
      final result = MathEngine.calculateGcdLcm('7', '13');
      expect(result.headline, 'UCLN = 1');
      expect(result.details, contains('BCNN = 91'));
    });

    test('tính chính xác BCNN lớn bằng BigInt', () {
      final result = MathEngine.calculateGcdLcm('1000000000', '999999999');
      expect(result.headline, 'UCLN = 1');
      expect(result.details, contains('BCNN = 999999999000000000'));
    });

    test('báo lỗi khi không phải số nguyên dương', () {
      expect(
        () => MathEngine.calculateGcdLcm('0', '18'),
        throwsA(isA<MathInputException>()),
      );
      expect(
        () => MathEngine.calculateGcdLcm('12.5', '18'),
        throwsA(isA<MathInputException>()),
      );
      expect(
        () => MathEngine.calculateGcdLcm('-12', '18'),
        throwsA(isA<MathInputException>()),
      );
    });
  });

  group('Phương trình bậc nhất', () {
    test('có một nghiệm', () {
      final result = MathEngine.solveLinear('2', '-4');
      expect(result.headline, 'x = 2');
      expect(result.details.first, 'Phương trình: 2x - 4 = 0');
    });

    test('vô số nghiệm', () {
      final result = MathEngine.solveLinear('0', '0');
      expect(result.headline, 'Phương trình có vô số nghiệm');
    });

    test('vô nghiệm', () {
      final result = MathEngine.solveLinear('0', '5');
      expect(result.headline, 'Phương trình vô nghiệm');
    });

    test('báo lỗi hệ số không hợp lệ', () {
      expect(
        () => MathEngine.solveLinear('abc', '1'),
        throwsA(isA<MathInputException>()),
      );
      expect(
        () => MathEngine.solveLinear('1000001', '1'),
        throwsA(isA<MathInputException>()),
      );
    });
  });

  group('Phương trình bậc hai', () {
    test('hai nghiệm phân biệt', () {
      final result = MathEngine.solveQuadratic('1', '-5', '6');
      expect(result.headline, contains('x₁ = 3'));
      expect(result.headline, contains('x₂ = 2'));
      expect(result.explanation, contains('hai nghiệm'));
    });

    test('nghiệm kép', () {
      final result = MathEngine.solveQuadratic('1', '-2', '1');
      expect(result.headline, 'Nghiệm kép x = 1');
    });

    test('vô nghiệm trên tập số thực', () {
      final result = MathEngine.solveQuadratic('1', '0', '1');
      expect(result.headline, 'Phương trình vô nghiệm trên tập số thực');
    });

    test('a = 0 chuyển sang phương trình bậc nhất', () {
      final result = MathEngine.solveQuadratic('0', '2', '-4');
      expect(result.headline, 'x = 2');
      expect(result.details.first, contains('a = 0'));
      expect(result.explanation, contains('bậc nhất'));
    });

    test('báo lỗi khi thiếu hệ số', () {
      expect(
        () => MathEngine.solveQuadratic('1', '', '6'),
        throwsA(isA<MathInputException>()),
      );
    });
  });

  group('Định dạng số', () {
    test('tối đa 4 chữ số sau dấu phẩy và bỏ số 0 thừa', () {
      expect(formatNumber(1 / 3), '0.3333');
      expect(formatNumber(1234.56789), '1234.5679');
      expect(formatNumber(2), '2');
      expect(formatNumber(-0.0), '0');
      expect(formatNumber(0.00001), '1e-5');
      expect(formatNumber(1e20), '1e20');
    });

    test('định dạng số nguyên lớn và thời gian', () {
      expect(
        formatBigInt(BigInt.parse('999999866000004473')),
        '999999866000004473',
      );
      final time = DateTime(2026, 11, 16, 9, 5);
      expect(formatDateTime(time), '16/11/2026 09:05');
      expect(formatDate(time), '16/11/2026');
    });
  });
}
