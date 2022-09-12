import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/widgets/attendence_widget.dart';
import 'package:flutter_uni_access/widgets/dialog_widget.dart';
import 'package:provider/provider.dart';

class NewSessionScreen extends StatelessWidget {
  Future<void> _showNewSessionReportDialog(BuildContext context) async {
    final Map<String, bool> allStudents = Provider.of<SessionProvider>(
      context,
      listen: false,
    ).allStudents!;
    final List<String> allStudentsIds = allStudents.keys.toList();

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DialogWidget(
        titleText: 'Session Report',
        content: SizedBox(
          height: 150,
          width: 150,
          child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allStudentsIds.length,
              itemBuilder: (_, index) => ListTile(
                leading: allStudents[allStudentsIds[index]] == true
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.close_rounded,
                        color: Colors.red,
                      ),
                title: Text(allStudentsIds[index]),
              ),
            ),
          ),
        ),
        asyncConfirmFunction: Provider.of<SessionProvider>(
          context,
          listen: false,
        ).saveSession(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = Provider.of<SessionProvider>(context).canSave;

    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        children: [
          if (!Provider.of<SessionProvider>(context).startedScanning)
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
            ),
          if (Provider.of<SessionProvider>(context).startedScanning)
            Column(
              children: [
                const AttendanceWidget(),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 9,
                ),
                Tooltip(
                  message: 'Save session',
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: canSave
                          ? const Color.fromRGBO(232, 52, 93, 1.0)
                          : Theme.of(context).backgroundColor,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height / 15,
                      ),
                    ),
                    onPressed: canSave
                        ? () async => _showNewSessionReportDialog(context)
                        : null,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save session'),
                  ),
                )
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.class_rounded,
                          size: 100.0,
                          color: Colors.white,
                        ),
                        Text('Register a new session')
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
