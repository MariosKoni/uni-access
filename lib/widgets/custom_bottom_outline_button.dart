import 'package:flutter/material.dart';

class CustomBottomOutlineButton extends StatelessWidget {
  const CustomBottomOutlineButton(
      {Key? key,
      required String hintMessage,
      required double width,
      required double height,
      required VoidCallback onPressedMethod,
      required IconData icon,
      required String label})
      : _hintMessage = hintMessage,
        _width = width,
        _height = height,
        _onPressedMethod = onPressedMethod,
        _icon = icon,
        _label = label,
        super(key: key);

  final String _hintMessage;
  final double _width;
  final double _height;
  final VoidCallback? _onPressedMethod;
  final IconData _icon;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _hintMessage,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(fixedSize: Size(_width, _height)),
        onPressed: _onPressedMethod,
        icon: Icon(_icon),
        label: Text(_label),
      ),
    );
  }
}
