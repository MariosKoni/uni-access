import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a user provider
class UserProvider with ChangeNotifier {
  UniUser? user;
  bool showAnimation = true;

  Future<UniUser> getUserFromId(String id, BuildContext context) async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    late final UniUser uniUser;

    await users.doc(id).get().then(
          (value) => uniUser = UniUser.fromFirestore(value),
          onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Could not fetch subjects'),
              backgroundColor: Theme.of(context).errorColor,
            ),
          ),
        );

    return uniUser;
  }
}
