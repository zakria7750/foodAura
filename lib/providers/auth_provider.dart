import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isGuest = false;
  bool _loading = true;

  User? get user => _user;
  bool get isGuest => _isGuest;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null || _isGuest;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool('foodaura_guest') ?? false;
    _user = AuthService.currentUser;
    _loading = false;
    notifyListeners();

    AuthService.authStateChanges.listen((state) {
      _user = state.session?.user;
      if (_user != null) {
        _isGuest = false;
        prefs.remove('foodaura_guest');
      }
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    final err = await AuthService.signInWithEmail(email, password);
    if (err == null) notifyListeners();
    return err;
  }

  Future<String?> signUp(String email, String password, String name) async {
    return await AuthService.signUpWithEmail(email, password, name);
  }

  Future<String?> signInWithGoogle() async {
    final err = await AuthService.signInWithGoogle();
    if (err == null) notifyListeners();
    return err;
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('foodaura_guest', true);
    _isGuest = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('foodaura_guest');
    _isGuest = false;
    await AuthService.signOut();
    notifyListeners();
  }

  String get displayName {
    if (_isGuest) return 'Guest';
    return AuthService.displayName;
  }
}
