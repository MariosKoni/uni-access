// ignore_for_file: avoid_dynamic_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:provider/provider.dart';

// Defines a session provider
class SessionProvider with ChangeNotifier {
  final List<UniUser>? _sessionUsers;
  final List<String>? _sessionUsersIds;

  final List<String>? _labs;
  List<String>? _labSubjects;

  String? _selectedLab;
  String? _selectedSubject;

  // 1 = authorized,
  // 2 = not authorized,
  // 3 = already authorized
  int result = 0;

  bool _startedScanning = false;
  bool abortSessionFromTabChange = false;
  bool canSave = false;
  int? currentStudentAttendances;

  SessionProvider(
    this._sessionUsers,
    this._sessionUsersIds,
    this._labs,
    this._labSubjects,
  );

  List<UniUser> get sessionUsers {
    return [..._sessionUsers!];
  }

  List<String> get labs {
    return [..._labs!];
  }

  List<String> get subjects => [...?_labSubjects];

  set selectedLab(String? lab) {
    _selectedLab = lab;
    notifyListeners();
  }

  set selectedSubject(String? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  set startedScanning(bool sScanning) {
    _startedScanning = sScanning;
    notifyListeners();
  }

  String? get selectedLab => _selectedLab;

  String? get selectedSubject => _selectedSubject;

  bool get startedScanning => _startedScanning;

  Future<void> populateFormData(int sw, String id, BuildContext context) async {
    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');

    switch (sw) {
      // load labs
      case 1:
        await labs.get().then(
          (value) {
            for (final element in value.docs) {
              for (final access in element['access']) {
                final Map<String, dynamic>? accessData =
                    access as Map<String, dynamic>?;

                if (!accessData!['users'].toString().contains(id)) {
                  continue;
                }

                final String labName = element['name'] as String;
                if (!_labs!.contains(labName)) {
                  _labs?.add(element['name'] as String);
                }
              }
            }
          },
          onError: (e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Could not fetch labs'),
                backgroundColor: Theme.of(context).errorColor,
              ),
            );
          },
        );

        break;
      // load subjects
      case 2:
        final List<String> subjects = List.empty(growable: true);
        await labs.where('name', isEqualTo: _selectedLab).get().then(
          (value) {
            for (final element in value.docs) {
              for (final access in element['access']) {
                final Map<String, dynamic>? accessData =
                    access as Map<String, dynamic>?;
                if (!accessData!['users'].toString().contains(id)) {
                  continue;
                }
                subjects.add(
                  '${accessData['info']['subjectName']}: ${accessData['info']['date']}',
                );
              }
            }
          },
          onError: (e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Could not fetch subjects'),
                backgroundColor: Theme.of(context).errorColor,
              ),
            );
          },
        );

        _labSubjects = subjects;
        notifyListeners();

        break;
    }
  }

  Future<void> addUserToSession(String id) async {
    if (_sessionUsersIds!.contains(id)) {
      result = 3;
      return;
    }

    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    await users.where('id', isEqualTo: id).get().then(
      (value) async {
        // Check if the user has rights
        final CollectionReference labs =
            FirebaseFirestore.instance.collection('labs');

        await checkIfUserHasAccess(labs, id);

        if (result == 2) {
          return;
        }

        final Map<String, dynamic>? data =
            value.docs.first.data() as Map<String, dynamic>?;
        final UniUser uniUser = UniUser(
          id: data!['id'] as String,
          name: data['name'] as String,
          surname: data['surname'] as String,
          email: data['email'] as String,
          isTeacher: data['isTeacher'] as bool,
          image: data['image'] as String,
        );

        if (_sessionUsersIds!.isEmpty) {
          canSave = true;
          notifyListeners();
        }

        _sessionUsers?.add(uniUser);
        _sessionUsersIds?.add(id);
      },
      onError: (e) => print(e),
    );

    notifyListeners();
  }

  Future<void> checkIfUserHasAccess(
    CollectionReference<Object?> labs,
    String id,
  ) async {
    await labs.get().then(
      (value) {
        for (final element in value.docs) {
          for (final access in element['access']) {
            final Map<String, dynamic>? accessData =
                access as Map<String, dynamic>?;
            final List<dynamic> userIdsList =
                accessData!['users'] as List<dynamic>;
            if (userIdsList.contains(id) &&
                ('${accessData['info']['subjectName']}: ${accessData['info']['date']}') ==
                    _selectedSubject &&
                element['name'].toString() == _selectedLab) {
              result = 1;
              break;
            }
          }
          if (result == 1) {
            break;
          }
        }

        if (result != 1) {
          result = 2;
        }
      },
      onError: (e) => print(e),
    );
  }

  Future<void> findStudentAttendances(String id) async {
    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');
    bool shouldBreak = false;

    await labs.where('name', isEqualTo: _selectedLab).get().then(
      (value) {
        for (final element in value.docs) {
          for (final access in element['access']) {
            final Map<String, dynamic>? accessData =
                access as Map<String, dynamic>?;
            final Map<String, dynamic>? info =
                accessData?['info'] as Map<String, dynamic>?;

            if (('${info?['subjectName'] as String}: ${info?['date'] as String}')
                    .compareTo(
                  '$selectedSubject',
                ) ==
                0) {
              final Map<String, dynamic>? attendance =
                  accessData?['attendance'] as Map<String, dynamic>?;
              attendance?.forEach((key, value) {
                if (key == id) {
                  currentStudentAttendances = value as int;
                  shouldBreak = true;
                }
              });
            }

            if (shouldBreak) {
              break;
            }
          }
          if (shouldBreak) {
            break;
          }
        }
      },
      onError: (e) => print(e),
    );
  }

  Future<void> saveSession(BuildContext context) async {
    final session = <String, dynamic>{
      'lab': _selectedLab,
      'subject': _selectedSubject,
      'students': _sessionUsersIds,
      'timestamp': DateTime.now(),
      'teacher': Provider.of<UserProvider>(context, listen: false).user?.id
    };

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc()
        .set(session)
        .onError((error, stackTrace) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could save session'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    });

    // TODO: Move it to frontend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session saved'),
        backgroundColor: Color.fromRGBO(
          232,
          52,
          93,
          1.0,
        ),
      ),
    );

    stopSession();
  }

  void stopSession() {
    _sessionUsers?.clear();
    _sessionUsersIds?.clear();
    startedScanning = false;
  }
}
