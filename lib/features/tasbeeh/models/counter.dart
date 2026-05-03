class TasbeehCounter {
  final String id;
  final String name;
  final String arabicText;
  final String transliteration;
  final String translation;
  int count;
  final int targetCount;
  final String category;
  bool isFavorite;
  final DateTime createdAt;
  int totalSessions;
  int totalCount;

  TasbeehCounter({
    required this.id,
    required this.name,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.count = 0,
    this.targetCount = 33,
    this.category = 'General',
    this.isFavorite = false,
    DateTime? createdAt,
    this.totalSessions = 0,
    this.totalCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => targetCount > 0 ? (count / targetCount).clamp(0.0, 1.0) : 0;
  bool get isCompleted => count >= targetCount;
  int get roundsCompleted => count ~/ targetCount;
  int get remainingInRound => targetCount - (count % targetCount);

  TasbeehCounter copyWith({
    String? id,
    String? name,
    String? arabicText,
    String? transliteration,
    String? translation,
    int? count,
    int? targetCount,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    int? totalSessions,
    int? totalCount,
  }) {
    return TasbeehCounter(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      count: count ?? this.count,
      targetCount: targetCount ?? this.targetCount,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      totalSessions: totalSessions ?? this.totalSessions,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'arabicText': arabicText,
    'transliteration': transliteration,
    'translation': translation,
    'count': count,
    'targetCount': targetCount,
    'category': category,
    'isFavorite': isFavorite,
    'createdAt': createdAt.toIso8601String(),
    'totalSessions': totalSessions,
    'totalCount': totalCount,
  };

  factory TasbeehCounter.fromJson(Map<String, dynamic> json) => TasbeehCounter(
    id: json['id'],
    name: json['name'],
    arabicText: json['arabicText'],
    transliteration: json['transliteration'],
    translation: json['translation'],
    count: json['count'] ?? 0,
    targetCount: json['targetCount'] ?? 33,
    category: json['category'] ?? 'General',
    isFavorite: json['isFavorite'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    totalSessions: json['totalSessions'] ?? 0,
    totalCount: json['totalCount'] ?? 0,
  );
}

class TasbeehSession {
  final String id;
  final String tasbeehId;
  final String tasbeehName;
  final int count;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;

  TasbeehSession({
    required this.id,
    required this.tasbeehId,
    required this.tasbeehName,
    required this.count,
    required this.startTime,
    required this.endTime,
  }) : duration = endTime.difference(startTime);
}