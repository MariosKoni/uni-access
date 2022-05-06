import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_uni_access/widgets/display_new_session_form.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

class NewSessionScreen extends StatelessWidget {
  final UniUser user;

  NewSessionScreen(this.user);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: NfcManager.instance.isAvailable(),
        builder: ((_, AsyncSnapshot snapshot) {
          if (snapshot.data == true) {
            return const DisplayNewSessionForm();
          } else {
            return Center(
                child: Card(
              color: Theme.of(context).colorScheme.secondary,
              elevation: 5,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0))),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Enable NFC to proceed.'),
              ),
            ));
          }
        }));
  }
}
