import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user/user_model.dart';
import '../settings/settings.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen>
    with AutomaticKeepAliveClientMixin<UserScreen> {
  @override
  bool get wantKeepAlive => true;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userModel = Provider.of<UserModel>(context);

    return ListenableProvider.value(
      value: userModel,
      child: Consumer<UserModel>(
        builder: (context, value, child) {
          return SettingScreen(
            user: value.user,
            onLogout: () async {
              await userModel.logout();
              await _auth.signOut();
            },
          );
        },
      ),
    );
  }
}
