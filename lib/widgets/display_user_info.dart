import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter_uni_access/utils/capitalize_first_letter.dart';

import 'package:flutter_uni_access/models/uni_user.dart';

class DisplayUserInfo extends StatelessWidget {
  final UniUser uniUser;

  DisplayUserInfo(this.uniUser);

  @override
  Widget build(BuildContext context) {
    int _denominator;
    if (uniUser.isTeacher!) {
      _denominator = 2;
    } else {
      _denominator = 3;
    }

    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      color: Theme.of(context).colorScheme.secondary,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height / _denominator,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0)),
                  image: DecorationImage(
                      image: NetworkImage(uniUser.image!), fit: BoxFit.cover))),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ',
                style: Theme.of(context).textTheme.headline5,
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
                style: Theme.of(context).textTheme.headline5,
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
                style: Theme.of(context).textTheme.headline5,
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
                style: Theme.of(context).textTheme.headline5,
              ),
              Text(
                !uniUser.isTeacher! ? 'Student' : 'Teacher',
                style: Theme.of(context).textTheme.headline5,
              )
            ],
          ),
          if (!uniUser.isTeacher!)
            Column(
              children: [
                const Divider(color: Colors.white),
                QrImage(
                  data: uniUser.id!,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                )
              ],
            )
        ]),
      ),
    );
  }
}
