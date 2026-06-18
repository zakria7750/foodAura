import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';

const _categories = ['All', 'Burgers', 'Sushi', 'Pizza', 'Meat', 'Asian', 'Noodles', 'Healthy', 'Dessert'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _all = [];
  List<Product> _filtered = [];
  String _selectedCategory = 'All';
  String _query = '';
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _fetchProducts() async {
    try {
      final products = await SupabaseService.fetchProducts();
      setState(() { _all = products; _filtered = products; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _filter(String category, String query) {
    setState(() {
      _selectedCategory = category;
      _query = query;
      _filtered = _all.where((p) {
        final matchCat = category == 'All' || p.category == category;
        final matchQ = query.isEmpty || p.name.toLowerCase().contains(query.toLowerCase())
            || p.restaurant.toLowerCase().contains(query.toLowerCase());
        return matchCat && matchQ;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FoodAura 🔥',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                        const Text('What are you craving today?',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (cartCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('$cartCount in cart', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 16),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                onChanged: (v) => _filter(_selectedCategory, v),
                decoration: const InputDecoration(
                  hintText: 'Search food, restaurant...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 14),

            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (_, i) => CategoryChip(
                  label: _categories[i],
                  selected: _selectedCategory == _categories[i],
                  onTap: () => _filter(_categories[i], _query),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, color: AppTheme.textSecondary, size: 48),
                              const SizedBox(height: 12),
                              const Text('No results found', style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.primary,
                          onRefresh: _fetchProducts,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => ProductCard(product: _filtered[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
