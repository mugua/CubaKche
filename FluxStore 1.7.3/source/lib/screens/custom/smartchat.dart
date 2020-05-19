import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/user/user_model.dart';
import '../../widgets/common/fab_circle_menu.dart';

class SmartChat extends StatefulWidget {
  final User user;
  final EdgeInsets margin;

  SmartChat({this.user, this.margin});

  @override
  _SmartChatState createState() => _SmartChatState();
}

class _SmartChatState extends State<SmartChat> with WidgetsBindingObserver {
  bool canLaunchAppURL;

  @override
  void initState() {
    super.initState();
    // With this, we will be able to check if the permission is granted or not
    // when returning to the application
    WidgetsBinding.instance.addObserver(this);
  }

  IconButton getIconButton(
      IconData iconData, double iconSize, Color iconColor, String appUrl) {
    return IconButton(
      icon: Icon(
        iconData,
        size: iconSize,
        color: iconColor,
      ),
      onPressed: () async {
        print(appUrl);
        if (await canLaunch(appUrl)) {
          if (appUrl.contains('http') && !appUrl.contains('wa.me')) {
            _openChat(appUrl);
          } else {
            print(appUrl);
            await launch(appUrl);
          }
          setState(() {
            setState(() {
              canLaunchAppURL = true;
            });
          });
        } else {
          setState(() {
            canLaunchAppURL = false;
          });
        }
        if (!canLaunchAppURL) {
          final snackBar = SnackBar(
            content: Text(
              S.of(context).canNotLaunch,
            ),
            action: SnackBarAction(
              label: S.of(context).undo,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        }
      },
    );
  }

  void _openChat(String url) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => WebviewScaffold(
          withJavascript: true,
          appCacheEnabled: true,
          resizeToAvoidBottomInset: true,
          url: url,
          appBar: AppBar(
            title: Text(S.of(context).message),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            elevation: 0.0,
          ),
          withZoom: true,
          withLocalStorage: true,
          hidden: true,
          initialChild: Container(child: kLoadingWidget(context)),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  List<Widget> getFabIconButton() {
    List<Widget> listWidget = [];

    for (int i = 0; i < config.smartChat.length; i++) {
      switch (config.smartChat[i]['app']) {
        default:
          listWidget.add(
            getIconButton(
              config.smartChat[i]['iconData'],
              35,
              Theme.of(context).primaryColorLight,
              config.smartChat[i]['app'],
            ),
          );
      }
    }

    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      child: Container(
        width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        height: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        child: FabCircularMenu(
          child: Container(),
          fabOpenIcon: Icon(Icons.chat, color: Colors.white),
          ringColor: Theme.of(context).primaryColor,
          ringWidth: 100.0,
          ringDiameter: 250.0,
          fabMargin: widget.margin ?? EdgeInsets.only(bottom: 0),
          options: getFabIconButton(),
        ),
      ),
    );
  }
}
