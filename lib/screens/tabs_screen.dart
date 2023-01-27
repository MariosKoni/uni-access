import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_uni_access/providers/session_provider.dart';
import 'package:flutter_uni_access/providers/user_provider.dart';
import 'package:flutter_uni_access/screens/new_session_screen.dart';
import 'package:flutter_uni_access/screens/session_overview_screen.dart';
import 'package:flutter_uni_access/screens/user_classes_screen.dart';
import 'package:flutter_uni_access/screens/user_info_screen.dart';
import 'package:flutter_uni_access/widgets/dialog_widget.dart';
import 'package:flutter_uni_access/widgets/filters_session_overview_dialog_widget.dart';
import 'package:flutter_uni_access/widgets/new_session_dialog_widget.dart';
import 'package:provider/provider.dart';

class TabsScreen extends StatefulWidget {
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  // all the possible pages / screens of the app
  late final List<Map<String, Object>> _pages;
  // current page shown
  int _selectedIndex = 0;
  // whether to show or not the floating action button
  bool _showFloatingActionButton = true;

  // When the widget (TabsScreen) is added to the tree
  // it will fire this method.
  @override
  void initState() {
    // take the current user in our UserProvider
    final user = Provider.of<UserProvider>(context, listen: false).user!;

    // Load seperate pages for each type of user
    if (!user.isTeacher!) {
      _pages = [
        {'page': UsertInfoScreen(), 'title': 'Info'},
        {'page': UserClassesScreen(), 'title': 'Classes'}
      ];
    } else {
      _pages = [
        {'page': UsertInfoScreen(), 'title': 'Info'},
        {'page': UserClassesScreen(), 'title': 'Classes'},
        {'page': NewSessionScreen(), 'title': 'Session'},
        {'page': SessionOverviewScreen(), 'title': 'Sessions Overview'},
      ];
    }

    super.initState();
  }

  // This method is being called
  // when the user changes screen
  // taps at tab button.
  // it uses setState which
  // rebuilds the whole screen
  // and as such loads the next screen.
  // It takes the the index of the screen
  // in which the user wants to go
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This method checks whether
  // the user is in a Session state when trying
  // to change screen.
  // It takes the index of the screen in which the user
  // is currently in and whether has confirmed that
  // he/she will
  Future<void> _checkIfUserExitsFromSession(
    int index,
    bool abortFromTabChange,
  ) async {
    // Take the current user
    final user = Provider.of<UserProvider>(context, listen: false).user!;

    // If the user is not a teacher
    // then we don't care
    // and change page
    if (!user.isTeacher!) {
      _changeTab(index);
      return;
    }

    // We are on sessions screen and
    //authorization process has started
    if (_selectedIndex == 2 &&
        index != _selectedIndex &&
        Provider.of<SessionProvider>(context, listen: false).startedScanning) {
      await _showExitDialog(context);
    } else {
      _changeTab(index);
    }

    if (abortFromTabChange) {
      _changeTab(index);
    }
  }

  // Helper function for the showDialog widget.
  // It closes popup if the user presses cancel
  void _cancelChangeTabFromNewSession() {
    Provider.of<SessionProvider>(context, listen: false)
        .abortSessionFromTabChange = false;
    Navigator.of(context).pop();
  }

  // Helper function for the showDialog widget.
  // It aborts the session that the user initiated
  void _confirmChangeTabFromNewSession() {
    Provider.of<SessionProvider>(context, listen: false)
        .abortSessionFromTabChange = true;
    Provider.of<SessionProvider>(context, listen: false).stopSession();
    Navigator.of(context).pop();
  }

  // It shows a popup that warns the user that he/she's trying
  // to cancel the authorization process
  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DialogWidget(
        titleText: 'Authorization cancel',
        content: const Text('Do you want to cancel the authorization process?'),
        confirmFunction: _confirmChangeTabFromNewSession,
        cancelFunction: _cancelChangeTabFromNewSession,
      ),
    );
  }

  // Signs out the user from the app.
  // If a session is underway, it stops it.
  Future<void> _logout() async {
    if (Provider.of<SessionProvider>(context, listen: false).startedScanning) {
      Provider.of<SessionProvider>(context, listen: false).stopSession();
    }

    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut();
  }

  // If the user pressess the logout button
  // a popup is shown warning him
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DialogWidget(
        titleText: 'Logout',
        content: const Text('Are you sure you want to logout?'),
        confirmFunction: _logout,
      ),
    );
  }

  // When a user wants to start a new session
  // A bottom popup is being displayed giving him
  // all the options to choose
  // This popup can't be dismissed!
  Future<void> _showNewSessionDialog() async {
    return showModalBottomSheet<void>(
      isDismissible: false,
      enableDrag: false,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) => const NewSessionDialogWidget(),
    );
  }

  // When the user wants to filter his/her sessions
  // a bottom popup is being shown with all the options
  Future<void> _showFiltersDialog() async {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      builder: (context) => const FiltersSessionOverviewDialogWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Duration of the animation of the floating action button
    const duration = Duration(milliseconds: 300);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedIndex]['title']! as String),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Tooltip(message: 'Logout', child: Icon(Icons.logout)),
          )
        ],
      ),
      // NotificationListener widget is used to determine
      // whether the user reached the end of the scrollable
      // page and hide the floating action button (session overview)
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final scrollDirection = notification.direction;
          setState(() {
            if (scrollDirection == ScrollDirection.reverse) {
              _showFloatingActionButton = false;
            } else if (scrollDirection == ScrollDirection.forward ||
                scrollDirection == ScrollDirection.idle) {
              _showFloatingActionButton = true;
            }
          });

          return true;
        },
        child: _pages[_selectedIndex]['page']! as Widget,
      ),
      floatingActionButton: (_selectedIndex == 2 &&
                  !Provider.of<SessionProvider>(context).startedScanning) ||
              _selectedIndex == 3
          ? AnimatedSlide(
              duration: duration,
              offset:
                  _showFloatingActionButton ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: duration,
                opacity: _showFloatingActionButton ? 1 : 0,
                child: FloatingActionButton(
                  onPressed: _selectedIndex == 2
                      ? () async {
                          await Provider.of<SessionProvider>(
                            context,
                            listen: false,
                          ).populateFormData(
                            1,
                            Provider.of<UserProvider>(context, listen: false)
                                .user!
                                .id!,
                            context,
                          );
                          _showNewSessionDialog();
                        }
                      : () async => _showFiltersDialog(),
                  tooltip:
                      _selectedIndex == 2 ? 'Add a new session' : 'Add filters',
                  backgroundColor: _selectedIndex == 2
                      ? const Color.fromRGBO(232, 52, 93, 1.0)
                      : const Color.fromARGB(255, 204, 170, 49),
                  child: _selectedIndex == 2
                      ? const Icon(Icons.add)
                      : const Icon(Icons.settings),
                ),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).colorScheme.background,
        type: BottomNavigationBarType.shifting,
        items:
            Provider.of<UserProvider>(context, listen: false).user!.isTeacher!
                ? [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: 'Info',
                      tooltip: 'User info',
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.school),
                      label: 'Classes',
                      tooltip: "User's classes",
                      backgroundColor: Color.fromRGBO(66, 183, 42, 1.0),
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.class_),
                      label: 'Session',
                      tooltip: 'Start a session',
                      backgroundColor: Color.fromRGBO(232, 52, 93, 1.0),
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.list_alt_rounded),
                      label: 'Overview',
                      tooltip: 'Show sessions',
                      backgroundColor: Color.fromARGB(255, 204, 170, 49),
                    ),
                  ]
                : [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: 'Info',
                      tooltip: 'User info',
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.school),
                      label: 'Classes',
                      tooltip: "User's classes",
                      backgroundColor: Color.fromRGBO(66, 183, 42, 1.0),
                    )
                  ],
        currentIndex: _selectedIndex,
        onTap: (index) => _checkIfUserExitsFromSession(
          index,
          Provider.of<SessionProvider>(context, listen: false)
              .abortSessionFromTabChange,
        ),
      ),
    );
  }
}
