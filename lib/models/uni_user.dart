import 'package:flutter/foundation.dart';

// Defines a User (student or teacher)
class UniUser {
  final String? id;
  final String? name;
  final String? surname;
  final String? email;
  final bool? isTeacher;
  final String? image;

  UniUser(
      {@required this.id,
      @required this.name,
      @required this.surname,
      @required this.email,
      @required this.isTeacher,
      @required this.image});
}
