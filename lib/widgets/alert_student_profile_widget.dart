import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';
import 'package:provider/provider.dart';

class AlertStudentProfileWidget extends StatefulWidget {
  const AlertStudentProfileWidget({Key? key, required UniUser user})
      : _user = user,
        super(key: key);

  final UniUser _user;

  @override
  State<AlertStudentProfileWidget> createState() =>
      _AlertStudentProfileWidgetState();
}

class _AlertStudentProfileWidgetState extends State<AlertStudentProfileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();

    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        title: const Center(
          child: Text(
            'Student Info',
            style: TextStyle(color: Colors.black),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.person_rounded, size: 150.0)),
            const Text('ID', style: TextStyle(fontWeight: FontWeight.w100)),
            Text(
              widget._user.id!,
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Name', style: TextStyle(fontWeight: FontWeight.w100)),
            Text(
              widget._user.name.toString().capitalize(),
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Surname',
                style: TextStyle(fontWeight: FontWeight.w100)),
            Text(
              widget._user.surname.toString().capitalize(),
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.w100)),
            Text(
              widget._user.email!,
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Attendences',
              style: TextStyle(fontWeight: FontWeight.w100),
            ),
            Text(
              Provider.of<SessionProvider>(context, listen: false)
                  .currentStudentAttendances
                  .toString(),
              style: const TextStyle(fontSize: 25),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Close',
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          )
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
