// lib/constants/api_constants.dart
// Central place to store all API configuration values

class ApiConstants {
  // ============================================================
  // IMPORTANT: Change this to your local IP when testing on a
  // physical device (e.g., http://192.168.1.100:8080)
  // Use http://10.0.2.2:8080 for Android emulator
  // Use http://localhost:8080 for web/Chrome
  // ============================================================
  static const String baseUrl = 'http://localhost:8080';

  // API Key - must match the API_KEY value in your backend .env file
  static const String apiKey = 'my-secret-api-key-change-this';

  // Full URL for bookings endpoint
  static const String bookingsEndpoint = '$baseUrl/api/bookings';

  // HTTP Headers sent with every request
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
  };
}
