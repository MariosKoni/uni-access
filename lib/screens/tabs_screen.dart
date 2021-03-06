import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';
import 'package:flutter_uni_access/screens/new_session_screen.dart';
import 'package:flutter_uni_access/screens/user_classes_screen.dart';
import 'package:flutter_uni_access/screens/user_info_screen.dart';

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

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]['title'] as String),
        actions: [
          IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout))
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
                    icon: Icon(Icons.person), label: 'Info'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Classes'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.class_), label: 'Session')
              ]
            : const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Info'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Classes')
              ],
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
