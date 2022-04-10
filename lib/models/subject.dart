import 'package:flutter/foundation.dart';

import 'package:flutter_uni_access/models/lab.dart';

// Defines a subject
class Subject {
  final String? id;
  final String? name;
  final List<Lab>? labs;

  Subject({@required this.id, @required this.name, @required this.labs});
}
