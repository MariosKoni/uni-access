import 'package:flutter/foundation.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a Laboratory
class Lab {
  final String? id;
  final String? name;
  final String? subjectId;
  final List<UniUser>? users;

  Lab(
      {@required this.id,
      @required this.name,
      @required this.subjectId,
      @required this.users});
}
