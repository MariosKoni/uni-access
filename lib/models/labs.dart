import 'package:cloud_firestore/cloud_firestore.dart';

class Labs {
  final String? id;
  final String? name;
  final List<Map<String, dynamic>>? access;

  Labs({required this.id, required this.name, required this.access});

  factory Labs.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    return Labs(
      id: snapshot.get('id') as String,
      name: snapshot.get('name') as String,
      access: snapshot.get('access') as List<Map<String, dynamic>>,
    );
  }
}
