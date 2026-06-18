import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match'); return;
    }
    if (_passCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters'); return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await context.read<AuthProvider>().signUp(
      _emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() { _loading = false; });
    if (err != null) { setState(() => _error = err); }
    else { setState(() => _success = true); }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: AppTheme.primary, size: 32),
                ).animate().scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 20),
                const Text('Check your email!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('We sent a confirmation link to ${_emailCtrl.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text('Join FoodAura', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)).animate().fadeIn(),
              const SizedBox(height: 4),
              const Text('Create your account to start ordering', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)).animate().fadeIn(delay: 80.ms),
              const SizedBox(height: 32),

              TextField(controller: _nameCtrl, style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Full name', prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20)),
              ).animate().fadeIn(delay: 120.ms),
              const SizedBox(height: 12),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Email address', prefixIcon: Icon(Icons.mail_outline, color: AppTheme.textSecondary, size: 20)),
              ).animate().fadeIn(delay: 160.ms),
              const SizedBox(height: 12),
              TextField(controller: _passCtrl, obscureText: _obscure, style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Password (min 6 characters)',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                  suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20)),
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              TextField(controller: _confirmCtrl, obscureText: _obscure, style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Confirm password', prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20)),
              ).animate().fadeIn(delay: 240.ms),

              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account'),
              ).animate().fadeIn(delay: 280.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
