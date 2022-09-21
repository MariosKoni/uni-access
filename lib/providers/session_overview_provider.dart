import 'package:flutter/cupertino.dart';
import 'package:flutter_uni_access/models/session.dart';

// Defines a session overview provider
class SessionOverviewProvider with ChangeNotifier {
  List<Session>? allSessions;
  List<Session>? sessions;
  List<String>? labs;
  List<String>? subjects;
  List<String>? filters;

  SessionOverviewProvider(
    this.allSessions,
    this.labs,
    this.subjects,
    this.sessions,
    this.filters,
  );

  void populateLists() {
    for (final session in sessions!) {
      final lab = session.lab;
      if (!labs!.contains(lab)) {
        labs?.add(lab!);
      }

      final subject = session.subject;
      if (!subjects!.contains(subject)) {
        subjects?.add(subject!);
      }
    }
  }

  void filter() {
    if (filters!.isEmpty) {
      sessions = allSessions;
      notifyListeners();
      return;
    }

    if (sessions!.isEmpty) {
      sessions = allSessions;
    }

    var filteredSessions = List<Session>.empty();
    filteredSessions = sessions!
        .where(
          (element) =>
              element.subject == filters?.last || element.lab == filters?.last,
        )
        .toList();

    sessions = filteredSessions;
    notifyListeners();
  }
}
