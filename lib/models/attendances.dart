import 'package:cloud_firestore/cloud_firestore.dart';

class Attendances {
  final String? subject;
  final Map<String, dynamic>? attendants;

  Attendances({required this.subject, required this.attendants});

  factory Attendances.fromFirestore(
    DocumentSnapshot<Object?> snapshot,
  ) {
    return Attendances(
      subject: snapshot.get('subject') as String,
      attendants: snapshot.get('attendants') as Map<String, dynamic>,
    );
  }
}
