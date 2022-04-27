import 'package:flutter/foundation.dart';

// Defines a Laboratory
class Lab {
  final String? id;
  final String? name;
  final String? subjectId;
  final List<String>? userIds;

  Lab(
      {@required this.id,
      @required this.name,
      @required this.subjectId,
      @required this.userIds});
}
