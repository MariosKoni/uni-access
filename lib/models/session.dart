// Defines a session
import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String? lab;
  final List<String>? studentsIds;
  final String? subject;
  final String? teacher;
  final DateTime? timestamp;

  Session({
    required this.lab,
    required this.studentsIds,
    required this.subject,
    required this.teacher,
    required this.timestamp,
  });
}
