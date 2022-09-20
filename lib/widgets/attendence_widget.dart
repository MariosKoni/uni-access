import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';
import 'package:flutter_uni_access/widgets/alert_student_profile_widget.dart';
import 'package:flutter_uni_access/widgets/scan_widget.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({Key? key}) : super(key: key);

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  final GlobalKey _one = GlobalKey();

  @override
  void initState() {
    super.initState();

    Provider.of<SessionProvider>(context, listen: false)
        .findAllPermittedStudents()
        .then((value) => print('ok'));

    Provider.of<SessionProvider>(context, listen: false).canSaveSession = true;

    // TODO: Make this run only one time!
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase([_one]),
    );
  }

  Future<void> _showStudentProfileAlertDialog(
    BuildContext context,
    UniUser user,
  ) async {
    await Provider.of<SessionProvider>(context, listen: false)
        .findStudentAttendances(user.id!, context);
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertStudentProfileWidget(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: const Color.fromRGBO(255, 255, 255, 0.6),
            elevation: 8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
              ),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: SingleChildScrollView(
                child: Showcase(
                  key: _one,
                  description: 'Tap on a user to see his/her profile',
                  child: Column(
                    children: Provider.of<SessionProvider>(context)
                        .sessionUsers!
                        .map(
                          (user) => ListTile(
                            leading: user.isAuthorized
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                    size: 35,
                                  )
                                : const Icon(
                                    Icons.close_rounded,
                                    color: Colors.red,
                                    size: 35,
                                  ),
                            title: Text(
                              '${user.name.toString().capitalize()} ${user.surname.toString().capitalize()}',
                            ),
                            subtitle: user.isTeacher!
                                ? Text('Teacher - ${user.id}')
                                : Text('Student - ${user.id}'),
                            onTap: () async => _showStudentProfileAlertDialog(
                              context,
                              user,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Tooltip(
            message: 'Scan a barcode',
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(232, 52, 93, 1.0),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ScanWidget()),
              ),
              child: const Text('Scan'),
            ),
          ),
        )
      ],
    );
  }
}
