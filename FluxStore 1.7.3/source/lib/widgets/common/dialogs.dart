import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

Future<dynamic> showDialogNotInternet(BuildContext context) {
  return showDialog(
      context: context,
      child: CupertinoAlertDialog(
        title: Center(
          child: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
              ),
              Text(S.of(context).noInternetConnection),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(S.of(context).pleaseCheckInternet),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: AppSettings.openWIFISettings,
            child: Text(S.of(context).settings),
          )
        ],
      ));
}
