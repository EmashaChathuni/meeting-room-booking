// lib/screens/edit_booking_screen.dart
// Pre-filled form to update an existing booking

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../services/booking_api_service.dart';
import '../services/auth_service.dart';

class EditBookingScreen extends StatefulWidget {
  final Booking booking; // The booking to edit

  const EditBookingScreen({super.key, required this.booking});

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers pre-filled with existing booking data
  late TextEditingController _roomNameController;
  late TextEditingController _bookedByController;
  late TextEditingController _departmentController;
  late TextEditingController _meetingTitleController;
  late TextEditingController _numberOfPeopleController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late String _selectedStatus;

  final List<String> _roomOptions = [
    'Conference Room A',
    'Conference Room B',
    'Boardroom',
    'Meeting Room 1',
    'Meeting Room 2',
    'Training Room',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing booking data
    _roomNameController = TextEditingController(text: widget.booking.roomName);
    _bookedByController = TextEditingController(text: widget.booking.bookedBy);
    _departmentController = TextEditingController(text: widget.booking.department);
    _meetingTitleController = TextEditingController(text: widget.booking.meetingTitle);
    _numberOfPeopleController = TextEditingController(
      text: widget.booking.numberOfPeople.toString(),
    );
    _selectedStatus = widget.booking.status;

    // Parse existing date
    _selectedDate = DateTime.tryParse(widget.booking.meetingDate) ?? DateTime.now();

    // Parse existing start and end times
    _selectedStartTime = _parseTime(widget.booking.startTime);
    _selectedEndTime = _parseTime(widget.booking.endTime);
    
    // Load current user data to auto-fill name and department
    _loadUserData();
  }

  // Load logged-in user data and auto-fill form fields
  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getUser();
      if (user != null && mounted) {
        setState(() {
          _bookedByController.text = user['full_name'] ?? '';
          _departmentController.text = user['department'] ?? '';
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  // Convert "HH:MM:SS" or "HH:MM" string to TimeOfDay
  TimeOfDay _parseTime(String timeStr) {
    try {
      final time = DateFormat.Hms().parse(timeStr);
      return TimeOfDay.fromDateTime(time);
    } catch (e) {
      try {
        final time = DateFormat.Hm().parse(timeStr);
        return TimeOfDay.fromDateTime(time);
      } catch (e) {
        return const TimeOfDay(hour: 9, minute: 0);
      }
    }
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _bookedByController.dispose();
    _departmentController.dispose();
    _meetingTitleController.dispose();
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _selectedStartTime : _selectedEndTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final bookingData = {
        'room_name': _roomNameController.text.trim(),
        'booked_by': _bookedByController.text.trim(),
        'department': _departmentController.text.trim(),
        'meeting_title': _meetingTitleController.text.trim(),
        'meeting_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'start_time': _formatTime(_selectedStartTime),
        'end_time': _formatTime(_selectedEndTime),
        'number_of_people': int.parse(_numberOfPeopleController.text.trim()),
        'status': _selectedStatus,
      };

      await BookingApiService.updateBooking(widget.booking.id, bookingData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking updated successfully! ✅'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return true = updated
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          'Edit Booking',
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
              // ── Room ──
              _label('Room Information'),
              DropdownButtonFormField<String>(
                value: _roomOptions.contains(_roomNameController.text)
                    ? _roomNameController.text
                    : null,
                decoration: _inputDecoration('Room Name', Icons.meeting_room),
                items: _roomOptions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _roomNameController.text = v;
                },
                validator: (v) => v == null ? 'Please select a room' : null,
              ),

              const SizedBox(height: 12),
              _textField(
                controller: _meetingTitleController,
                label: 'Meeting Title',
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              // ── Attendees ──
              _label('Attendee Information'),
              _textField(
                controller: _bookedByController,
                label: 'Your Name',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _departmentController,
                label: 'Department',
                icon: Icons.business,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _numberOfPeopleController,
                label: 'Number of People',
                icon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Must be at least 1';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Schedule ──
              _label('Schedule'),
              InkWell(
                onTap: _pickDate,
                child: _pickerContainer(
                  icon: Icons.calendar_today,
                  label: DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(true),
                      child: _pickerContainer(
                        icon: Icons.access_time,
                        label: _formatTime(_selectedStartTime),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(false),
                      child: _pickerContainer(
                        icon: Icons.access_time_filled,
                        label: _formatTime(_selectedEndTime),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Status ──
              _label('Status'),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _inputDecoration('Status', Icons.info_outline),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedStatus = v);
                },
              ),

              const SizedBox(height: 32),

              // ── Save Button ──
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
                          'Save Changes',
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

  // Helper builders
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1565C0),
          ),
        ),
      );

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
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
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _pickerContainer({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
