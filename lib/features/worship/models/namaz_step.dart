class NamazStep {
  final String id;
  final String title;
  final String description;
  final String? arabicDua;
  final String? duaTransliteration;
  final String? duaTranslation;
  final String imagePath; // Local asset path for the step illustration

  const NamazStep({
    required this.id,
    required this.title,
    required this.description,
    this.arabicDua,
    this.duaTransliteration,
    this.duaTranslation,
    required this.imagePath,
  });

  factory NamazStep.fromJson(Map<String, dynamic> json) {
    return NamazStep(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      arabicDua: json['arabicDua'] as String?,
      duaTransliteration: json['duaTransliteration'] as String?,
      duaTranslation: json['duaTranslation'] as String?,
      imagePath: json['imagePath'] as String,
    );
  }
}
