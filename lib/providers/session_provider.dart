import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a session provider
class SessionProvider with ChangeNotifier {
  final List<UniUser>? _sessionUsers;
  final List<String>? _sessionUsersIds;

  final List<String>? _labs;
  final List<Map<String, dynamic>>? _subjects;

  String? _selectedLab;
  String? _selectedSubject;
  // 1 = authorized, 2 = not authorized, 3 = already authorized
  int result = 0;
  bool startedScanning = false;
  bool abortSessionFromTabChange = false;
  bool canSave = true;

  SessionProvider(
      this._sessionUsers, this._sessionUsersIds, this._labs, this._subjects);

  List<UniUser> get sessionUsers {
    return [..._sessionUsers!];
  }

  List<String> get labs {
    return [..._labs!];
  }

  List<Map<String, dynamic>> get subjects {
    return [..._subjects!];
  }

  List<String> get stringyfiedSubjects {
    final List<String> subjects = List.empty(growable: true);

    for (final subject in _subjects!) {
      subject.forEach((key, value) {
        subjects.add('$key: $value');
      });
    }

    return subjects;
  }

  set selectedLab(final String lab) {
    _selectedLab = lab;
  }

  set selectedSubject(final String subject) {
    _selectedSubject = subject;
  }

  Future<void> populateFormData(final UniUser user) async {
    if (_labs!.isNotEmpty && _subjects!.isNotEmpty) {
      result = 3;
      return;
    }

    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');

    await labs.get().then((value) {
      for (final element in value.docs) {
        for (final access in element['access']) {
          if (!access['users'].contains(user.id)) {
            continue;
          }

          final labName = element['name'];
          if (!_labs!.contains(labName)) {
            _labs?.add(element['name']);
          }
          _subjects
              ?.add({access['info']['subjectName']: access['info']['date']});
        }
      }
    }, onError: (e) => print(e));
  }

  Future<void> addUserToSession(final String id) async {
    if (_sessionUsersIds!.contains(id)) {
      return;
    }

    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    await users.where('id', isEqualTo: id).get().then((value) async {
      // Check if the user has rights
      final CollectionReference labs =
          FirebaseFirestore.instance.collection('labs');

      await checkIfUserHasAccess(labs, id);

      if (result == 2) {
        return;
      }

      final Map<String, dynamic> data =
          value.docs.first.data() as Map<String, dynamic>;
      final UniUser uniUser = UniUser(
          id: data['id'],
          name: data['name'],
          surname: data['surname'],
          email: data['email'],
          isTeacher: data['isTeacher'],
          image: data['image']);

      if (_sessionUsersIds!.isEmpty) {
        canSave = true;
        notifyListeners();
      }

      _sessionUsers?.add(uniUser);
      _sessionUsersIds?.add(id);
    }, onError: (e) => print(e));

    notifyListeners();
  }

  Future<void> checkIfUserHasAccess(
      CollectionReference<Object?> labs, String id) async {
    await labs.get().then((value) {
      // final Map<String, dynamic> data = value.docs as Map<String, dynamic>;
      // print(data);

      for (final element in value.docs) {
        for (final access in element['access']) {
          if (access['users'].contains(id) &&
              (access['info']['subjectName'].toString() +
                      ': ' +
                      access['info']['date'].toString()) ==
                  _selectedSubject &&
              element['name'].toString() == _selectedLab) {
            result = 1;
            break;
          } else {
            result = 2;
            break;
          }
        }
        if (result == 1) {
          break;
        }
      }
    }, onError: (e) => print(e));
  }

  Future<void> saveSession() async {
    final session = <String, dynamic>{
      'lab': _selectedLab,
      'subject': _selectedSubject,
      'students': _sessionUsersIds,
      'timestamp': DateTime.now()
    };

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc()
        .set(session)
        .onError((error, stackTrace) => print('Error: $error'));

    stopSession();
  }

  void stopSession() {
    _sessionUsers?.clear();
    _sessionUsersIds?.clear();
    startedScanning = false;
  }
}
