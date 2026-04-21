import 'dart:io';
import 'dart:convert';

void main() {
  final dbFile = File('lib/assets/data/quran/wbw_translations/indonesian-word-by-word-translation.db');
  if (!dbFile.existsSync()) {
    print('DB not found!');
    return;
  }
  
  final bytes = dbFile.readAsBytesSync();
  final sb = StringBuffer();
  for (int i = 0; i < bytes.length; i++) {
    final b = bytes[i];
    if (b >= 32 && b <= 126) {
      sb.writeCharCode(b);
    } else {
      if (sb.length > 5) {
        print(sb.toString());
      }
      sb.clear();
    }
  }
}
