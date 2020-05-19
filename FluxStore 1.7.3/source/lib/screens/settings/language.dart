import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';

class Language extends StatefulWidget {
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final GlobalKey<ScaffoldState> _scaffordKey = GlobalKey<ScaffoldState>();

  void _showLoading(String language) {
    final snackBar = SnackBar(
      content: Text(
        S.of(context).languageSuccess,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
        label: language,
        onPressed: () {
          print('press OK');
        },
      ),
    );
    _scaffordKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    List<Map<String, dynamic>> languages = Utils.getLanguagesList(context);
    for (var i = 0; i < languages.length; i++) {
      list.add(
        Card(
          elevation: 0,
          margin: EdgeInsets.all(0),
          child: ListTile(
            leading: Image.asset(
              languages[i]["icon"],
              width: 30,
              height: 20,
              fit: BoxFit.cover,
            ),
            title: Text(languages[i]["name"]),
            onTap: () {
              Provider.of<AppModel>(context, listen: false)
                  .changeLanguage(languages[i]["code"], context);
              _showLoading(languages[i]["text"]);
            },
          ),
        ),
      );
      if (i < languages.length - 1) {
        list.add(
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
        );
      }
    }
    return Scaffold(
      key: _scaffordKey,
      appBar: AppBar(
        title: Text(
          S.of(context).language,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Center(
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...list,
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
