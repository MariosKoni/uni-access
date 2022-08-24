import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';

class DisplayUserClasses extends StatefulWidget {
  final StudentClassesCard card;

  DisplayUserClasses(this.card);

  @override
  State<DisplayUserClasses> createState() => _DisplayUserClassesState();
}

class _DisplayUserClassesState extends State<DisplayUserClasses> {
  bool _showContent = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      color: Theme.of(context).colorScheme.secondary,
      child: Column(children: [
        ListTile(
          leading: Icon(Icons.school),
          title: Center(
              child: Text(
            'Lab: ${widget.card.lab!}',
          )),
          trailing: IconButton(
            tooltip: 'Expand/Collapse user\'s classes',
            icon: Icon(
                _showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: () {
              setState(() {
                _showContent = !_showContent;
              });
            },
          ),
        ),
        _showContent
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.card.subjects?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                          '${widget.card.subjects![index].keys.first} - ${widget.card.subjects![index].values.first}',
                          style: const TextStyle(fontSize: 20),
                        )),
                      ),
                      index != ((widget.card.subjects?.length)! - 1)
                          ? const Divider(
                              thickness: 2.0,
                            )
                          : Container()
                    ],
                  );
                })
            : Container()
      ]),
    );
  }
}
