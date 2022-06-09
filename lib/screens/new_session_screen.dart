import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session.dart';

class NewSessionScreen extends StatefulWidget {
  final UniUser user;

  NewSessionScreen(this.user);

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  String _lab = 'One';

  String _subject = 'One';

  bool _showAttendence = false;

  @override
  Widget build(BuildContext context) {
    return Card(
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
            option: _lab,
            titleOption: 'Lab',
          ),
          FormOption(
            option: _subject,
            titleOption: 'Subject',
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _showAttendence = true;
                });
              },
              child: const Text('Start')),
          const Divider(
            color: Colors.white,
          ),
          if (_showAttendence) AttendanceWidget() else Container(),
        ],
      ),
    );
  }
}

class FormOption extends StatefulWidget {
  FormOption({
    Key? key,
    required String option,
    required String titleOption,
  })  : _option = option,
        _titleOption = titleOption,
        super(key: key);

  String _option;
  String _titleOption;

  @override
  State<FormOption> createState() => _FormOptionState();
}

class _FormOptionState extends State<FormOption> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget._titleOption, style: Theme.of(context).textTheme.headline6),
        const SizedBox(width: 10),
        DropdownButton<String>(
          dropdownColor: Theme.of(context).colorScheme.primary,
          value: widget._option,
          icon: const Icon(Icons.arrow_drop_down_rounded),
          elevation: 16,
          style: const TextStyle(color: Colors.white),
          underline: Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          onChanged: (String? newValue) {
            setState(() {
              widget._option = newValue!;
            });
          },
          items: <String>['One', 'Two', 'Free', 'Four']
              .map<DropdownMenuItem<String>>((String value) {
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
                            title: Text(e),
                            subtitle: const Text('Student'),
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content: Text(e),
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
                .push(MaterialPageRoute(builder: (context) => const Scan())),
            child: const Text('Scan'),
          ),
        )
      ],
    );
  }
}

class Scan extends StatelessWidget {
  const Scan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
        allowDuplicates: false,
        onDetect: (barcode, args) {
          if (barcode.rawValue == null) {
            print('NULL BARCODE');
          }

          final result = barcode.rawValue!;
          HapticFeedback.vibrate();
          print(result);
          Provider.of<Session>(context, listen: false).addUserToSession(result);

          Navigator.of(context).pop();
        });
  }
}
