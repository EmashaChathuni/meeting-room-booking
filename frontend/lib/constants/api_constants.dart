
class ApiConstants {
 
  // Choreo production backend
  static const String baseUrl = 'https://66393585-7f58-4d9a-86f6-1fc090093011-dev.e1-eu-north-azure.choreoapis.dev/default/backend/v1.0';

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

