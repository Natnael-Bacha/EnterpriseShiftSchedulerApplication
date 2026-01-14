import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shiftmanager/models/scheduleModel.dart';
import 'package:shiftmanager/utility/scheduleRepo.dart';

class MyShiftsPage extends StatefulWidget {
  const MyShiftsPage({super.key});

  @override
  State<MyShiftsPage> createState() => _MyShiftsPageState();
}

class _MyShiftsPageState extends State<MyShiftsPage> {
  final ScheduleRepository _repository = ScheduleRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late Future<List<ScheduleModel>> _shiftsFuture;

  @override
  void initState() {
    super.initState();

    final user = _auth.currentUser;

    if (user == null) {
      _shiftsFuture = Future.value([]);
    } else {
      _shiftsFuture = _repository.getSchedulesForUser(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text(
          "My Shifts",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<ScheduleModel>>(
        future: _shiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load shifts"));
          }

          final shifts = snapshot.data ?? [];

          if (shifts.isEmpty) {
            return const Center(
              child: Text(
                "No shifts assigned yet",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shifts.length,
            itemBuilder: (context, index) {
              return _ShiftCard(schedule: shifts[index]);
            },
          );
        },
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final ScheduleModel schedule;

  const _ShiftCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');

    final start = schedule.startTime;
    final end = schedule.endTime;

    final bool isOvernight = end.day != start.day;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(start),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                "${timeFormat.format(start)} → ${timeFormat.format(end)}"
                "${isOvernight ? " (Next day)" : ""}",
              ),
            ],
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(schedule.shiftType),
            backgroundColor: _chipColor(schedule.shiftType),
          ),
        ],
      ),
    );
  }

  Color _chipColor(String type) {
    switch (type) {
      case 'Morning':
        return Colors.lightBlue.shade100;
      case 'Afternoon':
        return Colors.orange.shade100;
      case 'Night':
        return Colors.indigo.shade100;
      case 'On-Call':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}
