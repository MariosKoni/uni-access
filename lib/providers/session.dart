// Defines a session
import 'package:flutter/material.dart';

class Session with ChangeNotifier {
  List<String>? _sessionUsers;

  Session(this._sessionUsers);

  List<String> get sessionUsers {
    return [..._sessionUsers!];
  }

  void addUserToSession(String name) {
    _sessionUsers?.add(name);
    print(_sessionUsers);

    notifyListeners();
  }
}
