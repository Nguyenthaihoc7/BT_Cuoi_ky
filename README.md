# Trợ lý Toán học

Ứng dụng di động Flutter hỗ trợ tính toán, kiểm tra số và lưu lại lịch sử học tập
theo từng tài khoản. Toàn bộ dữ liệu được lưu cục bộ trên thiết bị bằng Hive,
không cần máy chủ hay tài khoản Firebase.

## Tính năng

### Tài khoản
- Đăng ký, đăng nhập, đăng xuất với tài khoản lưu cục bộ.
- Mỗi tài khoản có lịch sử tính toán riêng.
- Phiên đăng nhập được ghi nhớ sau khi khởi động lại ứng dụng.
- Mật khẩu không lưu dạng văn bản thuần: băm SHA-256 kèm salt riêng cho từng
  tài khoản.

### Công cụ tính toán
1. **Dãy số**: nhập các số cách nhau bởi một hoặc nhiều khoảng trắng, tính tổng,
   tích và trung bình cộng. Báo lỗi khi dãy trống hoặc có phần tử không phải số.
2. **Số nguyên tố**: kiểm tra số nguyên tố kèm giải thích ngắn. Số nguyên nhỏ
   hơn 2 không phải số nguyên tố.
3. **Số hoàn hảo**: kiểm tra số hoàn hảo kèm giải thích. Số không dương không
   phải số hoàn hảo.
4. **UCLN & BCNN**: tính cho hai số nguyên dương, từ chối dữ liệu không hợp lệ.
   BCNN dùng `BigInt` để tránh tràn số.
5. **Phương trình bậc nhất** `ax + b = 0`: hiển thị các bước giải, phân biệt
   trường hợp vô nghiệm và vô số nghiệm.
6. **Phương trình bậc hai** `ax² + bx + c = 0`: hiển thị các bước giải, xử lý
   biệt thức âm, nghiệm kép, hai nghiệm phân biệt. Khi `a = 0`, tự động chuyển
   về giải phương trình bậc nhất.

### Lịch sử
- Tự động lưu **chỉ những lần tính thành công**.
- Mỗi bản ghi gồm: ID, mã người dùng, loại bài toán, đầu vào, kết quả kèm giải
  thích ngắn và thời điểm tạo.
- Danh sách mới nhất hiển thị trước.
- Tìm kiếm theo nội dung đầu vào, lọc theo loại bài toán.
- Xem chi tiết từng bản ghi, xóa một bản ghi hoặc xóa toàn bộ (có hộp thoại xác
  nhận).

### Thống kê
- Tổng số lần tính và số lượt theo từng loại bài toán.
- Tỷ lệ phần trăm và loại được dùng nhiều nhất.
- Cập nhật ngay sau khi thêm hoặc xóa lịch sử.

## Công nghệ và lý do chọn Hive

| Thành phần | Lựa chọn |
| --- | --- |
| Framework | Flutter / Dart |
| Lưu trữ | Hive + hive_flutter |
| Băm mật khẩu | `crypto` (SHA-256) |
| Định dạng ngày giờ | `intl` |

Đồ án không yêu cầu máy chủ và cần chạy được ngay trên thiết bị, nên Hive phù
hợp vì:

- Lưu trữ key – value thuần Dart, không cần cấu hình backend hay thông tin xác
  thực như Firebase.
- Hoạt động tốt trên Android, iOS, Windows và Web.
- Dữ liệu vẫn còn sau khi tắt/mở lại ứng dụng.
- Dễ tách lớp lưu trữ để kiểm thử bằng bộ nhớ tạm (xem `KeyValueStore`).

> Ứng dụng là demo học tập: tài khoản và lịch sử chỉ tồn tại trên thiết bị hiện
> tại, không đồng bộ giữa các thiết bị.

## Cấu trúc dự án

```
lib/
├── main.dart                     # Khởi tạo Hive, AuthGate, gốc ứng dụng
├── app_scope.dart                # Cung cấp service cho toàn bộ widget tree
├── logic/
│   ├── math_engine.dart          # Toàn bộ logic toán học và kiểm tra dữ liệu
│   ├── calculation_result.dart   # Kết quả tính và ngoại lệ lỗi đầu vào
│   └── number_format.dart        # Định dạng số (tối đa 4 chữ số thập phân)
├── models/
│   ├── app_user.dart             # Tài khoản
│   ├── history_record.dart       # Bản ghi lịch sử
│   └── problem_type.dart         # Loại bài toán kèm nhãn/màu/icon
├── services/
│   ├── auth_service.dart         # Đăng ký, đăng nhập, phiên đăng nhập
│   ├── history_service.dart      # Lưu, truy vấn, xóa, thống kê lịch sử
│   └── key_value_store.dart      # Trừu tượng lưu trữ Hive / bộ nhớ tạm
├── screens/
│   ├── auth/                     # Đăng nhập, đăng ký
│   ├── calculator/               # 4 màn hình công cụ
│   ├── home_shell.dart           # Thanh điều hướng 4 tab
│   ├── tools_screen.dart         # Trang chủ công cụ
│   ├── history_screen.dart       # Lịch sử, tìm kiếm, lọc, xóa
│   ├── history_detail_screen.dart
│   ├── statistics_screen.dart
│   └── account_screen.dart
├── theme/app_theme.dart          # Material 3, sáng/tối
└── widgets/                      # Thành phần giao diện dùng chung
```

## Mô hình dữ liệu

`HistoryRecord` được lưu trong Hive box `history` với khóa là ID bản ghi:

| Trường | Kiểu | Ý nghĩa |
| --- | --- | --- |
| `id` | String | Khóa duy nhất của bản ghi |
| `userId` | String | Chủ sở hữu bản ghi |
| `type` | String | Mã loại bài toán |
| `input` | String | Đầu vào đã chuẩn hóa |
| `result` | String | Kết quả hiển thị |
| `explanation` | String | Giải thích ngắn / các bước giải |
| `createdAt` | ISO 8601 | Thời điểm tạo |

Các box Hive: `users` (tài khoản), `session` (phiên đăng nhập hiện tại),
`history` (lịch sử).

## Quy tắc kiểm tra dữ liệu và giới hạn

- Dãy số: tối đa 50 số, mỗi số trong khoảng ±1.000.000.
- Số nguyên tố / số hoàn hảo: số nguyên trong khoảng ±1.000.000.000.
- UCLN & BCNN: hai số nguyên dương trong khoảng ±1.000.000.000.
- Hệ số phương trình: trong khoảng ±1.000.000.
- Kết quả số được làm tròn **chỉ khi hiển thị**, tối đa 4 chữ số thập phân.
- Mọi lỗi đầu vào đều hiển thị thông điệp tiếng Việt rõ ràng; lần tính thất bại
  không được lưu vào lịch sử.

## Chạy ứng dụng

Yêu cầu: Flutter SDK 3.x trở lên.

```bash
flutter pub get
flutter run
```

Chọn thiết bị/trình giả lập khi Flutter hỏi. Trên trình duyệt:

```bash
flutter run -d chrome
```

Tạo bản phát hành web:

```bash
flutter build web --release
```

Tạo APK Android (cần Android SDK và máy ảo/thiết bị thật):

```bash
flutter build apk --release
```

> Môi trường hiện tại không cài Android SDK nên APK chưa được kiểm chứng trực
> tiếp; phần giao diện và logic đã được kiểm tra qua web và bộ kiểm thử tự động.

## Kiểm thử

```bash
flutter analyze
flutter test
```

Bộ kiểm thử hiện có **31 test**:

- `test/math_engine_test.dart`: các trường hợp tính toán, biên và lỗi đầu vào.
- `test/storage_services_test.dart`: đăng ký/đăng nhập/đăng xuất, tách lịch sử
  theo tài khoản, tìm kiếm/lọc/xóa trên Hive thật.
- `test/app_flow_test.dart`: luồng giao diện đầy đủ từ đăng ký, thực hiện 4 phép
  tính, xem/tìm/lọc/xóa lịch sử, kiểm tra thống kê, đăng xuất và đăng nhập lại,
  xóa toàn bộ lịch sử.

Kiểm thử widget dùng `MemoryKeyValueStore` (xem `lib/services/key_value_store.dart`)
để chạy nhanh và ổn định, không phụ thuộc I/O đĩa.

## Ghi chú triển khai

- Logic toán học nằm hoàn toàn trong `MathEngine`, không phụ thuộc giao diện.
- Mọi thao tác đọc/ghi lịch sử đều thông báo qua `ChangeNotifier` để các màn
  hình lịch sử và thống kê tự cập nhật.
- Lịch sử được nạp lại theo đúng tài khoản khi đăng nhập/đăng xuất nhờ listener
  đặt trong `MathAssistantApp`.
- Giao diện có trạng thái đang xử lý, rỗng, lỗi và thông báo thành công.
