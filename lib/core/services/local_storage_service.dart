import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola local storage menggunakan SharedPreferences
/// 
/// Handles: guest user_id, tokens, dan data lokal lainnya
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  // ── Keys untuk local storage
  static const String _guestUserIdKey = 'guest_user_id';
  static const String _usernameKey = 'username';
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
    if (_isInitialized) {
      print('⚠️ LocalStorageService sudah initialized');
      return;
    }
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('✅ LocalStorageService initialized successfully');
    } catch (e) {
      print('❌ Error initializing LocalStorageService: $e');
      rethrow;
    }
  }

  /// Cek apakah service sudah initialized
  bool get isInitialized => _isInitialized && _prefs != null;

  // ── GUEST USER ID (UUID) ──────────────────────────────────────────────

  /// Simpan guest user_id
  /// 
  /// [userId] - UUID yang diterima dari API /auth/guest
  /// Throws: Exception jika gagal menyimpan
  Future<void> saveGuestUserId(String userId) async {
    if (!isInitialized) {
      print('❌ LocalStorageService belum initialized!');
      throw Exception('LocalStorageService not initialized');
    }
    
    try {
      await _prefs!.setString(_guestUserIdKey, userId);
      print('✅ Guest user_id saved: $userId');
      
      // Verify
      final saved = _prefs!.getString(_guestUserIdKey);
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
    if (!isInitialized) {
      print('❌ LocalStorageService belum initialized!');
      return null;
    }
    
    try {
      final userId = _prefs!.getString(_guestUserIdKey);
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
    if (!isInitialized) {
      print('❌ LocalStorageService belum initialized!');
      return;
    }
    
    try {
      await _prefs!.remove(_guestUserIdKey);
      print('✅ Guest user_id cleared');
    } catch (e) {
      print('❌ Error clearing guest user_id: $e');
      rethrow;
    }
  }

  // ── USERNAME ──────────────────────────────────────────────────────

  /// Simpan username setelah login
  /// 
  /// [username] - Username dari API response (bisa dari guest login atau email login)
  /// Throws: Exception jika gagal menyimpan
  Future<void> saveUsername(String? username) async {
    if (!isInitialized) {
      print('❌ LocalStorageService belum initialized!');
      return;
    }
    
    try {
      if (username != null && username.isNotEmpty) {
        await _prefs!.setString(_usernameKey, username);
        print('✅ Username saved: $username');
      }
    } catch (e) {
      print('❌ Error saving username: $e');
      rethrow;
    }
  }

  /// Ambil username yang tersimpan
  /// 
  /// Returns: username jika ada, null jika tidak
  String? getUsername() {
    if (!isInitialized) {
      print('❌ LocalStorageService belum initialized!');
      return null;
    }
    
    try {
      final username = _prefs!.getString(_usernameKey);
      if (username != null) {
        print('✅ Username retrieved: $username');
      } else {
        print('⚠️ No username found in storage');
      }
      return username;
    } catch (e) {
      print('❌ Error getting username: $e');
      return null;
    }
  }

  /// Hapus username (saat logout)
  Future<void> clearUsername() async {
    if (!isInitialized) {
      print('❌ LocalStorageService belum initialized!');
      return;
    }
    
    try {
      await _prefs!.remove(_usernameKey);
      print('✅ Username cleared');
    } catch (e) {
      print('❌ Error clearing username: $e');
      rethrow;
    }
  }

  /// Simpan access token
  Future<void> saveAuthToken(String token) async {
    if (!isInitialized) return;
    try {
      await _prefs!.setString(_authTokenKey, token);
    } catch (e) {
      print('❌ Error saving auth token: $e');
      rethrow;
    }
  }

  /// Ambil access token
  String? getAuthToken() {
    if (!isInitialized) return null;
    return _prefs!.getString(_authTokenKey);
  }

  /// Simpan refresh token
  Future<void> saveRefreshToken(String token) async {
    if (!isInitialized) return;
    try {
      await _prefs!.setString(_refreshTokenKey, token);
    } catch (e) {
      print('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Ambil refresh token
  String? getRefreshToken() {
    if (!isInitialized) return null;
    return _prefs!.getString(_refreshTokenKey);
  }

  // ── USER DATA ─────────────────────────────────────────────────────────

  /// Simpan user data (sebagai JSON string)
  Future<void> saveUserData(String userData) async {
    if (!isInitialized) return;
    try {
      await _prefs!.setString(_userDataKey, userData);
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  /// Ambil user data
  String? getUserData() {
    if (!isInitialized) return null;
    return _prefs!.getString(_userDataKey);
  }

  // ── CLEAR ALL ─────────────────────────────────────────────────────────

  /// Hapus semua data (full logout / clear cache)
  Future<void> clearAll() async {
    if (!isInitialized) return;
    try {
      await _prefs!.clear();
      print('✅ All local storage data cleared');
    } catch (e) {
      print('❌ Error clearing all data: $e');
      rethrow;
    }
  }

  /// Hapus hanya session data (logout) - userId tetap tersimpan!
  /// 
  /// Ini untuk logout biasa. userId akan tetap ada untuk next login
  /// Hanya username & tokens yang dihapus
  Future<void> clearSessionData() async {
    if (!isInitialized) return;
    try {
      await _prefs!.remove(_usernameKey);
      await _prefs!.remove(_authTokenKey);
      await _prefs!.remove(_refreshTokenKey);
      await _prefs!.remove(_userDataKey);
      print('✅ Session data cleared (userId persisted)');
      print('   └─ Removed: username, tokens, user data');
      print('   └─ Kept: userId for next login');
    } catch (e) {
      print('❌ Error clearing session data: $e');
      rethrow;
    }
  }
}
