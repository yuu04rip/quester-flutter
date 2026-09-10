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
  final bool isPinned;
  final int updatedAt; // Timestamp per la sincronizzazione

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
    this.isPinned = false,
    int? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

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
    'isPinned': isPinned ? 1 : 0,
    'updatedAt': updatedAt,
  };

  factory Mission.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    return Mission(
      id: map['id'] != null ? parseInt(map['id']) : null,
      userId: parseInt(map['userId'] ?? map['user_id']),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      dueDate: map['dueDate'] ?? map['due_date'],
      xpReward: parseInt(map['xpReward'] ?? map['xp_reward']),
      completed: parseBool(map['completed']),
      xpAwarded: parseBool(map['xpAwarded'] ?? map['xp_awarded']),
      redeemed: parseBool(map['redeemed']),
      createdAt: parseInt(map['createdAt'] ?? map['created_at'], DateTime.now().millisecondsSinceEpoch),
      completedAt: map['completedAt'] != null || map['completed_at'] != null
          ? parseInt(map['completedAt'] ?? map['completed_at'])
          : null,
      verificationLevel: map['verificationLevel'] ?? map['verification_level'] ?? 'AUTO',
      isPinned: parseBool(map['isPinned'] ?? map['is_pinned']),
      updatedAt: parseInt(map['updatedAt'] ?? map['updated_at'], DateTime.now().millisecondsSinceEpoch),
    );
  }

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
    bool? isPinned,
    int? updatedAt,
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
      updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}