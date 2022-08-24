import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class FormOptionWidget extends StatefulWidget {
  FormOptionWidget({
    Key? key,
    required List<String> option,
    required String titleOption,
  })  : _option = option,
        _titleOption = titleOption,
        super(key: key);

  final List<String> _option;
  final String _titleOption;

  String? _selectedItem = null;

  @override
  State<FormOptionWidget> createState() => _FormOptionState();
}

class _FormOptionState extends State<FormOptionWidget> {
  @override
  void initState() {
    super.initState();

    _updateSessionSelectedItem(widget._option.first, context);
  }

  void _updateSessionSelectedItem(String? newValue, BuildContext context) {
    if (newValue!.contains(':')) {
      Provider.of<SessionProvider>(context, listen: false).selectedSubject =
          newValue;
    } else {
      Provider.of<SessionProvider>(context, listen: false).selectedLab =
          newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0)),
              dropdownColor: Theme.of(context).backgroundColor,
              hint: Text(widget._titleOption),
              value: widget._selectedItem ??= null,
              icon: const Tooltip(
                  message: 'Expand options',
                  child: Icon(Icons.arrow_drop_down_rounded)),
              underline: Container(
                height: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              onChanged: Provider.of<SessionProvider>(context, listen: false)
                      .startedScanning
                  ? null
                  : (String? newValue) {
                      setState(() {
                        _updateSessionSelectedItem(newValue, context);
                        widget._selectedItem = newValue!;
                      });
                    },
              items: widget._option.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
