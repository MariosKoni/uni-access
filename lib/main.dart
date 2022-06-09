import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_uni_access/providers/session.dart';
import 'package:flutter_uni_access/screens/auth_screen.dart';

import 'package:flutter_uni_access/screens/tabs_screen.dart';
import 'package:provider/provider.dart';

import 'models/uni_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: ((context) => Session(List.empty(growable: true))))
      ],
      child: MaterialApp(
        title: 'UniAccess',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(secondary: const Color.fromRGBO(255, 127, 80, 1.0)),
            fontFamily: 'RobotoCondensed',
            textTheme: ThemeData.light().textTheme.copyWith(
                  bodyText1: const TextStyle(color: Colors.white),
                  bodyText2: const TextStyle(color: Colors.white),
                  headline1: const TextStyle(color: Colors.white),
                  headline4: const TextStyle(color: Colors.white),
                  headline5: const TextStyle(color: Colors.white),
                  headline6: const TextStyle(color: Colors.white),
                ),
            backgroundColor: const Color.fromRGBO(255, 127, 80, 1.0)),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              final _user = FirebaseAuth.instance.currentUser;
              CollectionReference _users =
                  FirebaseFirestore.instance.collection('users');

              var _id = '';
              UniUser _uniUser;

              if (_user != null) {
                _id = _user.uid;

                return FutureBuilder<DocumentSnapshot>(
                    future: _users.doc(_id).get(),
                    builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }

                      if (snapshot.hasData && !snapshot.data!.exists) {
                        return const Center(
                            child: Text('Document does not exist'));
                      }

                      if (snapshot.connectionState == ConnectionState.done) {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        _uniUser = UniUser(
                            id: data['id'],
                            name: data['name'],
                            surname: data['surname'],
                            email: data['email'],
                            isTeacher: data['isTeacher'],
                            image: data['image']);

                        return TabsScreen(_uniUser);
                      }

                      return const Center(child: CircularProgressIndicator());
                    });
              }
            }
            return const AuthScreen();
          },
        ),
      ),
    );
  }
}
