// lib/models/shop_item.dart

class ShopItem {
  final String itemId;
  final String name;
  final int price;
  final String description;
  final String iconName;
  final double iconScale;

  ShopItem({
    required this.itemId,
    required this.name,
    required this.price,
    this.description = '',
    this.iconName = 'shopping_cart',
    this.iconScale = 1.0,
  });

  Map<String, dynamic> toMap() => {
    'itemId': itemId,
    'name': name,
    'price': price,
    'description': description,
    'iconName': iconName,
    'iconScale': iconScale,
  };

  factory ShopItem.fromMap(Map<String, dynamic> map) => ShopItem(
    itemId: map['itemId'] ?? '',
    name: map['name'] ?? '',
    price: map['price'] ?? 0,
    description: map['description'] ?? '',
    iconName: map['iconName'] ?? 'shopping_cart',
    iconScale: map['iconScale'] ?? 1.0,
  );
}