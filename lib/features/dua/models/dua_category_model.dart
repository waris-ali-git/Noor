class DuaCategory {
  final int id;
  final String category;
  final String categoryAr;
  final String icon;
  final List<SingleDua> duas;

  const DuaCategory({
    required this.id,
    required this.category,
    required this.categoryAr,
    required this.icon,
    required this.duas,
  });

  int get duaCount => duas.length;

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] as int,
      category: json['category'] as String,
      categoryAr: json['categoryAr'] as String,
      icon: json['icon'] as String? ?? 'auto_awesome',
      duas: (json['duas'] as List<dynamic>)
          .map((d) => SingleDua.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SingleDua {
  final int id;
  final String arabic;
  final String transliteration;
  final String translationEn;
  final String reference;
  final String? benefit;

  const SingleDua({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translationEn,
    required this.reference,
    this.benefit,
  });

  factory SingleDua.fromJson(Map<String, dynamic> json) {
    return SingleDua(
      id: json['id'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translationEn: json['translationEn'] as String,
      reference: json['reference'] as String,
      benefit: json['benefit'] as String?,
    );
  }
}
