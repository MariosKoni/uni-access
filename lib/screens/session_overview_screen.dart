// ignore_for_file: avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/session.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/session_overview_widget.dart';
import 'package:provider/provider.dart';

class SessionOverviewScreen extends StatelessWidget {
  SessionOverviewScreen({Key? key}) : super(key: key);

  // Get a reference to the sessions collection as a stream
  late final Stream<QuerySnapshot> _sessionOverviewStream =
      FirebaseFirestore.instance.collection('sessions').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _sessionOverviewStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs == null) {
          return const Center(child: Text('Data is null.'));
        }

        final sessions = List<Session>.empty(growable: true);

        for (final element in snapshot.data!.docs) {
          final session = Session.fromFirestore(element);
          // If the session's teacher is not the current user, ingore it
          if (session.teacher?.compareTo(
                Provider.of<UserProvider>(context, listen: false).user!.id!,
              ) !=
              0) {
            continue;
          }

          final studentsIds = List<String>.empty(growable: true);
          for (final id in session.studentsIds!) {
            studentsIds.add(id as String);
          }

          sessions.add(session);
        }

        Provider.of<SessionOverviewProvider>(context, listen: false).sessions =
            sessions;
        Provider.of<SessionOverviewProvider>(context, listen: false)
            .allSessions = sessions;
        Provider.of<SessionOverviewProvider>(context, listen: false)
            .populateLists();

        // TODO: Maybe more efficient?
        return const SessionOverviewsWidget();
      },
    );
  }
}
