import 'package:flutter/foundation.dart';

// Defines a User (student or teacher)
class User {
  final String? id;
  final String? name;
  final String? surname;
  final String? email;
  final bool? isTeacher;

  User(
      {@required this.id,
      @required this.name,
      @required this.surname,
      @required this.email,
      @required this.isTeacher});
}
