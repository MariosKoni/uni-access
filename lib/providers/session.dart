import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a session
class Session with ChangeNotifier {
  final List<UniUser>? _sessionUsers;

  final List<String>? _labs;
  final List<Map<String, dynamic>>? _subjects;

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

  Future<void> populateFormData(final UniUser user) async {
    if (_labs!.isNotEmpty && _subjects!.isNotEmpty) {
      return;
    }

    CollectionReference labs = FirebaseFirestore.instance.collection('labs');

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

    print(_labs);
    print(_subjects);
  }

  void addUserToSession(final String id) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    users.where('id', isEqualTo: id).get().then((value) {
      // Chech if the user has rights
      Map<String, dynamic> data =
          value.docs.first.data() as Map<String, dynamic>;
      final UniUser uniUser = UniUser(
          id: data['id'],
          name: data['name'],
          surname: data['surname'],
          email: data['email'],
          isTeacher: data['isTeacher'],
          image: data['image']);

      _sessionUsers?.add(uniUser);
      print(_sessionUsers);
    });

    notifyListeners();
  }
}
