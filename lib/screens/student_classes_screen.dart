import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

class StudentClassesScreen extends StatefulWidget {
  final UniUser user;

  StudentClassesScreen(this.user);

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  CollectionReference labs = FirebaseFirestore.instance.collection('labs');
  CollectionReference subjects =
      FirebaseFirestore.instance.collection('subjects');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: labs.where('users', isEqualTo: widget.user.id).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            print(data);
            return ListTile(
              title: Text(data['id']),
              subtitle: Text(data['name']),
            );
          }).toList(),
        );
      },
    );
  }
}
