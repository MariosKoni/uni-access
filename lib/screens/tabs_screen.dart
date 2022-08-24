import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/screens/new_session_screen.dart';
import 'package:flutter_uni_access/screens/user_classes_screen.dart';
import 'package:flutter_uni_access/screens/user_info_screen.dart';
import 'package:flutter_uni_access/widgets/dialog_widget.dart';
import 'package:flutter_uni_access/widgets/new_session_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class TabsScreen extends StatefulWidget {
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Map<String, Object>> _pages;
  int _selectedIndex = 0;

  final GlobalKey _one = GlobalKey();

  @override
  void initState() {
    final UniUser user =
        Provider.of<UserProvider>(context, listen: false).user!;

    if (!user.isTeacher!) {
      _pages = [
        {'page': UsertInfoScreen(), 'title': 'Info'},
        {'page': UserClassesScreen(), 'title': 'Classes'}
      ];
    } else {
      _pages = [
        {'page': UsertInfoScreen(), 'title': 'Info'},
        {'page': UserClassesScreen(), 'title': 'Classes'},
        {'page': NewSessionScreen(), 'title': 'Session'}
      ];
    }

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase([_one]));

    super.initState();
  }

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkIfUserExitsFromSession(int index) async {
    final UniUser user =
        Provider.of<UserProvider>(context, listen: false).user!;

    if (user.isTeacher!) {
      // We are on sessions screen and
      //authorization proccess has started
      if (_selectedIndex == 2 &&
          index != _selectedIndex &&
          Provider.of<SessionProvider>(context, listen: false)
              .startedScanning) {
        await _showExitDialog(context);
      } else {
        _changeTab(index);
      }

      if (Provider.of<SessionProvider>(context, listen: false)
          .abortSessionFromTabChange) {
        _changeTab(index);
      }
    } else {
      _changeTab(index);
    }
  }

  void _cancelChangeTabFromNewSession() {
    Provider.of<SessionProvider>(context, listen: false)
        .abortSessionFromTabChange = false;
    Navigator.of(context).pop();
  }

  void _confirmChangeTabFromNewSession() {
    Provider.of<SessionProvider>(context, listen: false)
        .abortSessionFromTabChange = true;
    Provider.of<SessionProvider>(context, listen: false).stopSession();
    Navigator.of(context).pop();
  }

  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) => DialogWidget(
              titleText: 'Authorization cancel',
              contentText: 'Do you want to cancel the authorization proccess?',
              confirmFunction: _confirmChangeTabFromNewSession,
              cancelFunction: _cancelChangeTabFromNewSession,
            )));
  }

  void _logout() async {
    if (Provider.of<SessionProvider>(context, listen: false).startedScanning) {
      Provider.of<SessionProvider>(context, listen: false).stopSession();
    }

    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) => DialogWidget(
            titleText: 'Logout',
            contentText: 'Are you sure you want to logout?',
            confirmFunction: _logout,
            cancelFunction: null)));
  }

  Future<void> _showNewSessionDialog() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) => NewSessionDialogWidget()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]['title'] as String),
        actions: [
          IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Tooltip(message: 'Logout', child: Icon(Icons.logout)))
        ],
      ),
      body: _pages[_selectedIndex]['page'] as Widget,
      floatingActionButton: _selectedIndex == 2
          ? Showcase(
              key: _one,
              description: 'Tap on it, to start a new session',
              child: FloatingActionButton(
                onPressed: _showNewSessionDialog,
                tooltip: 'Add a new session',
                backgroundColor: Color.fromRGBO(232, 52, 93, 1.0),
                child: const Icon(Icons.add),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).backgroundColor,
        type: BottomNavigationBarType.shifting,
        items:
            Provider.of<UserProvider>(context, listen: false).user!.isTeacher!
                ? [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Info',
                        tooltip: 'User info',
                        backgroundColor: Theme.of(context).primaryColor),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.school),
                        label: 'Classes',
                        tooltip: 'User\'s classes',
                        backgroundColor: Color.fromRGBO(66, 183, 42, 1.0)),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.class_),
                        label: 'Session',
                        tooltip: 'Start a session',
                        backgroundColor: Color.fromRGBO(232, 52, 93, 1.0))
                  ]
                : [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'Info',
                        tooltip: 'User info',
                        backgroundColor: Theme.of(context).primaryColor),
                    const BottomNavigationBarItem(
                        icon: Icon(Icons.school),
                        label: 'Classes',
                        tooltip: 'User\'s classes',
                        backgroundColor: Color.fromRGBO(66, 183, 42, 1.0))
                  ],
        currentIndex: _selectedIndex,
        onTap: _checkIfUserExitsFromSession,
      ),
    );
  }
}
