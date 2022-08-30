// ignore_for_file: avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          final List<StudentClassesCard> userClasses =
              prepareClassesData(snapshot, user);

          return ListView.builder(
            itemCount: userClasses.length,
            itemBuilder: (BuildContext context, int index) =>
                DisplayUserClasses(userClasses[index]),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  List<StudentClassesCard> prepareClassesData(
    AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
    UniUser user,
  ) {
    final userClasses = List<StudentClassesCard>.empty(growable: true);

    for (final element in snapshot.data!.docs) {
      final subjectsOfLab = List<Map<String, dynamic>>.empty(growable: true);
      for (final access in element['access']) {
        final Map<String, dynamic>? accessData =
            access as Map<String, dynamic>?;
        final List<dynamic> userIdsList = accessData!['users'] as List<dynamic>;
        if (userIdsList.contains(user.id)) {
          subjectsOfLab.add({
            access!['info']['subjectName'] as String:
                access['info']['date'] as String
          });
        }
      }
      if (subjectsOfLab.isNotEmpty) {
        final studentClassCard = StudentClassesCard(
          lab: element['name'] as String,
          subjects: subjectsOfLab,
        );
        userClasses.add(studentClassCard);
      }
    }

    return userClasses;
  }
}
