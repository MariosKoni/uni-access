// ignore_for_file: avoid_dynamic_calls, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/attendances.dart';
import 'package:flutter_uni_access/models/labs.dart';
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

  final Map<String, int> _attendants;

  SessionProvider(
    this._sessionUsers,
    this._sessionUsersIds,
    this._labs,
    this._labSubjects,
    this._attendants,
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
    if (_labs!.isNotEmpty && _labSubjects!.isNotEmpty) {
      return;
    }

    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');

    switch (sw) {
      // load labs
      case 1:
        await labs.get().then(
          (value) {
            for (final element in value.docs) {
              final Labs lab = Labs.fromFirestore(element);
              if (lab.access == null) {
                return;
              }

              for (final access in lab.access!) {
                final Map<String, dynamic>? accessData =
                    access as Map<String, dynamic>?;

                if (!accessData!['users'].toString().contains(id)) {
                  continue;
                }

                final String labName = lab.name!;
                if (!_labs!.contains(labName)) {
                  _labs?.add(labName);
                }
              }
            }
          },
          onError: (e) {
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
              final Labs lab = Labs.fromFirestore(element);
              if (lab.access == null) {
                return;
              }
              for (final access in lab.access!) {
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

  Future<void> addUserToSession(String id, BuildContext context) async {
    if (_sessionUsersIds!.contains(id)) {
      result = 3;
      return;
    }

    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    await users.doc(id).get().then(
      (value) async {
        // Check if the user has rights
        final CollectionReference labs =
            FirebaseFirestore.instance.collection('labs');

        await checkIfUserHasAccess(labs, id, context);

        if (result == 2) {
          return;
        }

        final UniUser uniUser = UniUser.fromFirestore(value);

        if (_sessionUsersIds!.isEmpty) {
          canSave = true;
          notifyListeners();
        }

        _sessionUsers?.add(uniUser);
        _sessionUsersIds?.add(id);

        await updateUserAttendance(id, context);
      },
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get user with id $id'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      ),
    );

    notifyListeners();
  }

  Future<void> checkIfUserHasAccess(
    CollectionReference<Object?> labs,
    String id,
    BuildContext context,
  ) async {
    await labs.get().then(
      (value) {
        for (final element in value.docs) {
          final Labs lab = Labs.fromFirestore(element);
          if (lab.access == null) {
            return;
          }
          for (final access in lab.access!) {
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
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not fetch lab access data'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      ),
    );
  }

  Future<void> addMissingAttendanceDocument(
    String id,
    BuildContext context,
  ) async {
    final attendance = <String, dynamic>{
      'subject': _selectedSubject,
      'attendants': {id: 1},
    };

    _attendants.putIfAbsent(id, () => 1);

    await FirebaseFirestore.instance
        .collection('attendances')
        .doc(_selectedSubject)
        .set(attendance)
        .onError(
          (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not update attendance'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          ),
        );
  }

  Future<void> updateUserAttendance(String id, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('attendances')
        .doc(_selectedSubject)
        .get()
        .then(
      (value) async {
        if (!value.exists) {
          await addMissingAttendanceDocument(id, context);
          return;
        }

        final Attendances attendance = Attendances.fromFirestore(value);

        attendance.attendants?.forEach((key, value) {
          if (key == id) {
            _attendants.putIfAbsent(key, () => value + 1 as int);
          }
        });
      },
      onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not fetch attendance data'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      ),
    );
  }

  Future<void> findStudentAttendances(String id, BuildContext context) async {
    final CollectionReference attendances =
        FirebaseFirestore.instance.collection('attendances');

    await attendances.doc(_selectedSubject).get().then(
      (value) {
        final Attendances attendances = Attendances.fromFirestore(value);
        attendances.attendants?.forEach((key, value) {
          if (key == id) {
            currentStudentAttendances = value as int;
          }
        });
      },
      onError: (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not fetch student attendance data'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      ),
    );
  }

  Future<void> updateAttendances(BuildContext context) async {
    final currentAttendances = FirebaseFirestore.instance
        .collection('attendances')
        .doc(_selectedSubject);

    currentAttendances.update({'attendants': _attendants});
  }

  Future<void> saveSession(BuildContext context) async {
    await updateAttendances(context);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not save session'),
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
