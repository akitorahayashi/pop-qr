import 'package:flutter/cupertino.dart';
import '../../model/qr_item.dart';

class QrItemCard extends StatelessWidget {
  final QrItem item;
  final VoidCallback onTap;

  const QrItemCard({Key? key, required this.item, required this.onTap})
    : super(key: key);

  // アイコン名からIconDataを取得するヘルパーメソッド
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'link':
        return CupertinoIcons.link;
      case 'globe':
        return CupertinoIcons.globe;
      case 'phone':
        return CupertinoIcons.device_phone_portrait;
      case 'briefcase':
        return CupertinoIcons.briefcase;
      case 'camera':
        return CupertinoIcons.camera;
      case 'game':
        return CupertinoIcons.game_controller;
      case 'music':
        return CupertinoIcons.music_note;
      case 'book':
        return CupertinoIcons.book;
      case 'chat':
        return CupertinoIcons.chat_bubble;
      case 'cart':
        return CupertinoIcons.cart;
      case 'computer':
        return CupertinoIcons.desktopcomputer;
      case 'person':
        return CupertinoIcons.person;
      default:
        return CupertinoIcons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Hero(
        tag: 'qr_card_${item.id}',
        child: AspectRatio(
          aspectRatio: 1, // 正方形を維持
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconData(item.icon),
                    size: 40,
                    color: CupertinoColors.systemBlue,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
