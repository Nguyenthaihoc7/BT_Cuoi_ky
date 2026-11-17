import 'package:hive/hive.dart';

/// Giao diện lưu trữ khóa – giá trị tối giản.
///
/// Nhờ lớp trừu tượng này, các service nghiệp vụ có thể chạy trên Hive khi ứng
/// dụng hoạt động bình thường và trên bộ nhớ tạm khi kiểm thử widget, giúp test
/// nhanh, ổn định và không phụ thuộc vào I/O đĩa.
abstract interface class KeyValueStore {
  Iterable<dynamic> get keys;

  Iterable<dynamic> get values;

  dynamic get(dynamic key);

  Future<void> put(dynamic key, dynamic value);

  Future<void> delete(dynamic key);

  Future<void> deleteAll(Iterable<dynamic> keys);
}

/// Cài đặt lưu trữ trên một Hive box.
class HiveKeyValueStore implements KeyValueStore {
  HiveKeyValueStore(this._box);

  final Box<dynamic> _box;

  @override
  Iterable<dynamic> get keys => _box.keys;

  @override
  Iterable<dynamic> get values => _box.values;

  @override
  dynamic get(dynamic key) => _box.get(key);

  @override
  Future<void> put(dynamic key, dynamic value) => _box.put(key, value);

  @override
  Future<void> delete(dynamic key) => _box.delete(key);

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) => _box.deleteAll(keys);
}

/// Cài đặt lưu trữ trong bộ nhớ, dùng cho kiểm thử.
class MemoryKeyValueStore implements KeyValueStore {
  final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};

  @override
  Iterable<dynamic> get keys => _data.keys;

  @override
  Iterable<dynamic> get values => _data.values;

  @override
  dynamic get(dynamic key) => _data[key];

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(dynamic key) async {
    _data.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys.toList(growable: false)) {
      _data.remove(key);
    }
  }
}
