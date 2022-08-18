import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {
  const DialogWidget(
      {Key? key,
      required String titleText,
      required String contentText,
      required VoidCallback confirmFunction,
      VoidCallback? cancelFunction})
      : _titleText = titleText,
        _contentText = contentText,
        _confirmFunction = confirmFunction,
        _cancelFunction = cancelFunction,
        super(key: key);

  final String _titleText;
  final String _contentText;
  final VoidCallback _confirmFunction;
  final VoidCallback? _cancelFunction;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      title: Text(_titleText, style: const TextStyle(color: Colors.black)),
      content: Text(_contentText),
      actions: [
        Tooltip(
          message: 'Confirm',
          child: TextButton(
              onPressed: _confirmFunction, child: const Text('Confirm')),
        ),
        Tooltip(
          message: 'Cancel',
          child: TextButton(
              onPressed: _cancelFunction ?? () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
        ),
      ],
    );
  }
}
