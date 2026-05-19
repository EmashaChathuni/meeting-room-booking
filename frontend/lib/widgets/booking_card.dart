// lib/widgets/booking_card.dart
// A reusable card widget to display a booking summary in a list

import 'package:flutter/material.dart';
import '../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap; // Called when card is tapped (go to detail screen)

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Room name + Status badge ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Room name with icon
                  Row(
                    children: [
                      const Icon(Icons.meeting_room, color: Color(0xFF1565C0), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        booking.roomName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  // Status chip
                  _StatusBadge(status: booking.status),
                ],
              ),

              const SizedBox(height: 8),

              // ── Meeting Title ──
              Text(
                booking.meetingTitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Info Row: Date + Time + People ──
              Row(
                children: [
                  // Date
                  _InfoChip(
                    icon: Icons.calendar_today,
                    label: booking.meetingDate,
                  ),
                  const SizedBox(width: 12),
                  // Time range
                  _InfoChip(
                    icon: Icons.access_time,
                    label: '${booking.startTime} - ${booking.endTime}',
                  ),
                  const Spacer(),
                  // People count
                  _InfoChip(
                    icon: Icons.people,
                    label: '${booking.numberOfPeople}',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Booked by + Department ──
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Color(0xFF757575)),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.bookedBy} · ${booking.department}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status Badge Widget ───────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    // Choose color based on status
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      default: // pending
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57F17);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Info Chip Widget ─────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1565C0)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
        ),
      ],
    );
  }
}
