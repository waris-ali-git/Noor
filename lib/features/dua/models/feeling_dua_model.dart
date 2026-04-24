import 'package:flutter/material.dart';

class FeelingDua {
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String hadith;
  final String reference;

  FeelingDua({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.hadith,
    required this.reference,
  });

  factory FeelingDua.fromJson(Map<String, dynamic> json) {
    return FeelingDua(
      title: json['title'] ?? '',
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      translation: json['translation'] ?? '',
      hadith: json['hadith'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}

class FeelingCategory {
  final String id;
  final String name;
  final List<FeelingDua> duas;
  final Color color;
  final String emoji;

  FeelingCategory({
    required this.id,
    required this.name,
    required this.duas,
    required this.color,
    required this.emoji,
  });
}
