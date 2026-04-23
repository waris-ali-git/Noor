class DuaImageService {
  static final List<String> _aestheticIds = [
    '1470071459604-3b5ec3a7fe05', // Foggy Forest
    '1441974231531-c6227db76b6e', // Sunlight Woods
    '1426604966848-d7adac402bff', // Water/Nature
    '1494774157365-9e04c6720e47', // Cinematic Flowers
    '1510784722466-f2aa9c52fff6', // Sunrise
    '1475924156734-496f6cac6ec1', // Night Sky
    '1472214103451-9374bd1c798e', // Mountain
    '1434030216411-0b793f4b4173', // Study/Library
  ];

  Future<String> fetchBackgroundImage() async {
    // Select Random ID
    final String selectedId = _aestheticIds[DateTime.now().millisecondsSinceEpoch % _aestheticIds.length];

    // Construct Direct URL
    // fit=crop, w=1080, q=80 ensures mobile optimization
    return 'https://images.unsplash.com/photo-$selectedId?auto=format&fit=crop&w=1080&q=80';
  }
}
