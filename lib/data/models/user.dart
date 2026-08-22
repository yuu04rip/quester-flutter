// lib/models/user.dart

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
  });

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
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] ?? 0,
    username: map['username'] ?? '',
    email: map['email'],
    passwordHash: map['passwordHash'] ?? '',
    xpTotale: map['xpTotale'] ?? 0,
    livello: map['livello'] ?? 1,
    coins: map['coins'] ?? 0,
    equippedHat: map['equippedHat'] ?? 'NONE',
    equippedWeapon: map['equippedWeapon'] ?? 'NONE',
    equippedFrame: map['equippedFrame'] ?? 'NONE',
  );

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
    );
  }
}