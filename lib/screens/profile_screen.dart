import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.15),
                  border:
                      Border.all(color: AppTheme.primary.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    auth.displayName.isNotEmpty
                        ? auth.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ).animate().scale(delay: 50.ms),
              const SizedBox(height: 16),
              Text(
                auth.displayName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 4),
              Text(
                auth.isGuest
                    ? 'Browsing as Guest'
                    : (auth.user?.email ?? ''),
                style:
                    const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ).animate().fadeIn(delay: 130.ms),
              if (auth.isGuest) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Guest Mode',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ).animate().fadeIn(delay: 160.ms),
              ],
              const SizedBox(height: 36),

              // ── Menu tiles ─────────────────────────────────────────────
              if (!auth.isGuest) ...[
                _MenuTile(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Orders',
                  subtitle: 'View your order history',
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OrdersScreen())),
                ).animate().fadeIn(delay: 180.ms).slideX(begin: 0.05),
                const SizedBox(height: 10),
              ],

              _MenuTile(
                icon: Icons.restaurant_menu,
                label: 'App Version',
                subtitle: '1.0.0',
                showArrow: false,
              ).animate().fadeIn(delay: 220.ms).slideX(begin: 0.05),
              const SizedBox(height: 10),
              _MenuTile(
                icon: Icons.storage,
                label: 'Database',
                subtitle: 'Supabase',
                showArrow: false,
              ).animate().fadeIn(delay: 260.ms).slideX(begin: 0.05),

              const SizedBox(height: 36),

              // ── Sign out ───────────────────────────────────────────────
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.15),
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                ),
                onPressed: () async {
                  await auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, size: 18),
                label: Text(auth.isGuest ? 'Exit Guest Mode' : 'Sign Out'),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          if (showArrow)
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
        ]),
      ),
    );
  }
}
