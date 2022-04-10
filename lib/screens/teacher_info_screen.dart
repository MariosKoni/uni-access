import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class TeacherInfoScreen extends StatelessWidget {
  const TeacherInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Info'),
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Text(
          'Teacher info screen',
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
