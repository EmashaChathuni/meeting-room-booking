// lib/services/auth_service.dart
// Handles user authentication and token management

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  // SharedPreferences keys
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  // ─────────────────────────────────────────────────
  // POST /api/auth/signup  →  Register a new user
  // ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
    required String department,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': ApiConstants.apiKey,
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
          'department': department,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['token'] != null) {
          // Save token and user data locally
          await _saveToken(data['token']);
          if (data['user'] != null) {
            await _saveUser(data['user']);
          }
          
          return {
            'success': true,
            'message': data['message'] ?? 'Signup successful',
            'token': data['token'],
            'user': data['user'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Signup failed',
          };
        }
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Signup failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ─────────────────────────────────────────────────
  // POST /api/auth/login  →  Authenticate user
  // ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': ApiConstants.apiKey,
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['success'] == true && data['token'] != null) {
          // Save token and user data locally
          await _saveToken(data['token']);
          if (data['user'] != null) {
            await _saveUser(data['user']);
          }
          
          return {
            'success': true,
            'message': data['message'] ?? 'Login successful',
            'token': data['token'],
            'user': data['user'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return {
          'success': false,
          'message': body['message'] ?? 'Invalid email or password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ─────────────────────────────────────────────────
  // Get stored JWT token from device
  // ─────────────────────────────────────────────────
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  // Check if user is already logged in
  // ─────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─────────────────────────────────────────────────
  // Get stored user data from device
  // ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  // Clear token and logout user
  // ─────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // ─────────────────────────────────────────────────
  // PRIVATE: Save JWT token locally
  // ─────────────────────────────────────────────────
  static Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      // Handle error silently
    }
  }

  // ─────────────────────────────────────────────────
  // PRIVATE: Save user data locally
  // ─────────────────────────────────────────────────
  static Future<void> _saveUser(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user));
    } catch (e) {
      // Handle error silently
    }
  }
}
