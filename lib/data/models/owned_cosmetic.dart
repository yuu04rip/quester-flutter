// lib/models/owned_cosmetic.dart

class OwnedCosmetic {
  final int userId;
  final String itemId;

  OwnedCosmetic({
    required this.userId,
    required this.itemId,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'itemId': itemId,
  };

  factory OwnedCosmetic.fromMap(Map<String, dynamic> map) => OwnedCosmetic(
    userId: map['userId'] ?? 0,
    itemId: map['itemId'] ?? '',
  );
}