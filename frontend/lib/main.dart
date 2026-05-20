// lib/main.dart
// App entry point - configures theme, routing, and initial route

import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/booking_list_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const MeetingRoomBookingApp());
}

class MeetingRoomBookingApp extends StatelessWidget {
  const MeetingRoomBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title (shown in task switcher)
      title: 'Office Meeting Room Booking',

      // Hide the debug banner
      debugShowCheckedModeBanner: false,

      // ── App Theme ──────────────────────────────────────
      theme: ThemeData(
        // Use Material 3 design
        useMaterial3: true,

        // Primary color scheme (deep blue office style)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1565C0),
          secondary: const Color(0xFF0288D1),
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Input field decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),

        // ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Scaffold background
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),

      // ── Routing ────────────────────────────────────────
      // Start with splash screen to check authentication status
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/bookings': (context) => const BookingListScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
