// lib/models/subtask.dart

class SubTask {
  final int id;
  final int missionId;
  final String text;
  final bool done;

  SubTask({
    this.id = 0,
    required this.missionId,
    required this.text,
    this.done = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'missionId': missionId,
    'text': text,
    'done': done ? 1 : 0,
  };

  factory SubTask.fromMap(Map<String, dynamic> map) => SubTask(
    id: map['id'] ?? 0,
    missionId: map['missionId'] ?? 0,
    text: map['text'] ?? '',
    done: (map['done'] ?? 0) == 1,
  );

  SubTask copyWith({
    int? id,
    int? missionId,
    String? text,
    bool? done,
  }) {
    return SubTask(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}