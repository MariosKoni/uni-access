import 'package:cloud_firestore/cloud_firestore.dart';

class Labs {
  final String? name;
  final List<dynamic>? access;

  Labs({required this.name, required this.access});

  factory Labs.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    return Labs(
      name: snapshot.get('name') as String,
      access: snapshot.get('access') as List<dynamic>,
    );
  }
}
