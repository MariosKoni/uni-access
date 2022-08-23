import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';

class AlertStudentProfileWidget extends StatelessWidget {
  const AlertStudentProfileWidget({Key? key, required UniUser user})
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
              Text(_user.email!),
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
