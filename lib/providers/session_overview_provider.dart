import 'package:flutter/cupertino.dart';
import 'package:flutter_uni_access/models/session.dart';

// Defines a session overview provider
class SessionOverviewProvider with ChangeNotifier {
  List<Session>? sessions;
  List<String>? labs;
  List<String>? subjects;
  List<String>? filters;

  SessionOverviewProvider(
      this.labs, this.subjects, this.sessions, this.filters);

  void populateLists() {
    for (final session in sessions!) {
      final String? lab = session.lab;
      if (!labs!.contains(lab)) {
        labs?.add(lab!);
      }

      final String? subject = session.subject;
      if (!subjects!.contains(subject)) {
        subjects?.add(subject!);
      }
    }
  }

  void applyFilter(int filter, String? value) {
    List<Session> filteredSessions = List.empty();

    // 1 lab
    // 2 subject
    switch (filter) {
      case 1:
        filteredSessions =
            sessions!.where((element) => element.lab == value).toList();
        break;
      case 2:
        filteredSessions =
            sessions!.where((element) => element.subject == value).toList();
        break;
    }

    if (!filters!.contains(value)) {
      filters?.add(value!);
    }

    sessions = filteredSessions;
    notifyListeners();
  }
}
