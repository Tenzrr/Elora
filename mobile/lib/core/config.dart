class AppConfig {
  const AppConfig({
    this.apiUrl = '',
    this.firebaseApiKey = '',
    this.firebaseAppId = '',
    this.firebaseSenderId = '',
    this.firebaseProjectId = '',
    this.googleWebClientId = '',
  });

  const AppConfig.fromEnvironment()
    : apiUrl = const String.fromEnvironment('API_BASE_URL'),
      firebaseApiKey = const String.fromEnvironment('FIREBASE_API_KEY'),
      firebaseAppId = const String.fromEnvironment('FIREBASE_APP_ID'),
      firebaseSenderId = const String.fromEnvironment('FIREBASE_SENDER_ID'),
      firebaseProjectId = const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      googleWebClientId = const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  final String apiUrl;
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseSenderId;
  final String firebaseProjectId;
  final String googleWebClientId;

  bool get configured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty &&
      Uri.tryParse(apiUrl)?.hasAuthority == true;
}
