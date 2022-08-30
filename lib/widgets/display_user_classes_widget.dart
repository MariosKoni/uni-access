import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/student_classes_card.dart';

class DisplayUserClasses extends StatelessWidget {
  final StudentClassesCard card;

  const DisplayUserClasses(this.card);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      color: Theme.of(context).colorScheme.secondary,
      child: ExpansionTile(
        leading: const Icon(Icons.school),
        title: Text('Lab: ${card.lab!}'),
        subtitle: const Text('Tap the arrow to see the subjects.'),
        collapsedIconColor: const Color.fromRGBO(66, 183, 42, 1.0),
        childrenPadding: const EdgeInsets.all(8.0),
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: card.subjects?.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Center(
                    child: Text(
                      '${card.subjects![index].keys.first} - ${card.subjects![index].values.first}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  if (index != ((card.subjects?.length)! - 1))
                    const Divider(
                      thickness: 2.0,
                    )
                  else
                    Container()
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
