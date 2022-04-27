import 'package:flutter/foundation.dart';

// Defines a subject
class Subject {
  final String? id;
  final String? name;
  final List<String>? labIds;

  Subject({@required this.id, @required this.name, @required this.labIds});
}
