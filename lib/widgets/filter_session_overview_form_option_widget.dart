import 'package:flutter/material.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:provider/provider.dart';

class FilterSessionOverviewFormOptionWidget extends StatefulWidget {
  const FilterSessionOverviewFormOptionWidget({
    Key? key,
    required List<String> options,
    required String titleOption,
  })  : _options = options,
        _titleOption = titleOption,
        super(key: key);

  final List<String> _options;
  final String _titleOption;

  @override
  State<FilterSessionOverviewFormOptionWidget> createState() =>
      _FilterSessionOverviewFormOptionWidgetState();
}

class _FilterSessionOverviewFormOptionWidgetState
    extends State<FilterSessionOverviewFormOptionWidget> {
  String? _selectedItem;

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
          onChanged: (String? newValue) {
            Provider.of<SessionOverviewProvider>(context, listen: false)
                .applyFilter(
              widget.key.toString().compareTo("[<'lab'>]") == 0 ? 1 : 2,
              newValue,
            );
            setState(() {
              _selectedItem = newValue;
            });
          },
          items: widget._options.map<DropdownMenuItem<String>>((value) {
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
