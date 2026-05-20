// lib/services/booking_api_service.dart
// Handles all HTTP communication with the backend API

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/booking_model.dart';
import 'auth_service.dart';

class BookingApiService {
  // ─────────────────────────────────────────────────
  // PRIVATE: Build headers with Bearer token
  // ─────────────────────────────────────────────────
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'X-API-Key': ApiConstants.apiKey,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────
  // GET /api/bookings  →  Fetch all bookings
  // ─────────────────────────────────────────────────
  static Future<List<Booking>> getAllBookings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.bookingsEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((json) => Booking.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load bookings: ${response.body}');
    }
  }

  // ─────────────────────────────────────────────────
  // GET /api/bookings/:id  →  Fetch a single booking
  // ─────────────────────────────────────────────────
  static Future<Booking> getBookingById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.bookingsEndpoint}/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Booking.fromJson(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
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
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(ApiConstants.bookingsEndpoint),
      headers: headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Booking.fromJson(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      final Map<String, dynamic> body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to create booking');
    }
  }

  // ─────────────────────────────────────────────────
  // PUT /api/bookings/:id  →  Update a booking
  // ─────────────────────────────────────────────────
  static Future<Booking> updateBooking(int id, Map<String, dynamic> bookingData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiConstants.bookingsEndpoint}/$id'),
      headers: headers,
      body: jsonEncode(bookingData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Booking.fromJson(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
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
  static Future<void> deleteBooking(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.bookingsEndpoint}/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Success
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Booking not found');
    } else {
      throw Exception('Failed to delete booking: ${response.body}');
    }
  }
}
