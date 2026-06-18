import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static SupabaseClient get _client => SupabaseService.client;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // ضع هنا clientId من Google Cloud Console إذا كنت على iOS/web:
    // clientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
  );

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ── Email ────────────────────────────────────────────────────────────────

  static Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  static Future<String?> signUpWithEmail(
      String email, String password, String fullName) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // ── Google ───────────────────────────────────────────────────────────────

  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'تم إلغاء تسجيل الدخول';

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) return 'فشل الحصول على idToken من Google';

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _client.auth.signOut();
  }

  static String get displayName {
    final user = currentUser;
    if (user == null) return 'Guest';
    return user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['name'] as String? ??
        user.email?.split('@').first ??
        'User';
  }
}
