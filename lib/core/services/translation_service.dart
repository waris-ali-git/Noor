import 'dart:convert';
import 'package:dio/dio.dart';

class TranslationService {
  final Dio _dio;
  
  // Simple in-memory cache to prevent redundant API calls
  static final Map<String, String> _cache = {};

  TranslationService(this._dio);

  Future<String> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    // If target is English (and source is assumed English) or text is empty
    if (text.trim().isEmpty) return text;
    
    final cacheKey = '${text}_${sourceLang}_$targetLang';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _dio.get(
        'https://translate.googleapis.com/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': sourceLang,
          'tl': targetLang,
          'dt': 't',
          'q': text,
        },
      );

      if (response.statusCode == 200) {
        // The response is a nested array. The translated text is built by 
        // concatenating the first element of each array in the first main array.
        // Example response: [[["Translated Text","Original Text",null,null,1]],null,"en",null,null,null,1,[]]
        final List<dynamic> data = response.data;
        if (data.isNotEmpty && data[0] is List) {
          final List<dynamic> translationParts = data[0];
          StringBuffer translatedText = StringBuffer();
          
          for (var part in translationParts) {
            if (part is List && part.isNotEmpty) {
              translatedText.write(part[0].toString());
            }
          }
          
          final result = translatedText.toString();
          _cache[cacheKey] = result;
          return result;
        }
      }
      return text; // Fallback to original text on parsing error
    } catch (e) {
      print('Translation Error: $e');
      return text; // Fallback to original text on network/other error
    }
  }
}
