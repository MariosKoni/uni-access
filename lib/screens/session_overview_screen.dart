// ignore_for_file: avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/session.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/session_overview_card_widget.dart';
import 'package:provider/provider.dart';

class SessionOverviewScreen extends StatelessWidget {
  const SessionOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference sessions =
        FirebaseFirestore.instance.collection('sessions');

    return FutureBuilder(
      future: sessions
          .where(
            'teacher',
            isEqualTo:
                Provider.of<UserProvider>(context, listen: false).user?.id,
          )
          .orderBy('timestamp')
          .get(),
      builder: (
        _,
        AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
      ) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data?.docs == null) {
            return const Center(child: Text('Data is null.'));
          }

          final List<Session> sessions = List<Session>.empty(growable: true);

          for (final element in snapshot.data!.docs) {
            final List<String> studentsIds = List<String>.empty(growable: true);
            for (final id in element['students']) {
              studentsIds.add(id as String);
            }

            final session = Session(
              lab: element['lab'] as String,
              studentsIds: studentsIds,
              subject: element['subject'] as String,
              teacher: element['teacher'] as String,
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                element['timestamp'].millisecondsSinceEpoch as int,
              ),
            );

            sessions.add(session);
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (_, int index) =>
                SessionOverviewCardWidget(session: sessions[index]),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
