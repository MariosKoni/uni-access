import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/widgets/formOptionWidget.dart';
import 'package:provider/provider.dart';

class NewSessionDialogWidget extends StatelessWidget {
  const NewSessionDialogWidget({Key? key}) : super(key: key);

  void _startSession(BuildContext context) {
    // _showAttendence = true;

    Provider.of<SessionProvider>(context, listen: false).startedScanning = true;
    Provider.of<SessionProvider>(context, listen: false).canSave = false;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0))),
        title: Text('Register a new session',
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            FormOptionWidget(
              key: const Key('lab'),
              option: Provider.of<SessionProvider>(context, listen: false).labs,
              titleOption: 'Lab',
            ),
            FormOptionWidget(
              key: const Key('subject'),
              option: Provider.of<SessionProvider>(context, listen: false)
                  .stringyfiedSubjects,
              titleOption: 'Subject',
            ),
            const SizedBox(height: 10),
            Tooltip(
              message: 'Start/Save the authorization process',
              child: ElevatedButton(
                  onPressed:
                      Provider.of<SessionProvider>(context).selectedLab !=
                                  null &&
                              Provider.of<SessionProvider>(context)
                                      .selectedSubject !=
                                  null
                          ? () => _startSession(context)
                          : null,
                  child: const Text('Start')),
            ),
          ],
        ));
  }
}
