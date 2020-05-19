import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';

class Currencies extends StatefulWidget {
  @override
  CurrenciesState createState() => CurrenciesState();
}

class CurrenciesState extends State<Currencies> with AfterLayoutMixin {
  String currency;

  @override
  void afterFirstLayout(BuildContext context) {
    currency = Provider.of<AppModel>(context, listen: false).currency;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List currencies = kAdvanceConfig["Currencies"] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).currencies,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: Center(
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          for (var i = 0; i < currencies.length; i++)
            Column(
              children: <Widget>[
                Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  child: ListTile(
                    title: Text(
                        '${currencies[i]["currency"]} (${currencies[i]["symbol"]})'),
                    onTap: () {
                      setState(() {
                        currency = currencies[i]["currency"];
                      });
                      Provider.of<AppModel>(context, listen: false)
                          .changeCurrency(currencies[i]["currency"], context);
                    },
                    trailing: currency == currencies[i]["currency"]
                        ? Icon(Icons.done)
                        : Container(
                            width: 20,
                          ),
                  ),
                ),
                if (i != currencies.length - 1)
                  Divider(
                    color: Colors.black12,
                    height: 1.0,
                    indent: 75,
                    //endIndent: 20,
                  ),
              ],
            )
        ],
      ),
    );
  }
}
