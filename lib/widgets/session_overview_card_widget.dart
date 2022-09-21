// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/session.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/alert_student_profile_widget.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class SessionOverviewCardWidget extends StatefulWidget {
  const SessionOverviewCardWidget({Key? key, required Session session})
      : _session = session,
        super(key: key);

  final Session _session;

  @override
  State<SessionOverviewCardWidget> createState() =>
      _SessionOverviewCardWidgetState();
}

class _SessionOverviewCardWidgetState extends State<SessionOverviewCardWidget> {
  final GlobalKey _one = GlobalKey();

  Future<void> _showStudentProfileAlertDialog(
    BuildContext context,
    UniUser user,
  ) async {
    Provider.of<SessionProvider>(context, listen: false).selectedSubject =
        widget._session.subject;
    await Provider.of<SessionProvider>(context, listen: false)
        .findStudentAttendances(user.id!, context);
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertStudentProfileWidget(user: user),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase([_one]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: _one,
      description: 'Tap for more details',
      child: Card(
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
            '${widget._session.lab} - ${widget._session.subject!}',
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Saved at ${widget._session.timestamp}'),
          collapsedIconColor: const Color.fromARGB(255, 204, 170, 49),
          childrenPadding: const EdgeInsets.all(8.0),
          children: widget._session.studentsIds!
              .asMap()
              .entries
              .map(
                (studentId) => ListTile(
                  leading: Text('${studentId.key + 1}'),
                  title: Center(child: Text(studentId.value as String)),
                  trailing: const Icon(Icons.person),
                  onTap: () async {
                    final user =
                        await Provider.of<UserProvider>(context, listen: false)
                            .getUserFromId(studentId.value as String, context);

                    return _showStudentProfileAlertDialog(context, user);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
