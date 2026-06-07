// lib/constants/api_constants.dart
// Central place to store all API configuration values

class ApiConstants {
  // ============================================================
  // IMPORTANT: Change this to your backend server address:
  // 
  // - Local development: http://localhost:8081
  // - Choreo deployment: https://6639358-7f58-4d9a-86f6-...choreoapis.dev
  // - For Android emulator: http://10.0.2.2:8081
  // - For physical device: http://YOUR_COMPUTER_IP:8081
  // ============================================================
  static const String baseUrl = 'https://6639358-7f58-4d9a-86f6-ffc090093011-dev1-eu-north-azure.choreoapis.dev';  // Replace with your Choreo URL

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
