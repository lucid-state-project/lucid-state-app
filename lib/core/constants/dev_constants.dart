/// ─────────────────────────────────────────────────────────────────────
/// 📌 DEVELOPMENT CONSTANTS
/// 
/// Temporary configuration untuk development & testing analytics
/// 
/// FIXED GUEST ACCOUNT FOR ANALYTICS DEVELOPMENT:
/// - Saat app startup, pre-set local storage dengan fixed guest UUID & username
/// - Auto-login akan pick up UUID dari storage dan guest login
/// - User clicks "Continue as Guest" juga reuse same UUID → same account
/// - Prevent duplicate user creation, consistent data for analytics
/// 
/// IMPORTANT: Disable auto-login sebelum production release
/// ─────────────────────────────────────────────────────────────────────

class DevConstants {
  /// 🔐 Fixed Guest UUID untuk development
  /// 
  /// This UUID di-persistent ke local storage saat app startup
  /// Semua guest login akan reuse UUID ini (tidak create akun baru)
  /// 
  /// - First app start: POST /auth/guest?userId=989c6b32-f32a-4ffb-8702-06f007e0aeeb
  /// - Subsequent starts: POST /auth/guest?userId=989c6b32-f32a-4ffb-8702-06f007e0aeeb (same account)
  /// - User clicks "Continue as Guest": POST /auth/guest?userId=989c6b32-f32a-4ffb-8702-06f007e0aeeb (same)
  static const String fixedGuestUuid = '989c6b32-f32a-4ffb-8702-06f007e0aeeb';
  
  /// 👤 Fixed Guest Username untuk development
  /// 
  /// Pre-set ke local storage saat app startup
  /// Display di UI sebagai current user
  static const String fixedGuestUsername = 'guest_275';
  
  /// 🚀 Flag untuk enable/disable auto-login pada app startup
  /// 
  /// When enabled (true):
  ///   - App automatically perform guest login saat startup
  ///   - Using fixed UUID dari constant di atas
  ///   - Navigate langsung ke Dashboard (bypass login page)
  /// 
  /// Set ke FALSE untuk production atau jika mau manual login
  static const bool enableAutoLogin = true;
  
  /// ⏱️ Delay dalam milliseconds sebelum auto-login di-trigger
  /// 
  /// Berguna untuk:
  ///   - Memastikan UI/widgets sudah fully rendered sebelum navigation
  ///   - Prevent race condition atau animation jitter
  ///   - Smooth user experience saat app startup
  static const int autoLoginDelayMs = 500;
}
