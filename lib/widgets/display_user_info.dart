import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';

class DisplayUserInfo extends StatelessWidget {
  final UniUser uniUser;

  DisplayUserInfo(this.uniUser);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      color: Theme.of(context).colorScheme.secondary,
      elevation: 5,
      child: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)),
                image: DecorationImage(
                    image: NetworkImage(uniUser.image!), fit: BoxFit.cover))),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ID: ',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              uniUser.id!,
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Name: ',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '${uniUser.name.toString().capitalize()} ${uniUser.surname.toString().capitalize()}',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'E-mail: ',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '${uniUser.email}',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Property: ',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              !uniUser.isTeacher! ? 'Student' : 'Teacher',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      ]),
    );
  }
}
