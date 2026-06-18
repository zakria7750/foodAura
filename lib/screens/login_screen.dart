import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    final err = await context
        .read<AuthProvider>()
        .signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      _goHome();
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _googleLoading = true; _error = null; });
    final err = await context.read<AuthProvider>().signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      _goHome();
    }
  }

  Future<void> _guest() async {
    await context.read<AuthProvider>().continueAsGuest();
    if (!mounted) return;
    _goHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.restaurant_menu,
                    color: AppTheme.primary, size: 36),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),
              const SizedBox(height: 16),
              const Text('FoodAura',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 4),
              const Text('Welcome back — sign in to continue',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 40),

              // Google button
              _GoogleButton(
                loading: _googleLoading,
                onTap: _signInWithGoogle,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),

              // Divider
              Row(children: [
                const Expanded(child: Divider(color: AppTheme.border)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or sign in with email',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ),
                const Expanded(child: Divider(color: AppTheme.border)),
              ]).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.mail_outline,
                      color: AppTheme.textSecondary, size: 20),
                ),
              ).animate().fadeIn(delay: 280.ms),
              const SizedBox(height: 12),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppTheme.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ),
              ).animate().fadeIn(delay: 310.ms),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 20),

              // Sign In button
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In'),
              ).animate().fadeIn(delay: 340.ms),
              const SizedBox(height: 12),

              // Guest
              TextButton(
                onPressed: _guest,
                child: const Text('Continue as Guest',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ).animate().fadeIn(delay: 370.ms),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SignupScreen())),
                    child: const Text('Sign up',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _GoogleButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(loading ? 0.03 : 0.05),
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2)))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 20, height: 20,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text('Continue with Google',
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
                ],
              ),
      ),
    );
  }
}
