import 'package:flutter/services.dart' show rootBundle;

/// 絵文字カテゴリー
enum EmojiCategory {
  all('all', 'すべて'),
  social('social', 'SNS'),
  business('business', 'ビジネス'),
  personal('personal', '個人'),
  services('services', 'サービス'),
  media('media', 'メディア'),
  technology('tech', 'テクノロジー'),
  animals('animals', '動物'),
  places('places', '場所'),
  transport('transport', '乗り物'),
  food('food', '食べ物・飲み物'),
  emotions('emotions', '感情・表情'),
  sports('sports', 'スポーツ'),
  others('others', 'その他');

  final String id;
  final String label;
  const EmojiCategory(this.id, this.label);

  static final Map<String, List<String>> _emojiMap = {};
  List<String> get emojis => _emojiMap[id] ?? [];

  static EmojiCategory fromId(String id) =>
      values.firstWhere((c) => c.id == id, orElse: () => all);

  static List<EmojiCategory> get displayCategories => [
    social,
    business,
    personal,
    services,
    media,
    technology,
    sports,
    animals,
    food,
  ];

  static List<EmojiCategory> get allCategories =>
      values.where((c) => c != all).toList();

  static List<String> get allEmojis => all.emojis;

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
        'SNS': 'social',
        'ビジネス': 'business',
        '個人': 'personal',
        'サービス': 'services',
        'メディア': 'media',
        'テクノロジー': 'technology',
        '動物': 'animals',
        '場所': 'places',
        '乗り物': 'transport',
        '食べ物・飲み物': 'food',
        '感情・表情': 'emotions',
        'スポーツ': 'sports',
        'その他': 'others',
      };

      _emojiMap.clear();
      for (final c in allCategories) _emojiMap[c.id] = [];

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

      List<String> allList = <String>[];
      for (var list in _emojiMap.values) {
        allList.addAll(list);
      }
      _emojiMap['all'] = allList;
    } catch (e) {
      print('絵文字読み込みエラー: $e');
    }
  }
}
