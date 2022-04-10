import 'package:flutter/foundation.dart';
import 'package:flutter_uni_access/models/user.dart';

// Defines a Laboratory
class Lab {
  final String? id;
  final String? name;
  final String? subjectId;
  final List<User>? users;

  Lab(
      {@required this.id,
      @required this.name,
      @required this.subjectId,
      @required this.users});
}
