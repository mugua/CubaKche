import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/user/user_model.dart';
import '../../services/index.dart';

class UserUpdate extends StatefulWidget {
  @override
  _StateUserUpdate createState() => _StateUserUpdate();
}

class _StateUserUpdate extends State<UserUpdate> with AfterLayoutMixin {
  TextEditingController userEmail;
  TextEditingController userPassword;
  TextEditingController userDisplayName;
  TextEditingController userNiceName;
  TextEditingController userUrl;
  TextEditingController userPhone;
  TextEditingController currentPassword;

  String avatar;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    setState(() {
      userEmail = TextEditingController(text: user.email);
      userPassword = TextEditingController(text: "");
      currentPassword = TextEditingController(text: "");
      userDisplayName = TextEditingController(text: user.name);
      userNiceName = TextEditingController(text: user.nicename);
      userUrl = TextEditingController(text: user.userUrl);
      if (user.firstName != null && alphanumeric.hasMatch(user.firstName)) {
        userPhone = TextEditingController(text: user.firstName);
      }
      avatar = user.picture;
    });
  }

  void updateUserInfo() {
    final user = Provider.of<UserModel>(context, listen: false).user;
    setState(() {
      isLoading = true;
    });
    Services().widget.updateUserInfo(
        loggedInUser: user,
        onError: (e) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e)));
          setState(() {
            isLoading = false;
          });
        },
        onSuccess: (param) {
          Provider.of<UserModel>(context, listen: false).updateUser(param);
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        },
        currentPassword: currentPassword.text,
        userDisplayName: userDisplayName.text,
        userEmail: userEmail.text,
        userNiceName: userNiceName.text,
        userUrl: userUrl.text,
        userPassword: userPassword.text);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).backgroundColor,
      body: GestureDetector(
        onTap: () {
          Utils.hideKeyboard(context);
        },
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(100, 10),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 8)
                        ]),
                    child: avatar != null
                        ? Image.network(
                            avatar,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(150),
                          color: Theme.of(context).primaryColorLight),
                      child: avatar != null
                          ? Image.network(
                              avatar,
                              width: 150,
                              height: 150,
                            )
                          : Icon(
                              Icons.person,
                              size: 120,
                            ),
                    ),
                  ),
//                  Align(
//                    alignment: Alignment.bottomCenter,
//                    child: GestureDetector(
//                      onTap: () => Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => Scaffold(
//                            appBar: AppBar(),
//                            body: WebView(
//                              javascriptMode: JavascriptMode.unrestricted,
//                              initialUrl: 'https://en.gravatar.com/',
//                            ),
//                          ),
//                        ),
//                      ),
//                      child: Container(
//                        margin: EdgeInsets.only(left: 80),
//                        padding: const EdgeInsets.all(7),
//                        decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(100),
//                            color: Colors.grey.withOpacity(0.4)),
//                        child: Icon(
//                          Icons.mode_edit,
//                          size: 20,
//                        ),
//                      ),
//                    ),
//                  ),
                  SafeArea(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Text(S.of(context).email,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).accentColor,
                              )),
                          Container(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              controller: userEmail,
                              enabled: !user.isSocial,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(S.of(context).displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).accentColor,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColorLight,
                                border: Border.all(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 1.5)),
                            child: TextField(
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              controller: userDisplayName,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(S.of(context).niceName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).accentColor,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).primaryColorLight,
                              border: Border.all(
                                color: Theme.of(context).primaryColorLight,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              controller: userNiceName,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                              S.of(context).url,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).accentColor,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: Theme.of(context).primaryColorLight,
                                    width: 1.5)),
                            child: TextField(
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              controller: userUrl,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Services()
                              .widget
                              .renderCurrentPassInputforEditProfile(
                                  context: context,
                                  currentPassword: currentPassword),
                          if (!user.isSocial)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(S.of(context).newPassword,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).accentColor,
                                    )),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                          width: 1.5)),
                                  child: TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: InputBorder.none),
                                    controller: userPassword,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: updateUserInfo,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Container(
                                    height: 20,
                                    width: 100,
                                    child: isLoading
                                        ? SpinKitCircle(
                                            color: Colors.white,
                                            size: 20.0,
                                          )
                                        : Center(
                                            child: Text(
                                              S.of(context).update,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                          ),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
