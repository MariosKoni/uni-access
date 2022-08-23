import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/attendence_widget.dart';
import 'package:flutter_uni_access/widgets/formOptionWidget.dart';
import 'package:provider/provider.dart';

class NewSessionScreen extends StatefulWidget {
  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  bool _showAttendence = false;
  String _triggerButtonText = 'Start';

  void _startNsaveASession() {
    setState(() {
      if (_triggerButtonText == 'Start') {
        _triggerButtonText = 'Save';
        _showAttendence = true;
        Provider.of<SessionProvider>(context, listen: false).startedScanning =
            true;
        Provider.of<SessionProvider>(context, listen: false).canSave = false;
      } else {
        Provider.of<SessionProvider>(context, listen: false).saveSession();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 2),
            content: const Text('Session saved successfully.'),
            backgroundColor: Color.fromRGBO(232, 52, 93, 1.0)));
        Provider.of<SessionProvider>(context, listen: false).startedScanning =
            false;
        Provider.of<SessionProvider>(context, listen: false).canSave = true;
        _triggerButtonText = 'Start';
        _showAttendence = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<SessionProvider>(context, listen: false)
          .populateFormData(
              Provider.of<UserProvider>(context, listen: false).user!),
      builder: (_, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? const Center(child: CircularProgressIndicator())
          : Card(
              color: Theme.of(context).colorScheme.secondary,
              elevation: 5,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0))),
              child: Column(
                children: [
                  Text(
                    'Please enter the lab information to begin the procedure',
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  FormOptionWidget(
                    key: const Key('1'),
                    option: Provider.of<SessionProvider>(context, listen: false)
                        .labs,
                    titleOption: 'Lab',
                  ),
                  FormOptionWidget(
                    key: const Key('2'),
                    option: Provider.of<SessionProvider>(context, listen: false)
                        .stringyfiedSubjects,
                    titleOption: 'Subject',
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: 'Start/Save the authorization process',
                    child: ElevatedButton(
                        onPressed: Provider.of<SessionProvider>(context).canSave
                            ? _startNsaveASession
                            : null,
                        child: Text(_triggerButtonText)),
                  ),
                  const Divider(thickness: 5.0),
                  if (_showAttendence)
                    const AttendanceWidget()
                  else
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 6,
                        ),
                        SizedBox(
                          child: Center(
                              child: Column(
                            children: const [
                              Icon(
                                Icons.class_rounded,
                                size: 100.0,
                                color: Colors.white,
                              ),
                              Text(
                                  'Select a Lab and Subject to start the process')
                            ],
                          )),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
