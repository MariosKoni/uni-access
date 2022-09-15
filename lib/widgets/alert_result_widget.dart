import 'package:flutter/material.dart';

class AlertResultWidget extends StatefulWidget {
  const AlertResultWidget({Key? key, required int mode, required String msg})
      : _mode = mode,
        _msg = msg,
        super(key: key);

  final int _mode;
  final String _msg;

  @override
  State<AlertResultWidget> createState() => _AlertResultWidgetState();
}

class _AlertResultWidgetState extends State<AlertResultWidget>
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
    IconData? icon;
    Color? color;

    switch (widget._mode) {
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

    return ScaleTransition(
      scale: scaleAnimation,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
        title: const Text('Result'),
        content: Row(children: [Icon(icon), Text(widget._msg)]),
        backgroundColor: color,
      ),
    );
  }
}
