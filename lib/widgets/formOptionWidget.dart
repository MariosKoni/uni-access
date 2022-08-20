import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session.dart';
import 'package:provider/provider.dart';

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

  String _selectedItem = '';

  @override
  State<FormOptionWidget> createState() => _FormOptionState();
}

class _FormOptionState extends State<FormOptionWidget> {
  @override
  void initState() {
    super.initState();

    _updateSessionSelectedItem(widget._option.first, context);
    widget._selectedItem = widget._option.first;
  }

  void _updateSessionSelectedItem(String? newValue, BuildContext context) {
    if (newValue!.contains(':')) {
      Provider.of<Session>(context, listen: false).selectedSubject = newValue;
    } else {
      Provider.of<Session>(context, listen: false).selectedLab = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget._titleOption, style: Theme.of(context).textTheme.headline6),
        const SizedBox(width: 10),
        DropdownButton<String>(
          dropdownColor: Theme.of(context).colorScheme.primary,
          value: widget._selectedItem,
          icon: const Tooltip(
              message: 'Expand options',
              child: Icon(Icons.arrow_drop_down_rounded)),
          elevation: 16,
          underline: Container(
            height: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
          onChanged:
              Provider.of<Session>(context, listen: false).startedScanning
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
      ],
    );
  }
}
