import 'package:flutter/material.dart';

import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';

class DisplayStudentInfo extends StatelessWidget {
  final data;

  DisplayStudentInfo(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)),
                image: DecorationImage(
                    image: NetworkImage(data['image']), fit: BoxFit.cover)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          '${data['id']}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          '${data['name'].toString().capitalize()} ${data['surname'].toString().capitalize()}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          '${data['email']}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          !data['isTeacher'] ? 'Student' : 'Teacher',
          style: Theme.of(context).textTheme.headline4,
        )
      ],
    );
  }
}
