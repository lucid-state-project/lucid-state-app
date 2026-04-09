import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola local storage menggunakan SharedPreferences
/// 
/// Handles: guest user_id, tokens, dan data lokal lainnya
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  late SharedPreferences _prefs;

  // ── Keys untuk local storage
  static const String _guestUserIdKey = 'guest_user_id';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  /// Initialize service dengan SharedPreferences instance
  /// Call ini sekali saat app startup
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── GUEST USER ID (UUID) ──────────────────────────────────────────────

  /// Simpan guest user_id
  /// 
  /// [userId] - UUID yang diterima dari API /auth/guest
  /// Throws: Exception jika gagal menyimpan
  Future<void> saveGuestUserId(String userId) async {
    try {
      await _prefs.setString(_guestUserIdKey, userId);
      print('✅ Guest user_id saved: $userId');
      
      // Verify
      final saved = _prefs.getString(_guestUserIdKey);
      print('   └─ Verification: saved value = $saved');
      print('   └─ Match? ${saved == userId}');
    } catch (e) {
      print('❌ Error saving guest user_id: $e');
      rethrow;
    }
  }

  /// Ambil guest user_id yang sudah disimpan
  /// 
  /// Returns: user_id jika ada, null jika belum pernah login as guest
  String? getGuestUserId() {
    try {
      final userId = _prefs.getString(_guestUserIdKey);
      if (userId != null) {
        print('✅ Guest user_id retrieved: $userId');
      } else {
        print('⚠️ No guest user_id found in storage');
      }
      return userId;
    } catch (e) {
      print('❌ Error getting guest user_id: $e');
      return null;
    }
  }

  /// Cek apakah user sudah pernah login sebagai guest
  bool hasGuestUserId() {
    return getGuestUserId() != null;
  }

  /// Hapus guest user_id (misalnya saat logout)
  Future<void> clearGuestUserId() async {
    try {
      await _prefs.remove(_guestUserIdKey);
      print('✅ Guest user_id cleared');
    } catch (e) {
      print('❌ Error clearing guest user_id: $e');
      rethrow;
    }
  }

  // ── AUTH TOKENS ───────────────────────────────────────────────────────

  /// Simpan access token
  Future<void> saveAuthToken(String token) async {
    try {
      await _prefs.setString(_authTokenKey, token);
    } catch (e) {
      print('❌ Error saving auth token: $e');
      rethrow;
    }
  }

  /// Ambil access token
  String? getAuthToken() {
    return _prefs.getString(_authTokenKey);
  }

  /// Simpan refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _prefs.setString(_refreshTokenKey, token);
    } catch (e) {
      print('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Ambil refresh token
  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  // ── USER DATA ─────────────────────────────────────────────────────────

  /// Simpan user data (sebagai JSON string)
  Future<void> saveUserData(String userData) async {
    try {
      await _prefs.setString(_userDataKey, userData);
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  /// Ambil user data
  String? getUserData() {
    return _prefs.getString(_userDataKey);
  }

  // ── CLEAR ALL ─────────────────────────────────────────────────────────

  /// Hapus semua data (full logout)
  Future<void> clearAll() async {
    try {
      await _prefs.clear();
      print('✅ All local storage data cleared');
    } catch (e) {
      print('❌ Error clearing all data: $e');
      rethrow;
    }
  }
}
