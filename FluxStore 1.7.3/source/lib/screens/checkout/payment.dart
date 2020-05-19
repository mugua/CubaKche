import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/payment_method.dart';
import '../../models/user/user_model.dart';
import '../../services/index.dart';
import '../../widgets/payment/paypal/index.dart';
import '../../widgets/payment/tap/index.dart';

class PaymentMethods extends StatefulWidget {
  final Function onBack;
  final Function onFinish;
  final Function(bool) onLoading;

  PaymentMethods({this.onBack, this.onFinish, this.onLoading});

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String selectedId;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      Provider.of<PaymentMethodModel>(context, listen: false).getPaymentMethods(
          address: cartModel.address,
          shippingMethod: cartModel.shippingMethod,
          token: userModel.user != null ? userModel.user.cookie : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);

    return ListenableProvider.value(
        value: paymentMethodModel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(S.of(context).paymentMethods, style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text(
              S.of(context).chooseYourPaymentMethod,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).accentColor.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            Consumer<PaymentMethodModel>(builder: (context, model, child) {
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

              if (selectedId == null && model.paymentMethods.isNotEmpty) {
                selectedId =
                    model.paymentMethods.firstWhere((item) => item.enabled).id;
              }

              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.paymentMethods.length; i++)
                    model.paymentMethods[i].enabled
                        ? Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedId = model.paymentMethods[i].id;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: model.paymentMethods[i].id ==
                                              selectedId
                                          ? Theme.of(context).primaryColorLight
                                          : Colors.transparent),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Radio(
                                            value: model.paymentMethods[i].id,
                                            groupValue: selectedId,
                                            onChanged: (i) {
                                              setState(() {
                                                selectedId = i;
                                              });
                                            }),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              if (Payments[model
                                                      .paymentMethods[i].id] !=
                                                  null)
                                                Image.asset(
                                                  Payments[model
                                                      .paymentMethods[i].id],
                                                  width: 120,
                                                  height: 30,
                                                ),
                                              if (Payments[model
                                                      .paymentMethods[i].id] ==
                                                  null)
                                                Text(
                                                  model.paymentMethods[i].title,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .accentColor
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Divider(height: 1)
                            ],
                          )
                        : Container()
                ],
              );
            }),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).subtotal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                    ),
                  ),
                  Text(
                      Tools.getCurrecyFormatted(cartModel.getSubTotal(),
                          currency: cartModel.currency),
                      style: TextStyle(fontSize: 14, color: kGrey400))
                ],
              ),
            ),
            kPaymentConfig['EnableShipping']
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${cartModel.shippingMethod.title}",
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          Tools.getCurrecyFormatted(cartModel.getShippingCost(),
                              currency: cartModel.currency),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),
            if (cartModel.getCoupon() != '')
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S.of(context).discount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).accentColor.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      cartModel.getCoupon(),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                            fontSize: 14,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                          ),
                    )
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).total,
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).accentColor),
                  ),
                  Text(
                    Tools.getCurrecyFormatted(cartModel.getTotal(),
                        currency: cartModel.currency),
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).accentColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                    onPressed: () => placeOrder(paymentMethodModel, cartModel),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: Text(S.of(context).placeMyOrder.toUpperCase()),
                  ),
                ),
              ),
            ]),
            Center(
              child: FlatButton(
                onPressed: () {
                  widget.onBack();
                },
                child: Text(
                  S.of(context).goBackToReview,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void placeOrder(paymentMethodModel, cartModel) {
    if (paymentMethodModel.paymentMethods.isNotEmpty) {
      final paymentMethod = paymentMethodModel.paymentMethods
          .firstWhere((item) => item.id == selectedId);

      Provider.of<CartModel>(context, listen: false)
          .setPaymentMethod(paymentMethod);

      /// Use Native payment
      if (paymentMethod.id.contains(PaypalConfig["paymentMethodId"]) &&
          PaypalConfig["enabled"] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaypalPayment(
              onFinish: (number) {
                createOrder(paid: true);
              },
            ),
          ),
        );
      } else if (paymentMethod.id.contains(TapConfig["paymentMethodId"]) &&
          TapConfig["enabled"] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TapPayment(onFinish: (number) {
                    createOrder(paid: true);
                  })),
        );
      } else {
        /// Use WebView Payment per frameworks
        Services().widget.placeOrder(
          context,
          cartModel: cartModel,
          onLoading: widget.onLoading,
          paymentMethod: paymentMethod,
          success: (order) {
            widget.onFinish(order);
            widget.onLoading(false);
          },
          error: (message) {
            widget.onLoading(false);
            final snackBar = SnackBar(
              content: Text(message),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
        );
      }
    }
  }

  Future<void> createOrder({paid = false, cod = false}) async {
    widget.onLoading(true);
    await Services().widget.createOrder(
      context,
      paid: paid,
      cod: cod,
      success: (order) {
        widget.onFinish(order);
        widget.onLoading(false);
      },
      error: (message) {
        widget.onLoading(false);
        final snackBar = SnackBar(
          content: Text(message),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      },
    );
  }
}
