import 'package:flutter/material.dart';
import 'package:flutter_uni_access/models/uni_user.dart';

import 'package:flutter_uni_access/widgets/display_user_info.dart';

class UsertInfoScreen extends StatelessWidget {
  final UniUser user;

  UsertInfoScreen(this.user);

  @override
  Widget build(BuildContext context) {
    return DisplayUserInfo(user);
  }
}
