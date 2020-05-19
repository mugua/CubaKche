import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/shipping_method.dart';
import '../../services/index.dart';

class ShippingMethods extends StatefulWidget {
  final Function onBack;
  final Function onNext;

  ShippingMethods({this.onBack, this.onNext});

  @override
  _ShippingMethodsState createState() => _ShippingMethodsState();
}

class _ShippingMethodsState extends State<ShippingMethods> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      Services().widget.loadShippingMethods(context,
          Provider.of<CartModel>(context, listen: false).address, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shippingMethodModel = Provider.of<ShippingMethodModel>(context);
    final currency = Provider.of<CartModel>(context).currency;
    final totalMoney = Provider.of<CartModel>(context).getTotal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).shippingMethod,
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        ListenableProvider.value(
          value: shippingMethodModel,
          child: Consumer<ShippingMethodModel>(
            builder: (context, model, child) {
              if (model.isLoading) {
                return Container(height: 100, child: kLoadingWidget(context));
              }

              if (model.message != null) {
                return Container(
                  height: 100,
                  child: Center(
                      child: Text(model.message,
                          style: TextStyle(color: kErrorRed))),
                );
              }
              model.shippingMethods.forEach((e) {
                print('shippingMethods ${e.title}');
              });

              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.shippingMethods.length; i++)
                    if (model.shippingMethods[i].min_amount != null &&
                        totalMoney < model.shippingMethods[i].min_amount &&
                        model.shippingMethods[i].methodId == "free_shipping")
                      Container()
                    else
                      Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: i == selectedIndex
                                  ? Theme.of(context).primaryColorLight
                                  : Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Row(
                                children: <Widget>[
                                  Radio(
                                    value: i,
                                    groupValue: selectedIndex,
                                    onChanged: (i) {
                                      setState(() {
                                        selectedIndex = i;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(model.shippingMethods[i].title,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .accentColor)),
                                        SizedBox(height: 5),
                                        if (model.shippingMethods[i].cost >
                                                0.0 ||
                                            !isNotBlank(model
                                                .shippingMethods[i].classCost))
                                          Text(
                                            Tools.getCurrecyFormatted(
                                                model.shippingMethods[i].cost,
                                                currency: currency),
                                            style: TextStyle(
                                                fontSize: 14, color: kGrey400),
                                          ),
                                        if (model.shippingMethods[i].cost ==
                                                0.0 &&
                                            isNotBlank(model
                                                .shippingMethods[i].classCost))
                                          Text(
                                            model.shippingMethods[i].classCost,
                                            style: TextStyle(
                                                fontSize: 14, color: kGrey400),
                                          )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          i < model.shippingMethods.length - 1
                              ? Divider(height: 1)
                              : Container()
                        ],
                      )
                ],
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ButtonTheme(
                height: 45,
                child: RaisedButton(
                  onPressed: () {
                    if (shippingMethodModel.shippingMethods.isNotEmpty) {
                      Provider.of<CartModel>(context, listen: false)
                          .setShippingMethod(shippingMethodModel
                              .shippingMethods[selectedIndex]);
                      widget.onNext();
                    }
                  },
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: Text(S.of(context).continueToReview.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: FlatButton(
            onPressed: () {
              widget.onBack();
            },
            child: Text(
              S.of(context).goBackToAddress,
              textAlign: TextAlign.center,
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 15,
                  color: kGrey400),
            ),
          ),
        )
      ],
    );
  }
}
