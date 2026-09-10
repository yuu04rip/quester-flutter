class User {
  final int id;
  final String username;
  final String? email;
  final String passwordHash;
  final int xpTotale;
  final int livello;
  final int coins;
  final String equippedHat;
  final String equippedWeapon;
  final String equippedFrame;
  final int updatedAt; // Timestamp per la sincronizzazione

  User({
    this.id = 0,
    required this.username,
    this.email,
    required this.passwordHash,
    this.xpTotale = 0,
    this.livello = 1,
    this.coins = 0,
    this.equippedHat = 'NONE',
    this.equippedWeapon = 'NONE',
    this.equippedFrame = 'NONE',
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'passwordHash': passwordHash,
    'xpTotale': xpTotale,
    'livello': livello,
    'coins': coins,
    'equippedHat': equippedHat,
    'equippedWeapon': equippedWeapon,
    'equippedFrame': equippedFrame,
    'updatedAt': updatedAt,
  };

  factory User.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    return User(
      id: parseInt(map['id'] ?? map['user_id']),
      username: map['username'] ?? '',
      email: map['email'],
      passwordHash: map['passwordHash'] ?? map['password_hash'] ?? '',
      xpTotale: parseInt(map['xpTotale'] ?? map['xp_totale']),
      livello: parseInt(map['livello'] ?? map['level'], 1),
      coins: parseInt(map['coins']),
      equippedHat: map['equippedHat'] ?? map['equipped_hat'] ?? 'NONE',
      equippedWeapon: map['equippedWeapon'] ?? map['equipped_weapon'] ?? 'NONE',
      equippedFrame: map['equippedFrame'] ?? map['equipped_frame'] ?? 'NONE',
      updatedAt: parseInt(map['updatedAt'] ?? map['updated_at'], DateTime.now().millisecondsSinceEpoch),
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    int? xpTotale,
    int? livello,
    int? coins,
    String? equippedHat,
    String? equippedWeapon,
    String? equippedFrame,
    int? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      xpTotale: xpTotale ?? this.xpTotale,
      livello: livello ?? this.livello,
      coins: coins ?? this.coins,
      equippedHat: equippedHat ?? this.equippedHat,
      equippedWeapon: equippedWeapon ?? this.equippedWeapon,
      equippedFrame: equippedFrame ?? this.equippedFrame,
      updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}