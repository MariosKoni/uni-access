import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a session provider
class SessionProvider with ChangeNotifier {
  final List<UniUser>? _sessionUsers;
  final List<String>? _sessionUsersIds;

  final List<String>? _labs;
  final List<Map<String, dynamic>>? _subjects;

  String? _selectedLab = null;
  String? _selectedSubject = null;

  // 1 = authorized, 2 = not authorized, 3 = already authorized
  int result = 0;

  bool _startedScanning = false;
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
    print('CALLED');
    final List<String> subjects = List.empty(growable: true);

    if (_subjects!.isNotEmpty) {
      for (final subject in _subjects!) {
        subject.forEach((key, value) {
          subjects.add('$key: $value');
        });
      }
    }

    return subjects;
  }

  set selectedLab(final String? lab) {
    _selectedLab = lab;
    notifyListeners();
  }

  set selectedSubject(final String? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  set startedScanning(final bool sScanning) {
    _startedScanning = sScanning;
    notifyListeners();
  }

  String? get selectedLab => _selectedLab;

  String? get selectedSubject => _selectedSubject;

  bool get startedScanning => _startedScanning;

  Future<void> populateFormData(
      final int sw, final String? id, final BuildContext context) async {
    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');

    switch (sw) {
      // load labs
      case 1:
        await labs.get().then((value) {
          for (final element in value.docs) {
            for (final access in element['access']) {
              if (!access['users'].toString().contains(id!)) {
                continue;
              }

              final String labName = element['name'];
              if (!_labs!.contains(labName)) {
                _labs?.add(element['name'] as String);
              }
            }
          }
        }, onError: (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Could not fetch labs'),
              backgroundColor: Theme.of(context).errorColor));
        });

        break;
      // load subjects
      case 2:
        await labs.where('name', isEqualTo: _selectedLab).get().then((value) {
          for (final element in value.docs) {
            for (final access in element['access']) {
              if (!access['users'].toString().contains(id!)) {
                continue;
              }
              _subjects?.add(
                  {access['info']['subjectName']: access['info']['date']});
            }
          }
        }, onError: (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Could not fetch subjects'),
              backgroundColor: Theme.of(context).errorColor));
        });

        break;
    }
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
