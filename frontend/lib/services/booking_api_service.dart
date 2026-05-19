// lib/services/booking_api_service.dart
// Handles all HTTP communication with the backend API

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/booking_model.dart';

class BookingApiService {
  // ─────────────────────────────────────────────────
  // GET /api/bookings  →  Fetch all bookings
  // ─────────────────────────────────────────────────
  static Future<List<Booking>> getAllBookings() async {
    final response = await http.get(
      Uri.parse(ApiConstants.bookingsEndpoint),
      headers: ApiConstants.headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings: ${response.body}');
    }
  }

  // ─────────────────────────────────────────────────
  // GET /api/bookings/:id  →  Fetch a single booking
  // ─────────────────────────────────────────────────
  static Future<Booking> getBookingById(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.bookingsEndpoint}/$id'),
      headers: ApiConstants.headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Booking.fromJson(body['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Booking not found');
    } else {
      throw Exception('Failed to load booking: ${response.body}');
    }
  }

  // ─────────────────────────────────────────────────
  // POST /api/bookings  →  Create a new booking
  // ─────────────────────────────────────────────────
  static Future<Booking> createBooking(Map<String, dynamic> bookingData) async {
    final response = await http.post(
      Uri.parse(ApiConstants.bookingsEndpoint),
      headers: ApiConstants.headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Booking.fromJson(body['data']);
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to create booking');
    }
  }

  // ─────────────────────────────────────────────────
  // PUT /api/bookings/:id  →  Update a booking
  // ─────────────────────────────────────────────────
  static Future<Booking> updateBooking(String id, Map<String, dynamic> bookingData) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.bookingsEndpoint}/$id'),
      headers: ApiConstants.headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Booking.fromJson(body['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Booking not found');
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update booking');
    }
  }

  // ─────────────────────────────────────────────────
  // DELETE /api/bookings/:id  →  Delete a booking
  // ─────────────────────────────────────────────────
  static Future<void> deleteBooking(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.bookingsEndpoint}/$id'),
      headers: ApiConstants.headers,
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception('Booking not found');
      }
      throw Exception('Failed to delete booking: ${response.body}');
    }
  }
}
