import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shiftmanager/models/scheduleModel.dart';
import 'package:shiftmanager/utility/scheduleRepo.dart';

class AssignSchedulePage extends StatefulWidget {
  final String userId;
  final String userName;

  const AssignSchedulePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AssignSchedulePage> createState() => _AssignSchedulePageState();
}

class _AssignSchedulePageState extends State<AssignSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleRepository _repository = ScheduleRepository();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          "Assign Schedule",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildDatePicker(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTimePicker(isStart: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker(isStart: false)),
                ],
              ),
              const SizedBox(height: 16),

              if (_startTime != null) _buildDetectedShiftInfo(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueGrey.shade100,
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0] : '?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Assigning to:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate == null ? Colors.black12 : Colors.blue,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? "Select Date"
                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({required bool isStart}) {
    final time = isStart ? _startTime : _endTime;
    return InkWell(
      onTap: () => _pickTime(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: time == null ? Colors.black12 : Colors.blue,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStart ? "Start Time" : "End Time",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time == null ? "-- : --" : time.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedShiftInfo() {
    final shift = _getShiftType(_startTime!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            "Detected Shift: $shift",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : _submitSchedule,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Confirm Assignment",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _getShiftType(TimeOfDay start) {
    final hour = start.hour;

    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else {
      return 'Night';
    }
  }

  Future<void> _submitSchedule() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final double startVal = _startTime!.hour + (_startTime!.minute / 60.0);
    final double endVal = _endTime!.hour + (_endTime!.minute / 60.0);

    if (endVal < startVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Time: End time cannot be before Start time."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (startVal == endVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Start and End time cannot be the same.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final DateTime endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      String autoDetectedShift = _getShiftType(_startTime!);

      final newSchedule = ScheduleModel(
        id: mongo.ObjectId(),
        userId: widget.userId,
        userName: widget.userName,
        startTime: startDateTime,
        endTime: endDateTime,
        shiftType: autoDetectedShift,
        createdBy: mongo.ObjectId(),
        createdAt: DateTime.now(),
      );

      final success = await _repository.assignSchedule(newSchedule);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$autoDetectedShift Shift assigned to ${widget.userName}!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed: This time overlaps with an existing shift."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
