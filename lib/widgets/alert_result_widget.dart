import 'package:flutter/material.dart';

class AlertResultWidget extends StatelessWidget {
  const AlertResultWidget({Key? key, required int mode, required String msg})
      : _mode = mode,
        _msg = msg,
        super(key: key);

  final int _mode;
  final String _msg;

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    Color? color;

    switch (_mode) {
      case 1:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 2:
        icon = Icons.error_rounded;
        color = Colors.red;
        break;
      case 3:
        icon = Icons.warning_rounded;
        color = Colors.orange;
        break;
    }

    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      title: const Text('Result'),
      content: Row(children: [Icon(icon), Text(_msg)]),
      backgroundColor: color,
    );
  }
}
