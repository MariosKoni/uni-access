import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_uni_access/screens/auth_screen.dart';

import 'package:flutter_uni_access/screens/student_info_screen.dart';
import 'package:flutter_uni_access/screens/tabs_screen.dart';
import 'package:flutter_uni_access/screens/teacher_info_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniAccess',
      theme:
          ThemeData(primarySwatch: Colors.blue, backgroundColor: Colors.grey),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            final _user = FirebaseAuth.instance.currentUser;
            CollectionReference _users =
                FirebaseFirestore.instance.collection('users');

            var _id = '';
            late bool _isTeacher;

            if (_user != null) {
              _id = _user.uid;

              return FutureBuilder<DocumentSnapshot>(
                  future: _users.doc(_id).get(),
                  builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      print('Has error');
                    }

                    if (snapshot.hasData && !snapshot.data!.exists) {
                      print('Document does not exist');
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      if (!data['isTeacher']) {
                        return TabsScreen(_id);
                      } else {
                        return TeacherInfoScreen();
                      }
                    }

                    return const Center(child: CircularProgressIndicator());
                  });
            }
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
