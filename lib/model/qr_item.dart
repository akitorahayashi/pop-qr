import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate/qr_item.freezed.dart';
part 'generate/qr_item.g.dart';

// $ dart run build_runner build

@freezed
class QrItem with _$QrItem {
  const factory QrItem({
    required String id,
    required String title,
    required String url,
    required String emoji,
  }) = _QrItem;

  factory QrItem.fromJson(Map<String, dynamic> json) => _$QrItemFromJson(json);
}
