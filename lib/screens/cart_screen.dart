import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _placingOrder = false;

  Future<void> _placeOrder(CartProvider cart) async {
    if (cart.items.isEmpty) return;
    setState(() => _placingOrder = true);

    try {
      final items = cart.items
          .map((i) => OrderItem(
                productId: i.product.id,
                name: i.product.name,
                imageUrl: i.product.imageUrl,
                restaurant: i.product.restaurant,
                price: i.product.price,
                quantity: i.quantity,
              ))
          .toList();

      await SupabaseService.createOrder(items: items, total: cart.total);

      cart.clear();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Order placed successfully!'),
          ]),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _placingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('My Cart',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                    Text('${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ]),
                  if (cart.items.isNotEmpty)
                    TextButton(
                      onPressed: () => cart.clear(),
                      child: const Text('Clear all',
                          style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                ],
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 16),
            Expanded(
              child: cart.items.isEmpty
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.shopping_bag_outlined,
                                color: AppTheme.textSecondary, size: 56)
                            .animate()
                            .scale(),
                        const SizedBox(height: 12),
                        const Text('Your cart is empty',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Add some delicious food to get started',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ]),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      itemCount: cart.items.length,
                      itemBuilder: (_, i) {
                        final item = cart.items[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: AppTheme.border.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.imageUrl,
                                  width: 68,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 68,
                                    height: 68,
                                    color: AppTheme.surface,
                                    child: const Icon(Icons.fastfood,
                                        color: AppTheme.textSecondary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name,
                                          style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(item.product.restaurant,
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 11)),
                                      const SizedBox(height: 6),
                                      Text(
                                          '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14)),
                                    ]),
                              ),
                              Row(children: [
                                _QtyBtn(
                                    icon: Icons.remove,
                                    onTap: () => cart.decrement(item.product.id)),
                                Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  child: Text('${item.quantity}',
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15)),
                                ),
                                _QtyBtn(
                                    icon: Icons.add,
                                    onTap: () => cart.increment(item.product.id)),
                              ]),
                            ],
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
                      },
                    ),
            ),
            if (cart.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 14)),
                            Text('\$${cart.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22)),
                          ]),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _placingOrder ? null : () => _placeOrder(cart),
                      child: _placingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text('Place Order • \$${cart.total.toStringAsFixed(2)}'),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppTheme.primary, size: 16),
      ),
    );
  }
}
