class Validation {
  /// URLが有効かどうかを検証するメソッド
  ///
  /// URLの形式が正しいかどうかをチェックする
  /// 返り値: 有効な場合はnull、無効な場合はエラーメッセージ
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URLを入力してください';
    }

    // 簡易的なURL検証（http/httpsで始まることを確認）
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      return 'URLはhttp://またはhttps://で始まる必要があります';
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return '有効なURLではありません';
      }
      return null;
    } catch (e) {
      return '有効なURLではありません';
    }
  }

  /// タイトルが有効かどうかを検証するメソッド
  ///
  /// タイトルが空でないか、最大長を超えていないかをチェックする
  /// 返り値: 有効な場合はnull、無効な場合はエラーメッセージ
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'タイトルを入力してください';
    }

    if (value.length > 50) {
      return 'タイトルは50文字以内で入力してください';
    }

    return null;
  }
}
