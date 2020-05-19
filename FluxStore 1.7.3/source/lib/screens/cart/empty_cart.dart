import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/leaves.png',
                  width: 120,
                  height: 120,
                ),
              ),
              Column(
                children: <Widget>[
                  SizedBox(height: 60),
                  Text(S.of(context).yourBagIsEmpty,
                      style: TextStyle(
                          fontSize: 28, color: Theme.of(context).accentColor),
                      textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(S.of(context).emptyCartSubtitle,
                        style: TextStyle(
                            fontSize: 16, color: Theme.of(context).accentColor),
                        textAlign: TextAlign.center),
                  ),
                  SizedBox(height: 50)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
