import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const FoodAuraApp());
}

class FoodAuraApp extends StatelessWidget {
  const FoodAuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'FoodAura',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('FoodAura',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFFF6B35))),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Color(0xFFFF6B35)),
            ],
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const MainScreen();
    }

    return const LoginScreen();
  }
}
