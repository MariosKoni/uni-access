import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/lab.dart';

class DisplayStudentClasses extends StatelessWidget {
  final List<Lab> labs;

  DisplayStudentClasses(this.labs);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: labs.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
            height: 50,
            color: Colors.grey,
            child: Center(
              child: Text(labs[index].name!),
            ));
      },
    );
  }
}
