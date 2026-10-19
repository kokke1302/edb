class SettingData {
  final String apiUrl;
  final bool useTranslationApi;
  final bool useDictionaryApi;

  //   flutter run --dart-define=API_URL=https://example.com
  const SettingData({
    this.apiUrl = const String.fromEnvironment('API_URL'),
    this.useTranslationApi = false,
    this.useDictionaryApi = false,
  });

  bool get hasUrl => apiUrl.isNotEmpty; // URLが設定されているか

  Uri get translateEndpoint => Uri.parse('$apiUrl/api/translate');
  Uri get dictionaryEndpoint => Uri.parse('$apiUrl/api/dictionary');

  // 前後の空白と、末尾の「/」を取り除く
  static String normalizeUrl(String url) {
    return url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  // 空文字、または http / https の絶対URLなら true
  static bool isValidUrl(String url) {
    if (url.isEmpty) return true;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  // 変更用メソッド
  SettingData copyWith({
    String? apiUrl,
    bool? useTranslationApi,
    bool? useDictionaryApi,
  }) {
    return SettingData(
      apiUrl: apiUrl ?? this.apiUrl,
      useTranslationApi: useTranslationApi ?? this.useTranslationApi,
      useDictionaryApi: useDictionaryApi ?? this.useDictionaryApi,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SettingData &&
      other.apiUrl == apiUrl &&
      other.useTranslationApi == useTranslationApi &&
      other.useDictionaryApi == useDictionaryApi;

  @override
  int get hashCode => Object.hash(apiUrl, useTranslationApi, useDictionaryApi);
}
