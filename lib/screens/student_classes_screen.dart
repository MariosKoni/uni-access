import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/lab.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';
import 'package:flutter_uni_access/models/subject.dart';
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
    return FutureBuilder(
        future: Future.wait([
          labs.where('users', arrayContains: widget.user.id).get(),
          subjects.where('users', arrayContains: widget.user.id).get()
        ]),
        builder: (BuildContext context,
            AsyncSnapshot<List<QuerySnapshot<Object?>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.done) {
            final _userLabs = List<Lab>.empty(growable: true);
            final _userSubjects = List<Subject>.empty(growable: true);
            final _userClasses = List<StudentClassesCard>.empty(growable: true);

            for (var element in snapshot.data![0].docs) {
              final _lab = Lab(
                  id: element['id'],
                  name: element['name'],
                  subjectId: List<String>.from(element['subjectId']),
                  userIds: List<String>.from(element['users']));
              _userLabs.add(_lab);
            }

            for (var element in snapshot.data![1].docs) {
              final _subject = Subject(
                  id: element['id'],
                  name: element['name'],
                  labIds: List<String>.from(element['labs']));
              _userSubjects.add(_subject);
            }

            final _subjectsOfLab = List<String>.empty(growable: true);
            for (var lab in _userLabs) {
              for (var subject in _userSubjects) {
                if (lab.subjectId!.contains(subject.id)) {
                  _subjectsOfLab.add(subject.name!);
                }
              }
              final _studentClassCard =
                  StudentClassesCard(lab: lab.name, subjects: lab.subjectId);
              _userClasses.add(_studentClassCard);
            }

            return DisplayStudentClasses(_userClasses);
          }
          return const CircularProgressIndicator();
        });
  }
}
