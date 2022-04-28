import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';

class DisplayStudentClasses extends StatelessWidget {
  final List<StudentClassesCard> cards;

  DisplayStudentClasses(this.cards);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 5,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0))),
          color: Theme.of(context).colorScheme.secondary,
          child: Column(children: [
            Text(cards[index].lab!),
            ListView.builder(
                itemCount: cards[index].subjects?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text(cards[index].subjects![index]);
                }),
          ]),
        );
      },
    );
  }
}
