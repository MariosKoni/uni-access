import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_uni_access/widgets/display_new_session_form.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

class NewSessionScreen extends StatefulWidget {
  final UniUser user;

  NewSessionScreen(this.user);

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  bool _isAvailable = true;

  void _checkNFC() async {
    final bool _r = await NfcManager.instance.isAvailable();
    setState(() {
      _isAvailable = _r;
    });
  }

  @override
  void initState() {
    _checkNFC();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAvailable) {
      return const DisplayNewSessionForm();
    }

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
        child: Text('NFC is not available.'),
      ),
    ));
  }
}
