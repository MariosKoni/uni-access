import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/session.dart';

class SessionOverviewCardWidget extends StatelessWidget {
  const SessionOverviewCardWidget({Key? key, required Session session})
      : _session = session,
        super(key: key);

  final Session _session;

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
        title: Text('Session at ${_session.timestamp}'),
        subtitle: const Text('Tap the arrow to see the details/attendants.'),
        collapsedIconColor: const Color.fromARGB(255, 204, 170, 49),
        childrenPadding: const EdgeInsets.all(8.0),
        children: _session.studentsIds!
            .asMap()
            .entries
            .map(
              (e) => ListTile(
                leading: Text('${e.key + 1}'),
                title: Center(child: Text(e.value)),
                trailing: const Icon(Icons.person),
                onTap: () {},
              ),
            )
            .toList(),
      ),
    );
  }
}
