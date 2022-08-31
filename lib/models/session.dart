// Defines a session
class Session {
  final String? lab;
  final List<String>? studentsIds;
  final String? subject;
  final String? teacher;
  final String? timestamp;

  Session({
    required this.lab,
    required this.studentsIds,
    required this.subject,
    required this.teacher,
    required this.timestamp,
  });
}
