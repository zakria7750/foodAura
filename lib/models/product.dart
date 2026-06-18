class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String restaurant;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.restaurant,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      restaurant: json['restaurant'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
