/// Compile-time configuration, supplied with `--dart-define` per environment.
class AppConfig {
  const AppConfig._();

  static Uri? get apiBaseUri {
    const value = String.fromEnvironment('API_BASE_URL');
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('API_BASE_URL must be an http(s) URL.');
    }
    return uri;
  }
}
