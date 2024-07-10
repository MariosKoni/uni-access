import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/widgets/new_session_form_option_widget.dart';
import 'package:provider/provider.dart';

class NewSessionDialogWidget extends StatelessWidget {
  const NewSessionDialogWidget({Key? key}) : super(key: key);

  void _startSession(BuildContext context) {
    Provider.of<SessionProvider>(context, listen: false).startedScanning = true;
    Provider.of<SessionProvider>(context, listen: false).canSaveSession = false;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Register a new session',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          NewSessionFormOptionWidget(
            key: const Key('lab'),
            option: Provider.of<SessionProvider>(context, listen: false).labs,
            titleOption: 'Lab',
          ),
          NewSessionFormOptionWidget(
            key: const Key('subject'),
            option: Provider.of<SessionProvider>(context).subjects,
            titleOption: 'Subject',
          ),
          Tooltip(
            message: 'Start the authorization process',
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(232, 52, 93, 1.0),
              ),
              onPressed: Provider.of<SessionProvider>(context).selectedLab !=
                          null &&
                      Provider.of<SessionProvider>(context).selectedSubject !=
                          null
                  ? () => _startSession(context)
                  : null,
              child: const Text('Start'),
            ),
          ),
        ],
      ),
    );
  }
}
