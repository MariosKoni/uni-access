import 'package:flutter/material.dart';

class DisplayNewSessionForm extends StatefulWidget {
  const DisplayNewSessionForm({Key? key}) : super(key: key);

  @override
  State<DisplayNewSessionForm> createState() => _DisplayNewSessionFormState();
}

class _DisplayNewSessionFormState extends State<DisplayNewSessionForm> {
  String _lab = 'One';
  String _subject = 'One';
  bool _showAttendence = false;

  void _startAttendenceProcedure() {
    setState(() {
      _showAttendence = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      elevation: 5,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      child: Column(
        children: [
          Text(
            'Please enter the lab information to begin the procedure',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lab:', style: Theme.of(context).textTheme.headline6),
              const SizedBox(width: 10),
              DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.primary,
                value: _lab,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                elevation: 16,
                style: const TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _lab = newValue!;
                  });
                },
                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Subject:', style: Theme.of(context).textTheme.headline6),
              const SizedBox(width: 10),
              DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.primary,
                value: _subject,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                elevation: 16,
                style: const TextStyle(color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _subject = newValue!;
                  });
                },
                items: <String>['One', 'Two', 'Free', 'Four']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: !_showAttendence ? _startAttendenceProcedure : null,
              child: const Text('Start')),
          const Divider(
            color: Colors.white,
          ),
          if (_showAttendence) AttendanceWidget() else Container(),
        ],
      ),
    );
  }
}

class AttendanceWidget extends StatelessWidget {
  const AttendanceWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: const Color.fromRGBO(255, 255, 255, 0.6),
          elevation: 8,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0))),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
            child: ListView.builder(
                itemBuilder: (_, int index) => const ListTile(
                      leading: Icon(Icons.check_circle_rounded),
                      title: Text('Marios Konidaris'),
                    )),
          ),
        ));
  }
}
