import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:math_assistant/logic/calculation_result.dart';
import 'package:math_assistant/models/problem_type.dart';
import 'package:math_assistant/services/auth_service.dart';
import 'package:math_assistant/services/history_service.dart';

void main() {
  late Directory tempDirectory;
  late AuthService auth;
  late HistoryService history;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp('math_assistant_');
    Hive.init(tempDirectory.path);
    auth = AuthService();
    history = HistoryService();
    await auth.init();
    await history.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('đăng ký, đăng xuất và đăng nhập lại', () async {
    final user = await auth.register(username: 'minhanh', password: '123456');
    expect(auth.currentUser?.id, user.id);

    await auth.logout();
    expect(auth.currentUser, isNull);

    await expectLater(
      auth.login(username: 'minhanh', password: 'sai-mat-khau'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      auth.login(username: 'khong_ton_tai', password: '123456'),
      throwsA(isA<AuthException>()),
    );

    final loggedIn = await auth.login(
      username: '  MINHANH ',
      password: '123456',
    );
    expect(loggedIn.id, user.id);
    expect(loggedIn.passwordHash, isNot(contains('123456')));
  });

  test('không cho trùng tên đăng nhập và kiểm tra mật khẩu', () async {
    await expectLater(
      auth.register(username: 'MINHANH', password: 'abcdef'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      auth.register(username: 'ab', password: 'abcdef'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      auth.register(username: 'ten moi', password: 'abcdef'),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      auth.register(username: 'nguoidung', password: '123'),
      throwsA(isA<AuthException>()),
    );
  });

  test('lịch sử được lưu, tìm kiếm, lọc, xóa theo tài khoản', () async {
    final user = auth.currentUser!;
    await history.loadForUser(user.id);
    expect(history.totalCount, 0);

    final primeResult = CalculationResult(
      headline: '17 là số nguyên tố',
      explanation: 'Số 17 chỉ có hai ước dương.',
    );
    final sequenceResult = CalculationResult(
      headline: 'Tổng: 9',
      details: const <String>['Tích: 24', 'Trung bình cộng: 3'],
      explanation: 'Dãy có 3 số.',
    );

    await history.add(
      type: ProblemType.prime,
      input: '17',
      result: primeResult,
    );
    final record = await history.add(
      type: ProblemType.sequence,
      input: '2 3 4',
      result: sequenceResult,
    );

    expect(history.totalCount, 2);
    expect(history.records.first.input, '2 3 4');
    expect(history.countsByType[ProblemType.prime], 1);
    expect(history.countsByType[ProblemType.sequence], 1);
    expect(history.countsByType[ProblemType.perfect], 0);
    expect(history.query(search: '17').single.type, ProblemType.prime);
    expect(history.query(type: ProblemType.sequence).single.input, '2 3 4');
    expect(history.query(search: 'không khớp'), isEmpty);

    // Nạp lại từ Hive, mô phỏng mở lại ứng dụng.
    await history.loadForUser(null);
    await history.loadForUser(user.id);
    expect(history.totalCount, 2);
    expect(history.records.first.input, '2 3 4');

    await history.delete(record.id);
    expect(history.totalCount, 1);
    expect(history.countsByType[ProblemType.sequence], 0);

    await history.clearAll();
    expect(history.totalCount, 0);
    expect(history.countsByType.values.every((count) => count == 0), isTrue);
  });

  test('lịch sử của các tài khoản được tách riêng', () async {
    final firstUser = auth.currentUser!;
    await history.loadForUser(firstUser.id);
    await history.add(
      type: ProblemType.gcdLcm,
      input: 'a = 12, b = 18',
      result: const CalculationResult(
        headline: 'UCLN = 6',
        explanation: 'Dùng thuật toán Euclid.',
      ),
    );

    final secondUser = await auth.register(
      username: 'nguoidung2',
      password: 'abcdef',
    );
    await auth.logout();
    expect(auth.currentUser, isNull);

    final loggedIn = await auth.login(
      username: secondUser.username,
      password: 'abcdef',
    );
    await history.loadForUser(loggedIn.id);
    expect(history.totalCount, 0);

    await history.loadForUser(firstUser.id);
    expect(history.totalCount, 1);
    expect(history.records.single.type, ProblemType.gcdLcm);
  });
}
