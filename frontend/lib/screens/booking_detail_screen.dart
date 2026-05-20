// lib/screens/booking_detail_screen.dart
// Shows full details of a single booking with Edit and Delete options

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../services/booking_api_service.dart';
import 'edit_booking_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  // Show confirmation dialog before deleting
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Booking'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this booking?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _deleteBooking(context);
    }
  }

  // Call the API to delete and show result
  Future<void> _deleteBooking(BuildContext context) async {
    try {
      await BookingApiService.deleteBooking(booking.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Return true so the list screen refreshes
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Navigate to Edit screen
  void _goToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBookingScreen(booking: booking),
      ),
    );
    if (result == true && context.mounted) {
      // Return true to list screen to trigger a refresh
      Navigator.pop(context, true);
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
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Booking',
            onPressed: () => _goToEdit(context),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Booking',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card: Room + Status ──
            _HeaderCard(booking: booking),

            const SizedBox(height: 16),

            // ── Meeting Info ──
            _DetailCard(
              title: 'Meeting Information',
              icon: Icons.info_outline,
              children: [
                _DetailRow(label: 'Meeting Title', value: booking.meetingTitle),
                _DetailRow(label: 'Room', value: booking.roomName),
                _DetailRow(label: 'Status', value: booking.status.toUpperCase()),
              ],
            ),

            const SizedBox(height: 12),

            // ── Attendee Info ──
            _DetailCard(
              title: 'Attendee Information',
              icon: Icons.person_outline,
              children: [
                _DetailRow(label: 'Booked By', value: booking.bookedBy),
                _DetailRow(label: 'Department', value: booking.department),
                _DetailRow(
                  label: 'Number of People',
                  value: '${booking.numberOfPeople} person(s)',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Schedule ──
            _DetailCard(
              title: 'Schedule',
              icon: Icons.schedule,
              children: [
                _DetailRow(label: 'Date', value: booking.meetingDate),
                _DetailRow(label: 'Start Time', value: booking.startTime),
                _DetailRow(label: 'End Time', value: booking.endTime),
                _DetailRow(
                  label: 'Duration',
                  value: _calculateDuration(booking.startTime, booking.endTime),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Meta ──
            _DetailCard(
              title: 'Record Info',
              icon: Icons.receipt_long_outlined,
              children: [
                _DetailRow(
                  label: 'Booking ID',
                  value: booking.id.toString(),
                  isSmall: true,
                ),
                _DetailRow(
                  label: 'Created At',
                  value: booking.createdAt.toLocal().toString().substring(0, 16),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Bottom Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _goToEdit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Calculate duration between start and end times
  String _calculateDuration(String start, String end) {
    try {
      final startTime = DateFormat.Hms().parse(start);
      final endTime = DateFormat.Hms().parse(end);
      final diff = endTime.difference(startTime);

      if (diff.isNegative || diff.inMinutes == 0) return 'N/A';

      final hours = diff.inHours;
      final mins = diff.inMinutes % 60;

      if (hours == 0) return '$mins minutes';
      if (mins == 0) return '$hours hour(s)';
      return '$hours hour(s) $mins minutes';
    } catch (_) {
      // Fallback for HH:mm format
      try {
        final startTime = DateFormat.Hm().parse(start);
        final endTime = DateFormat.Hm().parse(end);
        final diff = endTime.difference(startTime);

        if (diff.isNegative || diff.inMinutes == 0) return 'N/A';

        final hours = diff.inHours;
        final mins = diff.inMinutes % 60;

        if (hours == 0) return '$mins minutes';
        if (mins == 0) return '$hours hour(s)';
        return '$hours hour(s) $mins minutes';
      } catch (e) {
        return 'N/A';
      }
    }
  }
}

// ─── Header Card ──────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final Booking booking;
  const _HeaderCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
        statusColor = const Color(0xFFC62828);
        break;
      default:
        statusColor = const Color(0xFFF57F17);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.meeting_room, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                booking.roomName,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            booking.meetingTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text(
                booking.meetingDate,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.white60, size: 16),
              const SizedBox(width: 6),
              Text(
                '${booking.startTime} – ${booking.endTime}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Detail Section Card ───────────────────────────────────
class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1565C0), size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ─── Single Detail Row ─────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSmall;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Color(0xFF9E9E9E))),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmall ? 11 : 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212121),
                fontFamily: isSmall ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
