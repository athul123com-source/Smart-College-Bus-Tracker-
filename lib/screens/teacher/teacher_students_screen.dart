import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../theme/app_theme.dart';

class TeacherStudentsScreen extends StatelessWidget {
  final String? busId;

  const TeacherStudentsScreen({super.key, this.busId});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('students');
    final filteredQuery =
        busId == null ? query : query.where('busId', isEqualTo: busId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
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
                  'No students found${busId != null ? ' for this bus' : ''}.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final s = students[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppTheme.primaryColor),
                  ),
                ),
                title: Text(s.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.email),
                    if (s.phoneNumber != null && s.phoneNumber!.isNotEmpty)
                      Text(
                        'Phone: ${s.phoneNumber}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.isOnBus ? 'On Bus' : 'Not on Bus',
                      style: TextStyle(
                        fontSize: 12,
                        color: s.isOnBus
                            ? AppTheme.successColor
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

