import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

import 'package:flutter_uni_access/widgets/display_student_info.dart';

class StudentInfoScreen extends StatefulWidget {
  final UniUser user;

  StudentInfoScreen(this.user);

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return DisplayStudentInfo(widget.user);
  }
}
