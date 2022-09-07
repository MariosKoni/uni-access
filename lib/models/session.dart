import 'package:cloud_firestore/cloud_firestore.dart';

// Defines a session
class Session {
  final String? lab;
  final List<String>? studentsIds;
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
      studentsIds: snapshot.get('students') as List<String>,
      subject: snapshot.get('subject') as String,
      teacher: snapshot.get('teacher') as String,
      timestamp: snapshot.get('timestamp') as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (lab != null) 'lab': lab,
      if (studentsIds != null) 'students': studentsIds,
      if (subject != null) 'subject': subject,
      if (teacher != null) 'teacher': teacher,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}
