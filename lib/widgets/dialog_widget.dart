import 'package:flutter/material.dart';

class DialogWidget extends StatefulWidget {
  const DialogWidget({
    Key? key,
    required String titleText,
    required String contentText,
    required VoidCallback confirmFunction,
    VoidCallback? cancelFunction,
  })  : _titleText = titleText,
        _contentText = contentText,
        _confirmFunction = confirmFunction,
        _cancelFunction = cancelFunction,
        super(key: key);

  final String _titleText;
  final String _contentText;
  final VoidCallback _confirmFunction;
  final VoidCallback? _cancelFunction;

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.elasticInOut,
    );

    animationController.addListener(() {});

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
        title: Text(widget._titleText,
            style: const TextStyle(color: Colors.black)),
        content: Text(widget._contentText),
        actions: [
          Tooltip(
            message: 'Confirm',
            child: TextButton(
              onPressed: widget._confirmFunction,
              child: const Text('Confirm'),
            ),
          ),
          Tooltip(
            message: 'Cancel',
            child: TextButton(
              onPressed:
                  widget._cancelFunction ?? () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
