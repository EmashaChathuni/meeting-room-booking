// lib/constants/api_constants.dart
// Central place to store all API configuration values

class ApiConstants {
  // ============================================================
  // IMPORTANT: Change baseUrl to match your environment:
  //
  // ▶ Choreo production (APK release):
  //   'https://66393585-7f58-4d9a-86f6-1fc090093011-dev.e1-eu-north-azure.choreoapis.dev/default/backend/v1.0'
  //
  // ▶ Local backend on physical Android device:
  //   'http://YOUR_PC_IP:8080'   (e.g. http://192.168.1.5:8080)
  //
  // ▶ Local backend on Android emulator:
  //   'http://10.0.2.2:8080'
  //
  // ▶ Local backend on same PC (web/desktop):
  //   'http://localhost:8080'
  // ============================================================
  static const String baseUrl =
      'https://66393585-7f58-4d9a-86f6-1fc090093011-dev.e1-eu-north-azure.choreoapis.dev/default/backend/v1.0';

  // API Key — must match API_KEY in backend .env
  static const String apiKey = 'my-secret-api-key';

  // Full URL for bookings endpoint
  static const String bookingsEndpoint = '$baseUrl/api/bookings';

  // HTTP Headers sent with every request
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'X-API-Key': apiKey,
      };
}

