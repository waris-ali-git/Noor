class ProphetModel {
  final int id;
  final String arabicName;
  final String englishName;
  final String title; // e.g. "Father of Mankind"
  final String period; // e.g. "~4000 BCE"
  final String mentionedIn; // Quran reference
  final String shortBio;
  final String keyLesson;
  final List<String> tableOfContents; // sections (empty if short story)
  final List<ProphetSection> sections;
  final String emoji; // visual icon

  const ProphetModel({
    required this.id,
    required this.arabicName,
    required this.englishName,
    required this.title,
    required this.period,
    required this.mentionedIn,
    required this.shortBio,
    required this.keyLesson,
    required this.tableOfContents,
    required this.sections,
    required this.emoji,
  });
}

class ProphetSection {
  final String heading;
  final String content;

  const ProphetSection({required this.heading, required this.content});
}
