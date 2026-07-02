import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/student_model.dart';
import '../../theme/app_theme.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  final String? busId;

  const TeacherAttendanceScreen({super.key, this.busId});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  final Map<String, bool> _present = {};

  @override
  Widget build(BuildContext context) {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final query = FirebaseFirestore.instance.collection('students');
    final filteredQuery = widget.busId == null
        ? query
        : query.where('busId', isEqualTo: widget.busId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: filteredQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final students = docs
              .map(
                (d) => StudentModel.fromMap({
                  'id': d.id,
                  ...d.data(),
                }),
              )
              .toList();

          if (students.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No students found${widget.busId != null ? ' for this bus' : ''}.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: $todayKey',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Present: ${_present.values.where((v) => v).length}'
                      ' / ${students.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final key = '${s.id}-$todayKey';
                    final isPresent = _present[key] ?? false;

                    return CheckboxListTile(
                      value: isPresent,
                      onChanged: (value) {
                        setState(() {
                          _present[key] = value ?? false;
                        });
                      },
                      title: Text(s.name),
                      subtitle: Text(s.email),
                      secondary: Icon(
                        isPresent
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isPresent
                            ? AppTheme.successColor
                            : AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

