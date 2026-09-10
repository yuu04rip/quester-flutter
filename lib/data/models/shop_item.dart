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

  factory ShopItem.fromMap(Map<String, dynamic> map) {
    // Gestione sicura per evitare errori di tipo (String vs num)
    int parsePrice(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseScale(dynamic val) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 1.0;
      return 1.0;
    }

    return ShopItem(
      itemId: map['itemId'] ?? map['item_id'] ?? '',
      name: map['name'] ?? '',
      price: parsePrice(map['price']),
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? map['icon_name'] ?? 'shopping_cart',
      iconScale: parseScale(map['iconScale'] ?? map['icon_scale']),
    );
  }
}