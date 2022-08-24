import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/widgets/attendence_widget.dart';
import 'package:provider/provider.dart';

class NewSessionScreen extends StatefulWidget {
  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  bool _showAttendence = false;
  String _triggerButtonText = 'Start';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<SessionProvider>(context, listen: false)
          .populateFormData(
              Provider.of<UserProvider>(context, listen: false).user!),
      builder: (_, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : Card(
                  color: Theme.of(context).colorScheme.secondary,
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                          bottomRight: Radius.circular(15.0))),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 3,
                      ),
                      if (_showAttendence)
                        const AttendanceWidget()
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
                              )),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}
