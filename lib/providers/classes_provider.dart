// Defines a class provider
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';

class ClassesProvider with ChangeNotifier {
  final List<StudentClassesCard>? studentClasses;

  ClassesProvider(this.studentClasses);

  void prepareClassesData(
    AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
    String userId,
  ) {
    for (final element in snapshot.data!.docs) {
      final subjectsOfLab = List<Map<String, dynamic>>.empty(growable: true);
      for (final access in element['access']) {
        final Map<String, dynamic>? accessData =
            access as Map<String, dynamic>?;
        final List<dynamic> userIdsList = accessData!['users'] as List<dynamic>;
        if (userIdsList.contains(userId)) {
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
        studentClasses?.add(studentClassCard);
      }
    }
  }
}
