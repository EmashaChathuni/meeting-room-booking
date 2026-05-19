// lib/screens/add_booking_screen.dart
// Form screen to create a new meeting room booking

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/booking_api_service.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form field controllers
  final _roomNameController = TextEditingController();
  final _bookedByController = TextEditingController();
  final _departmentController = TextEditingController();
  final _meetingTitleController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();

  // Date and time values
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  // Status dropdown value
  String _selectedStatus = 'pending';

  // Predefined room options
  final List<String> _roomOptions = [
    'Conference Room A',
    'Conference Room B',
    'Boardroom',
    'Meeting Room 1',
    'Meeting Room 2',
    'Training Room',
  ];

  @override
  void dispose() {
    // Clean up controllers when screen is removed
    _roomNameController.dispose();
    _bookedByController.dispose();
    _departmentController.dispose();
    _meetingTitleController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  // Open date picker dialog
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Open time picker dialog
  Future<void> _pickTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  // Format TimeOfDay as HH:MM string
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Submit the form to create a booking
  Future<void> _submitForm() async {
    // Check all form fields pass validation
    if (!_formKey.currentState!.validate()) return;

    // Check date and times are selected
    if (_selectedDate == null) {
      _showSnackBar('Please select a meeting date', isError: true);
      return;
    }
    if (_selectedStartTime == null) {
      _showSnackBar('Please select a start time', isError: true);
      return;
    }
    if (_selectedEndTime == null) {
      _showSnackBar('Please select an end time', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Build the booking data map
      final bookingData = {
        'room_name': _roomNameController.text.trim(),
        'booked_by': _bookedByController.text.trim(),
        'department': _departmentController.text.trim(),
        'meeting_title': _meetingTitleController.text.trim(),
        'meeting_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'start_time': _formatTime(_selectedStartTime!),
        'end_time': _formatTime(_selectedEndTime!),
        'number_of_people': int.parse(_numberOfPeopleController.text.trim()),
        'status': _selectedStatus,
      };

      await BookingApiService.createBooking(bookingData);

      _showSnackBar('Booking created successfully! 🎉');
      // Return true to tell the list screen to refresh
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text(
          'Add New Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Room Selection ──
              _SectionLabel(label: 'Room Information'),
              _buildRoomDropdown(),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _meetingTitleController,
                label: 'Meeting Title',
                hint: 'e.g. Sprint Planning',
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Meeting title is required' : null,
              ),

              const SizedBox(height: 20),

              // ── Attendee Information ──
              _SectionLabel(label: 'Attendee Information'),
              _buildTextField(
                controller: _bookedByController,
                label: 'Your Name',
                hint: 'e.g. John Doe',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _departmentController,
                label: 'Department',
                hint: 'e.g. Engineering',
                icon: Icons.business,
                validator: (v) => v!.isEmpty ? 'Department is required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _numberOfPeopleController,
                label: 'Number of People',
                hint: 'e.g. 5',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Number of people is required';
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Must be at least 1';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Schedule ──
              _SectionLabel(label: 'Schedule'),
              _buildDatePicker(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTimePicker(isStart: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimePicker(isStart: false)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Status ──
              _SectionLabel(label: 'Status'),
              _buildStatusDropdown(),

              const SizedBox(height: 32),

              // ── Submit Button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Create Booking',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Form Field Builders ─────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
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
    );
  }

  Widget _buildRoomDropdown() {
    return DropdownButtonFormField<String>(
      value: _roomNameController.text.isEmpty ? null : _roomNameController.text,
      decoration: InputDecoration(
        labelText: 'Room Name',
        prefixIcon: const Icon(Icons.meeting_room, color: Color(0xFF1565C0)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
      ),
      items: _roomOptions.map((room) {
        return DropdownMenuItem(value: room, child: Text(room));
      }).toList(),
      onChanged: (value) {
        if (value != null) _roomNameController.text = value;
      },
      validator: (value) => value == null ? 'Please select a room' : null,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF1565C0)),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? 'Select Meeting Date'
                  : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey : Colors.black87,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({required bool isStart}) {
    final time = isStart ? _selectedStartTime : _selectedEndTime;
    return InkWell(
      onTap: () => _pickTime(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1565C0), size: 20),
            const SizedBox(width: 8),
            Text(
              time == null
                  ? (isStart ? 'Start Time' : 'End Time')
                  : _formatTime(time),
              style: TextStyle(
                color: time == null ? Colors.grey : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.info_outline, color: Color(0xFF1565C0)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedStatus = value);
      },
    );
  }
}

// ─── Section Label Widget ─────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1565C0),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
