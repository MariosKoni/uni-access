import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/display_user_classes_widget.dart';
import 'package:provider/provider.dart';

class UserClassesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');
    final UniUser user =
        Provider.of<UserProvider>(context, listen: false).user!;

    return FutureBuilder(
        future: labs.get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.done) {
            List<StudentClassesCard> _userClasses =
                prepareClassesData(snapshot, user);

            return ListView.builder(
                itemCount: _userClasses.length,
                itemBuilder: (BuildContext context, int index) =>
                    DisplayUserClasses(_userClasses[index]));
          }
          return const CircularProgressIndicator();
        });
  }

  List<StudentClassesCard> prepareClassesData(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot, final UniUser user) {
    final _userClasses = List<StudentClassesCard>.empty(growable: true);

    for (var _element in snapshot.data!.docs) {
      final _subjectsOfLab = List<Map<String, dynamic>>.empty(growable: true);
      for (var _access in _element['access']) {
        if (_access['users'].contains(user.id)) {
          _subjectsOfLab
              .add({_access['info']['subjectName']: _access['info']['date']});
        }
      }
      if (_subjectsOfLab.isNotEmpty) {
        final _studentClassCard =
            StudentClassesCard(lab: _element['name'], subjects: _subjectsOfLab);
        _userClasses.add(_studentClassCard);
      }
    }

    return _userClasses;
  }
}
