// ignore_for_file: avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';
import 'package:flutter_uni_access/providers/classes_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/display_user_classes_widget.dart';
import 'package:provider/provider.dart';

class UserClassesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');
    final String userId =
        Provider.of<UserProvider>(context, listen: false).user!.id!;
    final studentClassesLength =
        Provider.of<ClassesProvider>(context, listen: false)
            .studentClasses
            ?.length;
    List<StudentClassesCard>? userClasses =
        Provider.of<ClassesProvider>(context, listen: false).studentClasses;

    return studentClassesLength == 0
        ? FutureBuilder(
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
                Provider.of<ClassesProvider>(context, listen: false)
                    .prepareClassesData(snapshot, userId);
                userClasses =
                    Provider.of<ClassesProvider>(context, listen: false)
                        .studentClasses;

                return ListView.builder(
                  itemCount: userClasses?.length,
                  itemBuilder: (BuildContext context, int index) =>
                      DisplayUserClasses(userClasses![index]),
                );
              }
              return const CircularProgressIndicator();
            },
          )
        : ListView.builder(
            itemCount: userClasses?.length,
            itemBuilder: (BuildContext context, int index) =>
                DisplayUserClasses(userClasses![index]),
          );
  }
}
