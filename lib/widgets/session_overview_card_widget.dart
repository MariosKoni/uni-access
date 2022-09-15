// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/session.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/alert_student_profile_widget.dart';
import 'package:provider/provider.dart';

class SessionOverviewCardWidget extends StatelessWidget {
  const SessionOverviewCardWidget({Key? key, required Session session})
      : _session = session,
        super(key: key);

  final Session _session;

  Future<void> _showStudentProfileAlertDialog(
    BuildContext context,
    UniUser user,
  ) async {
    Provider.of<SessionProvider>(context, listen: false).selectedSubject =
        _session.subject;
    await Provider.of<SessionProvider>(context, listen: false)
        .findStudentAttendances(user.id!, context);
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertStudentProfileWidget(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      color: Theme.of(context).colorScheme.secondary,
      child: ExpansionTile(
        leading: const Icon(Icons.list_alt_rounded),
        title: Text(
          '${_session.lab} - ${_session.subject!}',
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Saved at ${_session.timestamp}'),
        collapsedIconColor: const Color.fromARGB(255, 204, 170, 49),
        childrenPadding: const EdgeInsets.all(8.0),
        children: _session.studentsIds!
            .asMap()
            .entries
            .map(
              (e) => ListTile(
                leading: Text('${e.key + 1}'),
                title: Center(child: Text(e.value as String)),
                trailing: const Icon(Icons.person),
                onTap: () async {
                  final UniUser user =
                      await Provider.of<UserProvider>(context, listen: false)
                          .getUserFromId(e.value as String, context);

                  return _showStudentProfileAlertDialog(context, user);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
