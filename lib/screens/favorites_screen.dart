import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>().favorites;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saved', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)).animate().fadeIn(),
                  Text('${favs.length} item${favs.length == 1 ? '' : 's'} saved',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)).animate().fadeIn(delay: 80.ms),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: favs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border, color: AppTheme.textSecondary, size: 56).animate().scale(),
                          const SizedBox(height: 12),
                          const Text('No saved items yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          const Text('Tap ♥ on any dish to save it', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: favs.length,
                      itemBuilder: (_, i) {
                        final p = favs[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: p.imageUrl, width: 72, height: 72, fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 72, height: 72, color: AppTheme.surface,
                                    child: const Icon(Icons.fastfood, color: AppTheme.textSecondary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(p.restaurant, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Text('\$${p.price.toStringAsFixed(2)}',
                                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 15)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () => context.read<FavoritesProvider>().toggle(p),
                                    icon: const Icon(Icons.favorite, color: AppTheme.primary, size: 22),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.read<CartProvider>().addToCart(p),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                                      child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: i * 60)).slideX(begin: 0.05);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
