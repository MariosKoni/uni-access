import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

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
                  FormOption(
                    key: const Key('1'),
                    option: Provider.of<Session>(context, listen: false).labs,
                    titleOption: 'Lab',
                  ),
                  FormOption(
                    key: const Key('2'),
                    option: Provider.of<Session>(context, listen: false)
                        .stringyfiedSubjects,
                    titleOption: 'Subject',
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_triggerButtonText == 'Start') {
                            _triggerButtonText = 'Stop';
                            _showAttendence = true;
                          } else {
                            _triggerButtonText = 'Start';
                            _showAttendence = false;
                          }
                        });
                      },
                      child: Text(_triggerButtonText)),
                  const Divider(
                    color: Colors.white,
                  ),
                  if (_showAttendence) AttendanceWidget() else Container(),
                ],
              ),
            ),
    );
  }
}

class FormOption extends StatefulWidget {
  FormOption({
    Key? key,
    required List<String> option,
    required String titleOption,
  })  : _option = option,
        _titleOption = titleOption,
        super(key: key);

  final List<String> _option;
  final String _titleOption;

  String _selectedItem = '';

  @override
  State<FormOption> createState() => _FormOptionState();
}

class _FormOptionState extends State<FormOption> {
  @override
  void initState() {
    super.initState();

    _updateSessionSelectedItem(widget._option.first, context);
    widget._selectedItem = widget._option.first;
  }

  void _updateSessionSelectedItem(String? newValue, BuildContext context) {
    if (newValue!.contains(':')) {
      Provider.of<Session>(context, listen: false).selectedSubject = newValue;
    } else {
      Provider.of<Session>(context, listen: false).selectedLab = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget._titleOption, style: Theme.of(context).textTheme.headline6),
        const SizedBox(width: 10),
        DropdownButton<String>(
          dropdownColor: Theme.of(context).colorScheme.primary,
          value: widget._selectedItem,
          icon: const Icon(Icons.arrow_drop_down_rounded),
          elevation: 16,
          style: const TextStyle(color: Colors.white),
          underline: Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _updateSessionSelectedItem(newValue, context);
              widget._selectedItem = newValue!;
            });
          },
          items: widget._option.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class AttendanceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sessionUsers = Provider.of<Session>(context).sessionUsers;

    return Column(
      children: [
        Padding(
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
                  child: Column(
                    children: sessionUsers
                        .map((e) => ListTile(
                            leading: const Icon(Icons.check_circle_rounded),
                            title: Text('${e.name} ${e.surname}'),
                            subtitle: const Text('Student'),
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    duration: const Duration(seconds: 1),
                                    content: Text('${e.name} ${e.surname}'),
                                    backgroundColor:
                                        Theme.of(context).primaryColor))))
                        .toList(),
                  ),
                ),
              ),
            )),
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const _Scan())),
            child: const Text('Scan'),
          ),
        )
      ],
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
          print(result);
          await Provider.of<Session>(context, listen: false)
              .addUserToSession(result, context);

          final bool hasRights =
              Provider.of<Session>(context, listen: false).rights;
          print(hasRights);

          await _showAlertDialog(context, hasRights,
              hasRights ? 'Student Authorized' : 'Student was not authorized');

          Navigator.of(context).pop();
        });
  }
}

Future<void> _showAlertDialog(BuildContext context, bool ok, String msg) async {
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
      title: const Text('Result'),
      content: Row(children: [
        Icon(_ok ? Icons.check_circle : Icons.error_rounded),
        Text(_msg)
      ]),
      backgroundColor: _ok ? Colors.green : Colors.red,
    );
  }
}
