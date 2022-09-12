import 'package:flutter/material.dart';

class DialogWidget extends StatefulWidget {
  const DialogWidget({
    Key? key,
    required String titleText,
    required Widget content,
    VoidCallback? confirmFunction,
    VoidCallback? cancelFunction,
    Future<void>? asyncConfirmFunction,
  })  : _titleText = titleText,
        _content = content,
        _confirmFunction = confirmFunction,
        _cancelFunction = cancelFunction,
        _asyncConfirmFunction = asyncConfirmFunction,
        super(key: key);

  final String _titleText;
  final Widget _content;
  final VoidCallback? _confirmFunction;
  final VoidCallback? _cancelFunction;
  final Future<void>? _asyncConfirmFunction;

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
        title: Text(
          widget._titleText,
          style: const TextStyle(color: Colors.black),
        ),
        content: widget._content,
        actions: [
          Tooltip(
            message: 'Confirm',
            child: TextButton(
              onPressed: widget._confirmFunction ??
                  () async => widget._asyncConfirmFunction,
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
