import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:provider/provider.dart';

class NewSessionFormOptionWidget extends StatefulWidget {
  const NewSessionFormOptionWidget({
    Key? key,
    required List<String> option,
    required String titleOption,
  })  : _option = option,
        _titleOption = titleOption,
        super(key: key);

  final List<String> _option;
  final String _titleOption;

  @override
  State<NewSessionFormOptionWidget> createState() => _FormOptionState();
}

class _FormOptionState extends State<NewSessionFormOptionWidget> {
  String? _selectedItem;

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
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
        ),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration.collapsed(hintText: ''),
          isExpanded: true,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
          dropdownColor: Theme.of(context).backgroundColor,
          hint: Text(widget._titleOption),
          value: _selectedItem ??= null,
          icon: const Tooltip(
            message: 'Expand options',
            child: Icon(Icons.arrow_drop_down_rounded),
          ),
          onChanged: widget.key.toString().compareTo("[<'lab'>]") == 0 ||
                  (widget.key.toString().compareTo("[<'subject'>]") == 0 &&
                      Provider.of<SessionProvider>(context, listen: false)
                              .selectedLab !=
                          null)
              ? (String? newValue) async {
                  _updateSessionSelectedItem(newValue, context);
                  if (widget.key.toString().compareTo("[<'lab'>]") == 0) {
                    await Provider.of<SessionProvider>(context, listen: false)
                        .populateFormData(
                      2,
                      Provider.of<UserProvider>(context, listen: false)
                          .user!
                          .id!,
                      context,
                    );
                  }
                  setState(() {
                    _selectedItem = newValue;
                  });
                }
              : null,
          items: widget._option.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
