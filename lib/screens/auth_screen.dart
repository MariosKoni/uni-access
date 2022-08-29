import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uni_access/widgets/auth_form_widget.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(String email, String password, BuildContext ctx) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials';

      if (err.message != null) {
        message = err.message!;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: Theme.of(ctx).errorColor));

      setState(() {
        _isLoading = false;
      });
    } on FirebaseAuthException catch (err) {
      var message = 'Wrong credentials';

      if (err.message != null) {
        message = err.message!;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(message), backgroundColor: Theme.of(ctx).errorColor));

      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to UniAccess',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
            Image(
              image: AssetImage('assets/images/pada-logo.png'),
              height: MediaQuery.of(context).size.height / 3,
            ),
            AuthForm(_submitAuthForm, _isLoading),
          ],
        ),
      ),
    );
  }
}
