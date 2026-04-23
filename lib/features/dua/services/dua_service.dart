import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dua_category_model.dart';

class DuaService {
  static DuaService? _instance;
  static DuaService get instance => _instance ??= DuaService._();
  DuaService._();

  List<DuaCategory>? _cache;

  Future<List<DuaCategory>> loadCategories() async {
    if (_cache != null) return _cache!;
    final jsonStr = await rootBundle.loadString('lib/assets/data/duas_database.json');
    final List<dynamic> jsonList = json.decode(jsonStr) as List<dynamic>;
    _cache = jsonList
        .map((e) => DuaCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  List<DuaCategory> search(List<DuaCategory> all, String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((cat) {
      final nameMatch = cat.category.toLowerCase().contains(q) ||
          cat.categoryAr.contains(query);
      final duaMatch = cat.duas.any((d) =>
          d.arabic.contains(query) ||
          d.transliteration.toLowerCase().contains(q) ||
          d.translationEn.toLowerCase().contains(q));
      return nameMatch || duaMatch;
    }).toList();
  }
}
