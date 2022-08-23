import 'package:flutter/cupertino.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

// Defines a user provider
class UserProvider with ChangeNotifier {
  UniUser? user = null;
  bool showAnimation = true;
}
