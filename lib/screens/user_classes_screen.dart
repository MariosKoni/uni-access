import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_uni_access/models/lab.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';
import 'package:flutter_uni_access/models/subject.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/widgets/display_student_classes.dart';

class UserClassesScreen extends StatelessWidget {
  final UniUser user;

  UserClassesScreen(this.user);

  CollectionReference labs = FirebaseFirestore.instance.collection('labs');
  CollectionReference subjects =
      FirebaseFirestore.instance.collection('subjects');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          labs.where('users', arrayContains: user.id).get(),
          subjects.where('users', arrayContains: user.id).get()
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

            for (var accessLab in user.access!) {
              final _subjectsOfLab =
                  List<Map<String, String>>.empty(growable: true);
              final _lab = _userLabs
                  .firstWhere((element) => element.id == accessLab.keys.first);
              for (var val in accessLab.values) {
                for (var subject in val) {
                  if (_lab.subjectId!.contains(subject.keys.first)) {
                    final _subjectName = _userSubjects
                        .firstWhere(
                            (element) => element.id == subject.keys.first)
                        .name;
                    _subjectsOfLab.add({_subjectName!: subject.values.first});
                  }
                }
              }
              final _studentClassCard =
                  StudentClassesCard(lab: _lab.name, subjects: _subjectsOfLab);
              _userClasses.add(_studentClassCard);
            }

            return ListView.builder(
                itemCount: _userClasses.length,
                itemBuilder: (BuildContext context, int index) =>
                    DisplayStudentClasses(_userClasses[index]));
          }
          return const CircularProgressIndicator();
        });
  }
}
