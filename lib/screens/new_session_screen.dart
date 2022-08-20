import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session.dart';
import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';
import 'package:flutter_uni_access/widgets/formOptionWidget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class NewSessionScreen extends StatefulWidget {
  final UniUser user;

  NewSessionScreen(this.user);

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  bool _showAttendence = false;
  String _triggerButtonText = 'Start';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Session>(context, listen: false)
          .populateFormData(widget.user),
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
                    option: Provider.of<Session>(context, listen: false).labs,
                    titleOption: 'Lab',
                  ),
                  FormOptionWidget(
                    key: const Key('2'),
                    option: Provider.of<Session>(context, listen: false)
                        .stringyfiedSubjects,
                    titleOption: 'Subject',
                  ),
                  const SizedBox(height: 10),
                  Tooltip(
                    message: 'Start/Save the authorization process',
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_triggerButtonText == 'Start') {
                              _triggerButtonText = 'Save';
                              _showAttendence = true;
                              Provider.of<Session>(context, listen: false)
                                  .startedScanning = true;
                            } else {
                              Provider.of<Session>(context, listen: false)
                                  .saveSession();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: const Text(
                                          'Session saved successfully'),
                                      backgroundColor:
                                          Theme.of(context).primaryColor));
                              Provider.of<Session>(context, listen: false)
                                  .startedScanning = false;
                              _triggerButtonText = 'Start';
                              _showAttendence = false;
                            }
                          });
                        },
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

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({Key? key}) : super(key: key);

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  final GlobalKey _one = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([_one]));
  }

  @override
  Widget build(BuildContext context) {
    final sessionUsers = Provider.of<Session>(context).sessionUsers;

    return Column(
      children: [
        Showcase(
          key: _one,
          description: 'Tap on a user to see his/her profile',
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: const Color.fromRGBO(255, 255, 255, 0.6),
                elevation: 8,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(15.0))),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 2.5,
                  child: SingleChildScrollView(
                    child: sessionUsers.isEmpty
                        ? const Center(
                            child: Text(''),
                          )
                        : Column(
                            children: sessionUsers
                                .map(
                                  (e) => ListTile(
                                      leading: const Icon(
                                          Icons.check_circle_rounded),
                                      title: Text(
                                          '${e.name.toString().capitalize()} ${e.surname.toString().capitalize()}'),
                                      subtitle: Text('Student - ${e.id}'),
                                      onTap: () async {
                                        await _showStudentProfileAlertDialog(
                                            context, e);
                                      }),
                                )
                                .toList(),
                          ),
                  ),
                ),
              )),
        ),
        Center(
          child: Tooltip(
            message: 'Scan a barcode',
            child: ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const _Scan())),
              child: const Text('Scan'),
            ),
          ),
        )
      ],
    );
  }
}

Future<void> _showStudentProfileAlertDialog(
    BuildContext context, UniUser user) async {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) => _AlertStudentProfile(user: user)));
}

class _AlertStudentProfile extends StatelessWidget {
  const _AlertStudentProfile({Key? key, required UniUser user})
      : _user = user,
        super(key: key);

  final UniUser _user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      title: const Center(
          child: Text(
        'Student Info',
        style: TextStyle(color: Colors.black),
      )),
      content: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              Image(
                  image: NetworkImage(_user.image!),
                  height: MediaQuery.of(context).size.height / 3),
              Text(_user.id!),
              Text(_user.name.toString().capitalize()),
              Text(_user.surname.toString().capitalize()),
              Text(_user.email.toString().capitalize()),
            ],
          )),
      actions: [
        Tooltip(
          message: 'Close',
          child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close')),
        )
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

class _Scan extends StatelessWidget {
  const _Scan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) async {
          if (barcode.rawValue == null) {
            print('NULL BARCODE');
          }

          final result = barcode.rawValue!;
          HapticFeedback.vibrate();
          await Provider.of<Session>(context, listen: false)
              .addUserToSession(result, context);

          final bool hasRights =
              Provider.of<Session>(context, listen: false).rights;

          await _showAuthorizeAlertDialog(context, hasRights,
              hasRights ? 'Student Authorized' : 'Student was not authorized');

          Navigator.of(context).pop();
        });
  }
}

Future<void> _showAuthorizeAlertDialog(
    BuildContext context, bool ok, String msg) async {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(
            const Duration(seconds: 1), () => Navigator.of(context).pop(true));
        return _AlertResultWidget(ok: ok, msg: msg);
      });
}

class _AlertResultWidget extends StatelessWidget {
  const _AlertResultWidget({Key? key, required bool ok, required String msg})
      : _ok = ok,
        _msg = msg,
        super(key: key);

  final bool _ok;
  final String _msg;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      title: const Text('Result'),
      content: Row(children: [
        Icon(_ok ? Icons.check_circle : Icons.error_rounded),
        Text(_msg)
      ]),
      backgroundColor: _ok ? Colors.green : Colors.red,
    );
  }
}
