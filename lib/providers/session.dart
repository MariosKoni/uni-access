import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a session
class Session with ChangeNotifier {
  final List<UniUser>? _sessionUsers;

  final List<String>? _labs;
  final List<Map<String, dynamic>>? _subjects;

  String? _selectedLab;
  String? _selectedSubject;
  bool _hasRights = false;
  bool startedScanning = false;
  bool abortSessionFromTabChange = false;

  Session(this._sessionUsers, this._labs, this._subjects);

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

  bool get rights {
    return _hasRights;
  }

  Future<void> populateFormData(final UniUser user) async {
    if (_labs!.isNotEmpty && _subjects!.isNotEmpty) {
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

  Future<void> addUserToSession(final String id, final BuildContext ctx) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    await users.where('id', isEqualTo: id).get().then((value) async {
      // Check if the user has rights
      final CollectionReference labs =
          FirebaseFirestore.instance.collection('labs');

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
              _hasRights = true;
              break;
            } else {
              _hasRights = false;
              break;
            }
          }
          if (_hasRights) {
            break;
          }
        }
      }, onError: (e) => print(e));

      if (!_hasRights) {
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

      _sessionUsers?.add(uniUser);
    }, onError: (e) => print(e));

    notifyListeners();
  }

  Future<void> saveSession() async {
    final List<String> ids = List.empty(growable: true);

    for (final UniUser student in _sessionUsers!) {
      ids.add(student.id!);
    }

    final session = <String, dynamic>{
      'lab': _selectedLab,
      'subject': _selectedSubject,
      'students': ids,
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
    startedScanning = false;
  }
}
