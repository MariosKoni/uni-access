import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/providers/session.dart';
import 'package:flutter_uni_access/screens/new_session_screen.dart';
import 'package:flutter_uni_access/screens/user_classes_screen.dart';
import 'package:flutter_uni_access/screens/user_info_screen.dart';
import 'package:flutter_uni_access/widgets/dialog_widget.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  late final UniUser user;

  TabsScreen(this.user);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Map<String, Object>> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    if (!widget.user.isTeacher!) {
      _pages = [
        {'page': UsertInfoScreen(widget.user), 'title': 'Info'},
        {'page': UserClassesScreen(widget.user), 'title': 'Classes'}
      ];
    } else {
      _pages = [
        {'page': UsertInfoScreen(widget.user), 'title': 'Info'},
        {'page': UserClassesScreen(widget.user), 'title': 'Classes'},
        {'page': NewSessionScreen(widget.user), 'title': 'Session'}
      ];
    }
    super.initState();
  }

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkIfUserExitsFromSession(int index) async {
    if (widget.user.isTeacher!) {
      // We are on sessions screen and
      //authorization proccess has started
      if (_selectedIndex == 2 &&
          index != _selectedIndex &&
          Provider.of<Session>(context, listen: false).startedScanning) {
        await _showExitDialog(context);
      } else {
        _changeTab(index);
      }

      if (Provider.of<Session>(context, listen: false)
          .abortSessionFromTabChange) {
        _changeTab(index);
      }
    } else {
      _changeTab(index);
    }
  }

  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: ((context) => const _ExitDialogWidget()));
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
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
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.shifting,
        items: widget.user.isTeacher!
            ? const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Info',
                    tooltip: 'User info'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    label: 'Classes',
                    tooltip: 'User\'s classes'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.class_),
                    label: 'Session',
                    tooltip: 'Start a session')
              ]
            : const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Info',
                    tooltip: 'User info'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    label: 'Classes',
                    tooltip: 'User\'s classes')
              ],
        currentIndex: _selectedIndex,
        onTap: _checkIfUserExitsFromSession,
      ),
    );
  }
}

class _ExitDialogWidget extends StatelessWidget {
  const _ExitDialogWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0))),
      title: const Text(
        'Authorization cancel',
        style: TextStyle(color: Colors.black),
      ),
      content: const Text('Do you want to cancel the authorization proccess?'),
      actions: [
        Tooltip(
          message: 'Confirm',
          child: TextButton(
              onPressed: () {
                Provider.of<Session>(context, listen: false)
                    .abortSessionFromTabChange = true;
                Provider.of<Session>(context, listen: false).stopSession();
                Navigator.of(context).pop();
              },
              child: const Text('Confirm')),
        ),
        Tooltip(
          message: 'Cancel',
          child: TextButton(
              onPressed: () {
                Provider.of<Session>(context, listen: false)
                    .abortSessionFromTabChange = false;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),
        ),
      ],
    );
  }
}
