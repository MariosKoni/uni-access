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

    // TODO: Make this run only one time!
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([_one]));
  }

  Future<void> _showStudentProfileAlertDialog(
      BuildContext context, UniUser user) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) => AlertStudentProfileWidget(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    final sessionUsers = Provider.of<SessionProvider>(context).sessionUsers;

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
                      bottomRight: Radius.circular(15.0))),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2.5,
                child: SingleChildScrollView(
                  child: sessionUsers.isEmpty
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 10),
                          child: Center(
                            child: Center(
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 100.0,
                                    color: Colors.white,
                                  ),
                                  Text('Scan a barcode'),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Showcase(
                          key: _one,
                          description: 'Tap on a user to see his/her profile',
                          child: Column(
                            children: sessionUsers
                                .map(
                                  (e) => ListTile(
                                      leading: const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                          size: 35),
                                      title: Text(
                                          '${e.name.toString().capitalize()} ${e.surname.toString().capitalize()}'),
                                      subtitle: e.isTeacher!
                                          ? Text('Teacher - ${e.id}')
                                          : Text('Student - ${e.id}'),
                                      onTap: () async {
                                        await _showStudentProfileAlertDialog(
                                            context, e);
                                      }),
                                )
                                .toList(),
                          ),
                        ),
                ),
              ),
            )),
        Center(
          child: Tooltip(
            message: 'Scan a barcode',
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ScanWidget())),
              child: const Text('Scan'),
            ),
          ),
        )
      ],
    );
  }
}
