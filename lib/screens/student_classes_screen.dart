import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/lab.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/widgets/display_student_classes.dart';

class StudentClassesScreen extends StatefulWidget {
  final UniUser user;

  StudentClassesScreen(this.user);

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  CollectionReference labs = FirebaseFirestore.instance.collection('labs');
  CollectionReference subjects =
      FirebaseFirestore.instance.collection('subjects');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: labs.where('users', arrayContains: widget.user.id).get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final _userLabs = List<Lab>.empty(growable: true);

            for (var element in (snapshot.data as QuerySnapshot).docs) {
              final _lab = Lab(
                  id: element['id'],
                  name: element['name'],
                  subjectId: element['subjectId'],
                  users: List<String>.from(element['users']));
              _userLabs.add(_lab);
            }
            return DisplayStudentClasses(_userLabs);
          }
          return const Text('Hang...');
        });
  }
}
