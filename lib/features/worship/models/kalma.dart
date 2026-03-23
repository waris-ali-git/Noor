class Kalma {
  final int id;
  final String name;
  final String arabic;
  final String transliteration;
  final String translation;
  final String description;

  const Kalma({
    required this.id,
    required this.name,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.description,
  });

  factory Kalma.fromJson(Map<String, dynamic> json) {
    return Kalma(
      id: json['id'] as int,
      name: json['name'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      description: json['description'] as String,
    );
  }
}
