// lib/screens/booking_list_screen.dart
// Main screen showing all bookings with pull-to-refresh and FAB

import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_api_service.dart';
import '../widgets/booking_card.dart';
import 'add_booking_screen.dart';
import 'booking_detail_screen.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  // State variables
  List<Booking> _bookings = [];        // List of all bookings
  bool _isLoading = true;              // Show spinner while loading
  String? _errorMessage;               // Show error if fetch fails

  @override
  void initState() {
    super.initState();
    _fetchBookings(); // Load bookings when screen opens
  }

  // Fetch all bookings from the API
  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookings = await BookingApiService.getAllBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Navigate to Add Booking screen
  void _goToAddBooking() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddBookingScreen()),
    );
    // Refresh list if a new booking was created
    if (result == true) {
      _fetchBookings();
    }
  }

  // Navigate to Booking Detail screen
  void _goToDetail(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailScreen(booking: booking),
      ),
    );
    // Refresh list if booking was updated or deleted
    if (result == true) {
      _fetchBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Meeting Room Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // Refresh button in app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchBookings,
          ),
          // Profile button in app bar
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: _buildBody(),
      // Floating Action Button to add a new booking
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddBooking,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
        elevation: 4,
      ),
    );
  }

  Widget _buildBody() {
    // Show loading spinner
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1565C0)),
            SizedBox(height: 16),
            Text('Loading bookings...', style: TextStyle(color: Color(0xFF757575))),
          ],
        ),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Failed to load bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchBookings,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No bookings yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to create\nyour first booking',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF757575)),
            ),
          ],
        ),
      );
    }

    // Show the list of bookings with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: const Color(0xFF1565C0),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80), // space for FAB
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          return BookingCard(
            booking: _bookings[index],
            onTap: () => _goToDetail(_bookings[index]),
          );
        },
      ),
    );
  }
}
