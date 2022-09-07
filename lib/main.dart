// ignore_for_file: depend_on_referenced_packages, cast_nullable_to_non_nullable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/classes_provider.dart';
import 'package:flutter_uni_access/providers/session_overview_provider.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/screens/auth_screen.dart';
import 'package:flutter_uni_access/screens/tabs_screen.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
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
          create: (context) => SessionProvider(
            List.empty(growable: true),
            List.empty(growable: true),
            List.empty(growable: true),
            List.empty(growable: true),
            {},
          ),
        ),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => SessionOverviewProvider(
            List.empty(growable: true),
            List.empty(growable: true),
            List.empty(growable: true),
            List.empty(growable: true),
            List.empty(growable: true),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ClassesProvider(
            List.empty(growable: true),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'UniAccess',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color.fromRGBO(36, 110, 233, 1.0),
            secondary: const Color.fromRGBO(240, 242, 245, 1.0),
          ),
          fontFamily: 'RobotoCondensed',
          backgroundColor: Colors.white,
        ),
        home: ShowCaseWidget(
          builder: Builder(
            builder: (_) => StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                if (userSnapshot.hasData) {
                  late final User? user = FirebaseAuth.instance.currentUser;
                  late final CollectionReference users =
                      FirebaseFirestore.instance.collection('users');

                  late String id;

                  if (user != null) {
                    id = user.uid;

                    return FutureBuilder<DocumentSnapshot>(
                      future: users.doc(id).get(),
                      builder: (_, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }

                        if (snapshot.hasData &&
                            (snapshot.data == null || !snapshot.data!.exists)) {
                          return const Center(
                            child: Text('Document does not exist'),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          final Map<String, dynamic> data =
                              snapshot.data!.data() as Map<String, dynamic>;

                          final uniUser = UniUser(
                            id: data['id'] as String,
                            name: data['name'] as String,
                            surname: data['surname'] as String,
                            email: data['email'] as String,
                            isTeacher: data['isTeacher'] as bool,
                            image: data['image'] as String,
                          );

                          Provider.of<UserProvider>(ctx, listen: false).user =
                              uniUser;

                          return TabsScreen();
                        }

                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                }
                return const AuthScreen();
              },
            ),
          ),
        ),
      ),
    );
  }
}
