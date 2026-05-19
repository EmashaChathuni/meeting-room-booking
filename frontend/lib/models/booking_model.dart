// lib/models/booking_model.dart
// Dart data class that matches the API booking JSON structure

class Booking {
  // All the fields matching our database table
  final String id;
  final String roomName;
  final String bookedBy;
  final String department;
  final String meetingTitle;
  final String meetingDate;   // Format: YYYY-MM-DD
  final String startTime;     // Format: HH:MM
  final String endTime;       // Format: HH:MM
  final int numberOfPeople;
  final String status;        // pending, confirmed, cancelled
  final DateTime createdAt;

  // Constructor
  Booking({
    required this.id,
    required this.roomName,
    required this.bookedBy,
    required this.department,
    required this.meetingTitle,
    required this.meetingDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfPeople,
    required this.status,
    required this.createdAt,
  });

  // Create a Booking object from a JSON map (from API response)
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      roomName: json['room_name'] ?? '',
      bookedBy: json['booked_by'] ?? '',
      department: json['department'] ?? '',
      meetingTitle: json['meeting_title'] ?? '',
      meetingDate: _parseDate(json['meeting_date']),
      startTime: _parseTime(json['start_time']),
      endTime: _parseTime(json['end_time']),
      numberOfPeople: json['number_of_people'] ?? 1,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Convert Booking object to JSON map (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'room_name': roomName,
      'booked_by': bookedBy,
      'department': department,
      'meeting_title': meetingTitle,
      'meeting_date': meetingDate,
      'start_time': startTime,
      'end_time': endTime,
      'number_of_people': numberOfPeople,
      'status': status,
    };
  }

  // Helper: parse date string, handles various formats from Postgres
  static String _parseDate(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    // If it contains a 'T' it's a datetime, extract just the date part
    if (str.contains('T')) return str.split('T')[0];
    return str.length >= 10 ? str.substring(0, 10) : str;
  }

  // Helper: parse time string, handles various formats from Postgres
  static String _parseTime(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    // Postgres TIME includes seconds (HH:MM:SS), we only want HH:MM
    if (str.length >= 5) return str.substring(0, 5);
    return str;
  }
}
