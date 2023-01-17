// ignore_for_file: depend_on_referenced_packages, cast_nullable_to_non_nullable, use_build_context_synchronously

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

// Entrypoint of the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sets the orientation of the app to portrait only
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  // Inits firebase
  await Firebase.initializeApp();

  // Run the app with MyApp as the first widget
  runApp(const MyApp());
}

// Father of all the widgets in the tree
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Since we have multiple providers in the app
    // we use MultiProvider and init all of them
    // in the first component of the tree as to
    // pass the down
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => SessionProvider(
            List.empty(growable: true),
            List.empty(growable: true),
            List.empty(growable: true),
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

      // Create the app
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
              // We subscibe to this stream in order
              // to keep track of the user's login status
              // every time it changes it will fire this
              // builder function
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, userSnapshot) {
                // If there are not data
                // redirect to the auth screen
                if (!userSnapshot.hasData) {
                  return const AuthScreen();
                }

                // current user if any
                late final user = FirebaseAuth.instance.currentUser;

                // users collections back at firebase
                late final CollectionReference users =
                    FirebaseFirestore.instance.collection('users');

                // id of the current user
                late String id;

                // If no user is present
                // redirect to auth screen
                if (user == null) {
                  return const AuthScreen();
                }

                // since id is included from the email
                // and we have easy access to the user email
                // from FirebaseAuth, take it from there
                id = user.email!.split('@').elementAt(0);

                // Find the user with the above id
                // Set the image for the given user
                // When all of this is done, procceed
                return FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    users.doc(id).get(),
                    Provider.of<UserProvider>(ctx, listen: false)
                        .setImageData(id)
                  ]),
                  builder: (_, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    if (snapshot.hasData &&
                        (snapshot.data == null || snapshot.data!.isEmpty)) {
                      return const Center(
                        child: Text('Document does not exist'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.done) {
                      // Get the user from the snapshot data
                      final uniUser = UniUser.fromFirestore(
                        snapshot.data!.elementAt(0)
                            as DocumentSnapshot<Object?>,
                      );

                      // Set his/her image
                      uniUser.image =
                          Provider.of<UserProvider>(ctx, listen: false)
                              .userImageData;

                      // Store the user in the UserProvider
                      // since we will need it down the line
                      Provider.of<UserProvider>(ctx, listen: false).user =
                          uniUser;

                      // Proccedd to the TabsScreen
                      // i.e the core app
                      return TabsScreen();
                    }

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
