import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/order.dart';

class SupabaseService {
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://ptpnkdaigzhtnuackhtt.supabase.co');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_kHa7ozdNcVTluv4eMJ3Q9A_xRAu9Uyg');

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  // ── Products ──────────────────────────────────────────────────────────────

  static Future<List<Product>> fetchProducts() async {
    final response = await client
        .from('products')
        .select()
        .order('id', ascending: true);
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<List<Product>> searchProducts(String query) async {
    final response = await client
        .from('products')
        .select()
        .ilike('name', '%$query%');
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }

  static Future<List<Product>> fetchByCategory(String category) async {
    final response = await client
        .from('products')
        .select()
        .eq('category', category);
    return (response as List).map((e) => Product.fromJson(e)).toList();
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  /// إنشاء طلب جديد. يعيد الطلب المحفوظ أو يرمي خطأً.
  static Future<Order> createOrder({
    required List<OrderItem> items,
    required double total,
  }) async {
    final userId = client.auth.currentUser?.id;

    final payload = {
      'user_id': userId,
      'items': items.map((i) => i.toJson()).toList(),
      'total': total,
      'status': 'pending',
    };

    final response = await client
        .from('orders')
        .insert(payload)
        .select()
        .single();

    return Order.fromJson(response as Map<String, dynamic>);
  }

  /// جلب طلبات المستخدم الحالي مرتّبة من الأحدث للأقدم.
  static Future<List<Order>> fetchMyOrders() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
