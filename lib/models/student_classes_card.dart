import 'package:flutter/foundation.dart';

// Defines the structure of the card to appear in the classes screen
class StudentClassesCard {
  final String? lab;
  final List<Map<String, dynamic>>? subjects;

  StudentClassesCard({@required this.lab, @required this.subjects});
}
