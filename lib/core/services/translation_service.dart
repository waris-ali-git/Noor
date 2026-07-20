import 'dart:convert';
import 'package:dio/dio.dart';

class TranslationService {
  final Dio _dio;
  
  // Simple in-memory cache to prevent redundant API calls
  static final Map<String, String> _cache = {};

  static const Map<String, String> _urduOverrides = {
    'kalma': 'کلمہ',
    'kalmas': 'کلمے',
    '6 kalmas': '6 کلمے',
    'namaz': 'نماز',
    'roza': 'روزہ',
    'zakat': 'زکوٰۃ',
    'hajj': 'حج',
    'the declaration of faith': 'ایمان کا اقرار',
    'the five daily prayers': 'پانچ وقت کی نماز',
    'fasting in ramadan': 'رمضان میں روزہ',
    'obligatory charity': 'فرض زکوٰۃ',
    'pilgrimage to makkah': 'مکہ کی زیارت (حج)',
    '5 pillars of islam': 'اسلام کے 5 ارکان',
    'explore the foundational acts of worship in islam.': 'اسلام میں عبادت کے بنیادی اعمال کو دریافت کریں۔',
    'first kalma (tayyab)': 'پہلا کلمہ (طیب)',
    'second kalma (shahadat)': 'دوسرا کلمہ (شہادت)',
    'third kalma (tamjeed)': 'تیسرا کلمہ (تمجید)',
    'fourth kalma (tauheed)': 'چوتھا کلمہ (توحید)',
    'fifth kalma (astaghfar)': 'پانچواں کلمہ (استغفار)',
    'sixth kalma (radde kufr)': 'چھٹا کلمہ (ردِ کفر)',
    'transliteration': 'رومن اردو',
  };

  TranslationService(this._dio);

  Future<String> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    // If target is English (and source is assumed English) or text is empty
    if (text.trim().isEmpty) return text;
    
    if (targetLang == 'ur') {
      final key = text.trim().toLowerCase();
      if (_urduOverrides.containsKey(key)) {
        return _urduOverrides[key]!;
      }
    }

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
