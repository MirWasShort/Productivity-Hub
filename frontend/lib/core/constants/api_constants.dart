/// Base URL of the backend API. Overridable at build/run time:
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8081
abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );
}
