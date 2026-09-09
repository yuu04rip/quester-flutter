// lib/models/mission.dart

enum VerificationLevel {
  none,
  auto,
  manual
}

class Mission {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String type;
  final String? dueDate;
  final int xpReward;
  final bool completed;
  final bool xpAwarded;
  final bool redeemed;
  final int createdAt;
  final int? completedAt;
  final String verificationLevel;
  final bool isPinned; // <-- Aggiunto campo isPinned

  Mission({
    this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.type,
    this.dueDate,
    this.xpReward = 0,
    this.completed = false,
    this.xpAwarded = false,
    this.redeemed = false,
    int? createdAt,
    this.completedAt,
    this.verificationLevel = 'AUTO',
    this.isPinned = false, // <-- Default a false
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  // Conversione da/verso Map per il database
  Map<String, dynamic> toMap() => {
    if (id != null && id != 0) 'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'type': type,
    'dueDate': dueDate,
    'xpReward': xpReward,
    'completed': completed ? 1 : 0,
    'xpAwarded': xpAwarded ? 1 : 0,
    'redeemed': redeemed ? 1 : 0,
    'createdAt': createdAt,
    'completedAt': completedAt,
    'verificationLevel': verificationLevel,
    'isPinned': isPinned ? 1 : 0, // <-- Mappato nel DB come intero
  };

  factory Mission.fromMap(Map<String, dynamic> map) => Mission(
    id: map['id'],
    userId: map['userId'] ?? 0,
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    type: map['type'] ?? '',
    dueDate: map['dueDate'],
    xpReward: map['xpReward'] ?? 0,
    completed: (map['completed'] ?? 0) == 1,
    xpAwarded: (map['xpAwarded'] ?? 0) == 1,
    redeemed: (map['redeemed'] ?? 0) == 1,
    createdAt: map['createdAt'] ?? 0,
    completedAt: map['completedAt'],
    verificationLevel: map['verificationLevel'] ?? 'AUTO',
    isPinned: (map['isPinned'] ?? 0) == 1, // <-- Letto dal DB
  );

  // Copy per aggiornamenti
  Mission copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? type,
    String? dueDate,
    int? xpReward,
    bool? completed,
    bool? xpAwarded,
    bool? redeemed,
    int? createdAt,
    int? completedAt,
    String? verificationLevel,
    bool? isPinned, // <-- Aggiunto nel copyWith
  }) {
    return Mission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      xpReward: xpReward ?? this.xpReward,
      completed: completed ?? this.completed,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      redeemed: redeemed ?? this.redeemed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}