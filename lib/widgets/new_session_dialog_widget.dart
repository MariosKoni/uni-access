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
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Register a new session',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          NewSessionFormOptionWidget(
            key: const Key('lab'),
            option: Provider.of<SessionProvider>(context, listen: false).labs,
            titleOption: 'Lab',
          ),
          const SizedBox(
            height: 10,
          ),
          NewSessionFormOptionWidget(
            key: const Key('subject'),
            option: Provider.of<SessionProvider>(context).subjects,
            titleOption: 'Subject',
          ),
          const SizedBox(height: 10),
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
