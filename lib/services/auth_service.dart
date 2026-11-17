import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/app_user.dart';
import 'key_value_store.dart';

/// Lỗi xác thực với thông điệp tiếng Việt hiển thị cho người dùng.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Quản lý tài khoản cục bộ bằng Hive.
///
/// Mật khẩu không được lưu dạng văn bản thuần: mỗi tài khoản có salt riêng và
/// mật khẩu được băm bằng SHA-256. Phiên đăng nhập được lưu để lần mở sau vẫn
/// giữ trạng thái đăng nhập cho tới khi người dùng đăng xuất.
class AuthService extends ChangeNotifier {
  AuthService({KeyValueStore? usersStore, KeyValueStore? sessionStore})
    : _usersStoreOverride = usersStore,
      _sessionStoreOverride = sessionStore;

  static const String usersBoxName = 'users';
  static const String sessionBoxName = 'session';
  static const String _sessionUserKey = 'currentUserId';

  final KeyValueStore? _usersStoreOverride;
  final KeyValueStore? _sessionStoreOverride;

  late KeyValueStore _usersBox;
  late KeyValueStore _sessionBox;
  AppUser? _currentUser;
  bool _initialized = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    _usersBox =
        _usersStoreOverride ??
        HiveKeyValueStore(await Hive.openBox<dynamic>(usersBoxName));
    _sessionBox =
        _sessionStoreOverride ??
        HiveKeyValueStore(await Hive.openBox<dynamic>(sessionBoxName));

    final savedId = _sessionBox.get(_sessionUserKey);
    if (savedId is String) {
      final raw = _usersBox.get(savedId);
      if (raw is Map) {
        try {
          _currentUser = AppUser.fromMap(Map<dynamic, dynamic>.from(raw));
        } catch (_) {
          await _sessionBox.delete(_sessionUserKey);
        }
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Tạo tài khoản mới và tự động đăng nhập.
  Future<AppUser> register({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    _validateUsername(normalizedUsername);
    _validatePassword(password);

    final lowerUsername = normalizedUsername.toLowerCase();
    final duplicate = _usersBox.values.any((value) {
      if (value is! Map) return false;
      final savedUsername = value['username'];
      return savedUsername is String &&
          savedUsername.toLowerCase() == lowerUsername;
    });
    if (duplicate) {
      throw const AuthException('Tên đăng nhập đã được sử dụng.');
    }

    final salt = _generateSalt();
    final user = AppUser(
      id: _generateId('u'),
      username: normalizedUsername,
      passwordHash: _hashPassword(password, salt),
      salt: salt,
      createdAt: DateTime.now(),
    );

    await _usersBox.put(user.id, user.toMap());
    await _sessionBox.put(_sessionUserKey, user.id);
    _currentUser = user;
    notifyListeners();
    return user;
  }

  /// Đăng nhập bằng tên đăng nhập và mật khẩu.
  Future<AppUser> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty) {
      throw const AuthException('Vui lòng nhập tên đăng nhập.');
    }
    if (password.isEmpty) {
      throw const AuthException('Vui lòng nhập mật khẩu.');
    }

    final lowerUsername = normalizedUsername.toLowerCase();
    AppUser? found;
    for (final value in _usersBox.values) {
      if (value is! Map) continue;
      try {
        final user = AppUser.fromMap(Map<dynamic, dynamic>.from(value));
        if (user.username.toLowerCase() == lowerUsername) {
          found = user;
          break;
        }
      } catch (_) {
        // Bỏ qua bản ghi hỏng, không làm dừng ứng dụng.
      }
    }

    if (found == null) {
      throw const AuthException('Tài khoản không tồn tại.');
    }
    if (_hashPassword(password, found.salt) != found.passwordHash) {
      throw const AuthException('Mật khẩu không đúng.');
    }

    await _sessionBox.put(_sessionUserKey, found.id);
    _currentUser = found;
    notifyListeners();
    return found;
  }

  /// Đăng xuất và xóa phiên đăng nhập đã lưu.
  Future<void> logout() async {
    await _sessionBox.delete(_sessionUserKey);
    _currentUser = null;
    notifyListeners();
  }

  void _validateUsername(String username) {
    if (username.length < 3) {
      throw const AuthException('Tên đăng nhập phải có ít nhất 3 ký tự.');
    }
    if (username.length > 24) {
      throw const AuthException('Tên đăng nhập tối đa 24 ký tự.');
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      throw const AuthException(
        'Tên đăng nhập chỉ gồm chữ không dấu, số và dấu gạch dưới.',
      );
    }
  }

  void _validatePassword(String password) {
    if (password.length < 6) {
      throw const AuthException('Mật khẩu phải có ít nhất 6 ký tự.');
    }
    if (password.length > 64) {
      throw const AuthException('Mật khẩu tối đa 64 ký tự.');
    }
  }

  static String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt::$password')).toString();
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static String _generateId(String prefix) {
    final random = Random.secure().nextInt(0xFFFFFF);
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_'
        '${random.toRadixString(16)}';
  }
}
