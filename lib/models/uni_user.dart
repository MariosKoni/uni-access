import 'package:cloud_firestore/cloud_firestore.dart';

// Defines a User (student or teacher)
class UniUser {
  final String? id;
  final String? name;
  final String? surname;
  final String? email;
  final bool? isTeacher;
  final String? image;
  late final bool isAuthorized;
  late final int? attendaces;

  UniUser({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.isTeacher,
    required this.image,
  });

  factory UniUser.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    return UniUser(
      id: snapshot.get('id') as String,
      name: snapshot.get('name') as String,
      surname: snapshot.get('surname') as String,
      email: snapshot.get('email') as String,
      isTeacher: snapshot.get('isTeacher') as bool,
      image: snapshot.get('image') as String,
    );
  }
}
