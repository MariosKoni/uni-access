import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

class NewSessionScreen extends StatefulWidget {
  final UniUser user;

  NewSessionScreen(this.user);

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(children: [Text('Test')]));
  }
}
