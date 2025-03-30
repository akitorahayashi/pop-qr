// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../qr_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QrItem _$QrItemFromJson(Map<String, dynamic> json) {
  return _QrItem.fromJson(json);
}

/// @nodoc
mixin _$QrItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;

  /// Serializes this QrItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QrItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QrItemCopyWith<QrItem> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrItemCopyWith<$Res> {
  factory $QrItemCopyWith(QrItem value, $Res Function(QrItem) then) =
      _$QrItemCopyWithImpl<$Res, QrItem>;
  @useResult
  $Res call({String id, String title, String url, String emoji});
}

/// @nodoc
class _$QrItemCopyWithImpl<$Res, $Val extends QrItem>
    implements $QrItemCopyWith<$Res> {
  _$QrItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QrItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
    Object? emoji = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            url:
                null == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String,
            emoji:
                null == emoji
                    ? _value.emoji
                    : emoji // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QrItemImplCopyWith<$Res> implements $QrItemCopyWith<$Res> {
  factory _$$QrItemImplCopyWith(
    _$QrItemImpl value,
    $Res Function(_$QrItemImpl) then,
  ) = __$$QrItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String url, String emoji});
}

/// @nodoc
class __$$QrItemImplCopyWithImpl<$Res>
    extends _$QrItemCopyWithImpl<$Res, _$QrItemImpl>
    implements _$$QrItemImplCopyWith<$Res> {
  __$$QrItemImplCopyWithImpl(
    _$QrItemImpl _value,
    $Res Function(_$QrItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QrItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
    Object? emoji = null,
  }) {
    return _then(
      _$QrItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        url:
            null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String,
        emoji:
            null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QrItemImpl with DiagnosticableTreeMixin implements _QrItem {
  const _$QrItemImpl({
    required this.id,
    required this.title,
    required this.url,
    required this.emoji,
  });

  factory _$QrItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$QrItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String url;
  @override
  final String emoji;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'QrItem(id: $id, title: $title, url: $url, emoji: $emoji)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'QrItem'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('emoji', emoji));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, url, emoji);

  /// Create a copy of QrItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QrItemImplCopyWith<_$QrItemImpl> get copyWith =>
      __$$QrItemImplCopyWithImpl<_$QrItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QrItemImplToJson(this);
  }
}

abstract class _QrItem implements QrItem {
  const factory _QrItem({
    required final String id,
    required final String title,
    required final String url,
    required final String emoji,
  }) = _$QrItemImpl;

  factory _QrItem.fromJson(Map<String, dynamic> json) = _$QrItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get url;
  @override
  String get emoji;

  /// Create a copy of QrItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QrItemImplCopyWith<_$QrItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
