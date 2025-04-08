import 'package:flutter/services.dart' show rootBundle;

/// 絵文字カテゴリー
enum EmojiCategory {
  technology('technology', 'テクノロジー'),
  hobby('hobby', '趣味'),
  services('services', 'サービス'),
  personal('personal', '個人'),
  food('food', '食べ物・飲み物'),
  places('places', '場所'),
  transport('transport', '乗り物'),
  animals('animals', '動物'),
  weather('weather', '天気');

  final String id;
  final String label;
  const EmojiCategory(this.id, this.label);

  static final Map<String, List<String>> _emojiMap = {};
  List<String> get emojis => _emojiMap[id] ?? [];

  static EmojiCategory fromId(String id) =>
      values.firstWhere((c) => c.id == id, orElse: () => technology);

  static List<EmojiCategory> get displayCategories => [
    technology,
    hobby,
    services,
    personal,
    food,
    places,
    transport,
    animals,
    weather,
  ];

  static List<EmojiCategory> get allCategories => values.toList();

  static List<String> get allEmojis {
    final List<String> result = [];
    for (final category in values) {
      result.addAll(category.emojis);
    }
    return result;
  }

  static Map<String, String> get categoryNames => {
    for (final c in values) c.id: c.label,
  };

  static Map<String, List<String>> get categoryEmojiMap => {
    for (final c in values) c.id: c.emojis,
  };

  static Future<void> loadEmojisFromFile() async {
    try {
      final content = await rootBundle.loadString(
        'lib/resource/emoji_list.txt',
      );
      final categoryMapping = {
        'SNS': 'technology',
        'ビジネス': 'services',
        '個人': 'personal',
        'サービス': 'services',
        'メディア': 'hobby',
        '趣味': 'hobby',
        'スポーツ': 'hobby',
        'テクノロジー': 'technology',
        '動物': 'animals',
        '場所': 'places',
        '乗り物': 'transport',
        '食べ物・飲み物': 'food',
        '天気': 'weather',
      };

      _emojiMap.clear();
      for (final c in allCategories) {
        _emojiMap[c.id] = [];
      }

      var lines = content.split('\n');
      var currentCategory = '';

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        if (line.startsWith('#')) {
          var categoryName = line.substring(1).trim();
          currentCategory =
              categoryMapping.entries
                  .firstWhere(
                    (e) => categoryName.contains(e.key),
                    orElse: () => MapEntry('', ''),
                  )
                  .value;
          continue;
        }

        if (currentCategory.isNotEmpty) {
          var emojis =
              line
                  .split(' ')
                  .where((e) => e.isNotEmpty && e.codeUnits.every((c) => c > 0))
                  .map((e) => e.trim())
                  .toList();
          _emojiMap[currentCategory]?.addAll(emojis);
        }
      }
    } catch (e) {
      print('絵文字読み込みエラー: $e');
    }
  }
}
