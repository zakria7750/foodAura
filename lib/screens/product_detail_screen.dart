import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final favs = context.watch<FavoritesProvider>();
    final isFav = favs.isFavorite(product.id);
    final inCart = cart.isInCart(product.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero Image AppBar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => context.read<FavoritesProvider>().toggle(product),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppTheme.primary : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.surface),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surface,
                  child: const Icon(Icons.fastfood, color: AppTheme.textSecondary, size: 80),
                ),
              ),
            ),
          ),

          // ── Product Info ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Rating row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBC04).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFBBC04), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Color(0xFFFBBC04), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

                  const SizedBox(height: 8),

                  // Restaurant
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, color: AppTheme.textSecondary, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        product.restaurant,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ).animate().fadeIn(delay: 80.ms),

                  const SizedBox(height: 6),

                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ).animate().fadeIn(delay: 120.ms),

                  const SizedBox(height: 28),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 20),

                  // Description placeholder
                  const Text(
                    'About this dish',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ).animate().fadeIn(delay: 160.ms),
                  const SizedBox(height: 8),
                  Text(
                    'A carefully crafted dish from ${product.restaurant}, '
                    'made with the finest ingredients. '
                    'Rated ${product.rating.toStringAsFixed(1)} stars by our community.',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 28),

                  // Info row
                  Row(
                    children: [
                      _InfoBadge(icon: Icons.access_time, label: '25–35 min'),
                      const SizedBox(width: 12),
                      _InfoBadge(icon: Icons.delivery_dining, label: 'Free delivery'),
                      const SizedBox(width: 12),
                      _InfoBadge(icon: Icons.local_fire_department, label: '~520 kcal'),
                    ],
                  ).animate().fadeIn(delay: 240.ms),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 24),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<CartProvider>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${product.name} added to cart'),
                    backgroundColor: AppTheme.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                },
                icon: Icon(inCart ? Icons.check : Icons.add_shopping_cart, size: 18),
                label: Text(inCart ? 'Added to Cart' : 'Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart ? Colors.green.shade700 : AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.2, duration: 400.ms),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
