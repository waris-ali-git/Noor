import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/feeling_dua_model.dart';

class FeelingDuaService {
  static const Map<String, Color> feelingColors = {
    'angry': Color(0xFFD32F2F),
    'anxious': Color(0xFFF57C00),
    'bored': Color(0xFF9E9E9E),
    'confident': Color(0xFF1565C0),
    'confused': Color(0xFF7E57C2),
    'content': Color(0xFF66BB6A),
    'depressed': Color(0xFF37474F),
    'doubtful': Color(0xFF8D6E63),
    'grateful': Color(0xFFFFD54F),
    'greedy': Color(0xFFE65100),
    'guilty': Color(0xFF5D4037),
    'happy': Color(0xFF90BDE7),
    'hopeful': Color(0xFF4FC3F7),
    'hopeless': Color(0xFF455A64),
    'humble': Color(0xFFA1887F),
    'hurt': Color(0xFFC62828),
    'hypocritical': Color(0xFF78909C),
    'ill': Color(0xFF81C784),
    'indecisive': Color(0xFFB0BEC5),
    'jealous': Color(0xFF2E7D32),
    'lazy': Color(0xFFBCAAA4),
    'lonely': Color(0xFF5C6BC0),
    'lost': Color(0xFF607D8B),
    'nervous': Color(0xFFFF8A65),
    'overwhelmed': Color(0xFFAB47BC),
    'regret': Color(0xFF795548),
    'sad': Color(0xFF42A5F5),
    'scared': Color(0xFF263238),
    'suicidal': Color(0xFF880E4F),
    'tired': Color(0xFF8D6E63),
    'unloved': Color(0xFFCE93D8),
    'weak': Color(0xFFBDBDBD),
  };

  static const Map<String, String> feelingEmojis = {
    'angry': '😡',
    'anxious': '😰',
    'bored': '😒',
    'confident': '😎',
    'confused': '😕',
    'content': '😌',
    'depressed': '😔',
    'doubtful': '🤔',
    'grateful': '🙏',
    'greedy': '🤑',
    'guilty': '😓',
    'happy': '😊',
    'hopeful': '✨',
    'hopeless': '🥀',
    'humble': '🙇',
    'hurt': '💔',
    'hypocritical': '🎭',
    'ill': '🤒',
    'indecisive': '🤷',
    'jealous': '😒',
    'lazy': '🥱',
    'lonely': '🚶',
    'lost': '🌫️',
    'nervous': '😬',
    'overwhelmed': '🤯',
    'regret': '😞',
    'sad': '😢',
    'scared': '😨',
    'suicidal': '🆘',
    'tired': '😫',
    'unloved': '🥀',
    'weak': '🥀',
  };

  static String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  Future<List<FeelingCategory>> loadFeelingDuas() async {
    try {
      final jsonString = await rootBundle.loadString('lib/assets/data/feeling_duas.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<FeelingCategory> categories = [];

      data.forEach((key, value) {
        if (value is List) {
          final List<FeelingDua> duas = value.map((e) => FeelingDua.fromJson(e)).toList();
          
          categories.add(FeelingCategory(
            id: key,
            name: _capitalize(key),
            duas: duas,
            color: feelingColors[key] ?? const Color(0xFF607D8B),
            emoji: feelingEmojis[key] ?? '✨',
          ));
        }
      });

      return categories;
    } catch (e) {
      debugPrint('Error loading feeling duas: $e');
      return [];
    }
  }
}
