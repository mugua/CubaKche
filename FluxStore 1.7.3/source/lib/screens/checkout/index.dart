import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/order/order_model.dart';
import 'payment.dart';
import 'review.dart';
import 'shipping_address.dart';
import 'shipping_method.dart';
import 'success.dart';

class Checkout extends StatefulWidget {
  final PageController controller;
  final bool isModal;

  Checkout({this.controller, this.isModal});

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> with AfterLayoutMixin {
  int tabIndex = 0;
  Order newOrder;
  bool isPayment = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (!kPaymentConfig['EnableAddress']) {
      setState(() {
        tabIndex = 1;
      });
      if (!kPaymentConfig['EnableShipping']) {
        setState(() {
          tabIndex = 2;
        });
        if (!kPaymentConfig['EnableReview']) {
          setState(() {
            tabIndex = 3;
            isPayment = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              S.of(context).checkout,
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: Center(
              child: GestureDetector(
                onTap: () => widget.controller.animateToPage(
                  0,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                ),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).accentColor,
                  size: 20,
                ),
              ),
            ),
            actions: <Widget>[
              if (widget.isModal != null && widget.isModal == true)
                IconButton(
                  icon: Icon(Icons.close, size: 24),
                  onPressed: () {
                    Navigator.popUntil(
                        context, (Route<dynamic> route) => route.isFirst);
                  },
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: newOrder != null
                        ? OrderedSuccess(
                            order: newOrder,
                            isModal: widget.isModal,
                            controller: widget.controller,
                          )
                        : Column(
                            children: <Widget>[
                              !isPayment
                                  ? Row(
                                      children: <Widget>[
                                        kPaymentConfig['EnableAddress']
                                            ? Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      tabIndex = 0;
                                                    });
                                                  },
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 13),
                                                        child: Text(
                                                          S
                                                              .of(context)
                                                              .address
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      tabIndex >= 0
                                                          ? ClipRRect(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          2.0),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          2.0)),
                                                              child: Container(
                                                                  height: 3.0,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor),
                                                            )
                                                          : Divider(
                                                              height: 2,
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        kPaymentConfig['EnableShipping']
                                            ? Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (cartModel.address !=
                                                            null &&
                                                        cartModel.address
                                                            .isValid()) {
                                                      setState(() {
                                                        tabIndex = 1;
                                                      });
                                                    }
                                                  },
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 13),
                                                        child: Text(
                                                          S
                                                              .of(context)
                                                              .shipping
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      tabIndex >= 1
                                                          ? Container(
                                                              height: 3.0,
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor)
                                                          : Divider(
                                                              height: 2,
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        kPaymentConfig['EnableReview']
                                            ? Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (cartModel
                                                            .shippingMethod !=
                                                        null) {
                                                      setState(() {
                                                        tabIndex = 2;
                                                      });
                                                    }
                                                  },
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 13),
                                                        child: Text(
                                                            S
                                                                .of(context)
                                                                .review
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                      tabIndex >= 2
                                                          ? Container(
                                                              height: 3.0,
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor)
                                                          : Divider(
                                                              height: 2,
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (cartModel.shippingMethod !=
                                                  null) {
                                                setState(() {
                                                  tabIndex = 3;
                                                });
                                              }
                                            },
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 13),
                                                  child: Text(
                                                      S
                                                          .of(context)
                                                          .payment
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                                tabIndex >= 3
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        2.0),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        2.0)),
                                                        child: Container(
                                                            height: 3.0,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                      )
                                                    : Divider(
                                                        height: 2,
                                                        color: Theme.of(context)
                                                            .accentColor)
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  : Container(),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  children: <Widget>[renderContent()],
                                ),
                              )
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white.withOpacity(0.36),
                child: kLoadingWidget(context),
              )
            : Container()
      ],
    );
  }

  Widget renderContent() {
    switch (tabIndex) {
      case 0:
        return ShippingAddress(onNext: () {
          Future.delayed(Duration.zero, () {
            setState(() {
              if (kPaymentConfig['EnableShipping']) {
                tabIndex = 1;
              } else {
                tabIndex = 2;
              }
            });
          });
        });
      case 1:
        return ShippingMethods(onBack: () {
          setState(() {
            tabIndex -= 1;
          });
        }, onNext: () {
          setState(() {
            tabIndex = 2;
          });
        });
      case 2:
        return Review(onBack: () {
          if (kPaymentConfig['EnableShipping'] &&
              kPaymentConfig['EnableAddress']) {
            setState(() {
              tabIndex -= 1;
            });
          }
        }, onNext: () {
          setState(() {
            tabIndex = 3;
          });
        });
      case 3:
      default:
        return PaymentMethods(
            onBack: () {
              setState(() {
                tabIndex -= 1;
              });
            },
            onFinish: (order) {
              setState(() {
                newOrder = order;
              });
              Provider.of<CartModel>(context, listen: false).clearCart();
            },
            onLoading: setLoading);
    }
  }
}
