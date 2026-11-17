import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_assistant/main.dart';
import 'package:math_assistant/screens/statistics_screen.dart';
import 'package:math_assistant/services/auth_service.dart';
import 'package:math_assistant/services/history_service.dart';
import 'package:math_assistant/services/key_value_store.dart';

void main() {
  late AuthService auth;
  late HistoryService history;

  setUp(() async {
    auth = AuthService(
      usersStore: MemoryKeyValueStore(),
      sessionStore: MemoryKeyValueStore(),
    );
    history = HistoryService(store: MemoryKeyValueStore());
    await auth.init();
    await history.init();
    await history.loadForUser(null);
  });

  testWidgets('luồng sử dụng đầy đủ từ đăng ký đến thống kê', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MathAssistantApp(auth: auth, history: history));
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập'), findsWidgets);

    // Đăng ký tài khoản mới.
    await tester.tap(find.text('Đăng ký ngay'));
    await tester.pumpAndSettle();
    expect(find.text('Tạo tài khoản'), findsWidgets);

    final registerFields = find.byType(TextField);
    expect(registerFields, findsNWidgets(3));
    await tester.enterText(registerFields.at(0), 'minhanh');
    await tester.enterText(registerFields.at(1), '123456');
    await tester.enterText(registerFields.at(2), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Tạo tài khoản'));
    await _settleAsyncWork(tester);
    await _dismissSnackBar(tester);

    expect(find.text('Xin chào, minhanh'), findsOneWidget);
    expect(find.text('Chọn công cụ'), findsOneWidget);

    // 1. Tính dãy số.
    await _openTool(tester, 'Dãy số');
    await tester.enterText(find.byType(TextField).first, '2 3 4');
    await _calculate(tester);
    expect(find.text('Tổng: 9'), findsOneWidget);
    expect(find.text('Tích: 24'), findsOneWidget);
    expect(find.text('Trung bình cộng: 3'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 2. Kiểm tra số nguyên tố.
    await _openTool(tester, 'Số nguyên tố');
    await tester.enterText(find.byType(TextField).first, '17');
    await _calculate(tester);
    expect(find.text('17 là số nguyên tố'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 3. UCLN và BCNN.
    await _openTool(tester, 'UCLN & BCNN');
    await tester.enterText(find.byType(TextField).at(0), '12');
    await tester.enterText(find.byType(TextField).at(1), '18');
    await _calculate(tester);
    expect(find.text('UCLN = 6'), findsOneWidget);
    expect(find.text('BCNN = 36'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 4. Phương trình bậc hai.
    await _openTool(tester, 'Bậc hai');
    await tester.enterText(find.byType(TextField).at(0), '1');
    await tester.enterText(find.byType(TextField).at(1), '-5');
    await tester.enterText(find.byType(TextField).at(2), '6');
    await _calculate(tester);
    expect(find.textContaining('x₁ = 3'), findsOneWidget);
    expect(find.textContaining('x₂ = 2'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 5. Lịch sử: tìm kiếm, lọc, xem chi tiết và xóa.
    await _goToTab(tester, 'Lịch sử');
    expect(find.text('4 bản ghi'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '17');
    await tester.pump();
    expect(find.text('1 bản ghi'), findsOneWidget);
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pump();
    expect(find.text('4 bản ghi'), findsOneWidget);

    await tester.tap(find.text('Dãy số').first);
    await tester.pump();
    expect(find.text('1 bản ghi'), findsOneWidget);
    await tester.tap(find.text('Bỏ lọc'));
    await tester.pump();
    expect(find.text('4 bản ghi'), findsOneWidget);

    await tester.tap(find.text('Đầu vào: 17'));
    await tester.pumpAndSettle();
    expect(find.text('Chi tiết lịch sử'), findsOneWidget);
    expect(find.text('17'), findsWidgets);

    await tester.tap(find.byTooltip('Xóa bản ghi'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await _settleAsyncWork(tester);
    await _dismissSnackBar(tester);
    expect(find.text('3 bản ghi'), findsOneWidget);

    // 6. Thống kê cập nhật sau khi xóa.
    await _goToTab(tester, 'Thống kê');
    expect(find.text('Tổng số lần tính'), findsOneWidget);
    expect(find.textContaining('Nhiều nhất: Dãy số'), findsOneWidget);

    // 7. Đăng xuất và đăng nhập lại, dữ liệu vẫn còn.
    await _goToTab(tester, 'Tài khoản');
    expect(find.text('minhanh'), findsOneWidget);
    final logoutTile = find.text('Đăng xuất');
    await tester.ensureVisible(logoutTile);
    await tester.pumpAndSettle();
    await tester.tap(logoutTile);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng xuất'));
    await _settleAsyncWork(tester);
    expect(find.text('Đăng nhập'), findsWidgets);

    final loginFields = find.byType(TextField);
    await tester.enterText(loginFields.at(0), 'minhanh');
    await tester.enterText(loginFields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await _settleAsyncWork(tester);
    expect(find.text('Xin chào, minhanh'), findsOneWidget);

    await _goToTab(tester, 'Lịch sử');
    expect(find.text('3 bản ghi'), findsOneWidget);

    // 8. Xóa toàn bộ lịch sử và kiểm tra trạng thái rỗng.
    await tester.tap(find.byTooltip('Xóa toàn bộ lịch sử'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa tất cả'));
    await _settleAsyncWork(tester);
    await _dismissSnackBar(tester);
    expect(find.text('Chưa có lịch sử'), findsOneWidget);

    await _goToTab(tester, 'Thống kê');
    expect(find.text('Chưa có lượt sử dụng nào'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Chưa có dữ liệu thống kê'),
      250,
      scrollable: find.descendant(
        of: find.byType(StatisticsScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu thống kê'), findsOneWidget);
  });
}

Future<void> _openTool(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _calculate(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Tính toán');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pumpAndSettle();
}

Future<void> _goToTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _settleAsyncWork(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 2)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _dismissSnackBar(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
