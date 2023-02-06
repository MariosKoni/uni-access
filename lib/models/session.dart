// ignore_for_file: avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Defines a session
class Session {
  final String? lab;
  final List<dynamic>? studentsIds;
  final String? subject;
  final String? teacher;
  final String? timestamp;

  Session({
    required this.lab,
    required this.studentsIds,
    required this.subject,
    required this.teacher,
    required this.timestamp,
  });

  factory Session.fromFirestore(
    QueryDocumentSnapshot<Object?> snapshot,
  ) {
    return Session(
      lab: snapshot.get('lab') as String,
      studentsIds: snapshot.get('students') as List<dynamic>,
      subject: snapshot.get('subject') as String,
      teacher: snapshot.get('teacher') as String,
      timestamp: DateFormat('yyy-MM-dd kk:mm').format(
        DateTime.fromMillisecondsSinceEpoch(
          snapshot.get('timestamp').millisecondsSinceEpoch as int,
          isUtc: true,
        ).toLocal(),
      ),
    );
  }
}
