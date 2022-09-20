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
  final List<UniUser>? sessionUsers;

  final List<String>? _labs;
  List<String>? _subjects;

  String? _selectedLab;
  String? _selectedSubject;

  // 1 = authorized,
  // 2 = not authorized,
  // 3 = already authorized
  int authResult = 0;

  bool _startedScanning = false;
  bool abortSessionFromTabChange = false;
  bool canSaveSession = false;
  int? currentUserAttendance;

  SessionProvider(
    this.sessionUsers,
    this._labs,
    this._subjects,
  );

  List<String> get labs {
    return [..._labs!];
  }

  List<String> get subjects => [...?_subjects];

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
    if (_labs!.isNotEmpty && _subjects!.isNotEmpty) {
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
        await labs.doc(_selectedLab).get().then(
          (value) {
            final Labs lab = Labs.fromFirestore(value);
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

        _subjects = subjects;
        notifyListeners();

        break;
    }
  }

  Future<void> findAllPermittedStudents() async {
    final CollectionReference labs =
        FirebaseFirestore.instance.collection('labs');
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    await labs.doc(_selectedLab).get().then(
      (value) async {
        final Labs lab = Labs.fromFirestore(value);

        for (final access in lab.access!) {
          final Map<String, dynamic>? accessData =
              access as Map<String, dynamic>?;
          if ('${accessData?['info']['subjectName']}: ${accessData?['info']['date']}' ==
              _selectedSubject) {
            for (final String student in accessData?['users']) {
              if (!student.startsWith('cs')) {
                continue;
              }

              await users.doc(student).get().then(
                (value) {
                  final UniUser uniUser = UniUser.fromFirestore(value);
                  uniUser.isAuthorized = false;
                  sessionUsers?.add(uniUser);
                },
                onError: (e) => print(e),
              );
            }
          }
        }
      },
      onError: (e) => print(e),
    );

    notifyListeners();
  }

  void authorizeUser(String id) {
    print(sessionUsers!.firstWhere((user) => user.id == id).isAuthorized);
    if (sessionUsers!.firstWhere((user) => user.id == id).isAuthorized) {
      print('already');
      authResult = 3;
    } else {
      print('new');
      sessionUsers
          ?.map((user) => user.id == id ? user.isAuthorized = true : null);
      authResult = 1;
    }

    print(sessionUsers!.firstWhere((user) => user.id == id).isAuthorized);
    notifyListeners();
  }

  Future<void> addMissingAttendanceDocument(
    BuildContext context,
  ) async {
    sessionUsers?.map((user) => user.attendaces = 1);

    final attendance = <String, dynamic>{
      'subject': _selectedSubject,
      'attendants': {
        for (final user in sessionUsers!) user.id: user.attendaces
      },
    };

    await FirebaseFirestore.instance
        .collection('attendances')
        .doc(_selectedSubject)
        .set(attendance)
        .onError(
          (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not initiate attendance'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          ),
        );
  }

  Future<void> updateUserAttendance(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('attendances')
        .doc(_selectedSubject)
        .get()
        .then(
      (value) async {
        if (!value.exists) {
          await addMissingAttendanceDocument(context);
          return;
        }

        final Attendances attendance = Attendances.fromFirestore(value);

        attendance.attendants?.forEach((key, value) {
          sessionUsers?.map(
            (user) =>
                user.id == key ? user.attendaces = value + 1 as int : null,
          );
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
        if (!value.exists) {
          currentUserAttendance = null;
          return;
        }
        final Attendances attendances = Attendances.fromFirestore(value);
        attendances.attendants?.forEach((key, value) {
          if (key == id) {
            currentUserAttendance = value as int;
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

    currentAttendances.update({
      'attendants': {for (final user in sessionUsers!) user.id: user.attendaces}
    });
  }

  Future<void> saveSession(BuildContext context) async {
    await updateUserAttendance(context);

    await updateAttendances(context);

    final session = <String, dynamic>{
      'lab': _selectedLab,
      'subject': _selectedSubject,
      'students': sessionUsers?.map((e) => e.id).toList(),
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
    _selectedLab = null;
    _selectedSubject = null;
    sessionUsers?.clear();
    startedScanning = false;
  }
}
