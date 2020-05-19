import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/cart/cart_model.dart';
import '../../models/coupon.dart';
import '../../services/index.dart';

class ShoppingCartSummary extends StatefulWidget {
  ShoppingCartSummary({this.model, this.onApplyCoupon});

  final CartModel model;
  final Function onApplyCoupon;

  @override
  _ShoppingCartSummaryState createState() => _ShoppingCartSummaryState();
}

class _ShoppingCartSummaryState extends State<ShoppingCartSummary> {
  final services = Services();
  Coupons coupons;
  bool _enable = true;
  bool _loading = false;
  Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];

  @override
  void initState() {
    super.initState();
    if (widget.model.couponObj != null && widget.model.couponObj.amount > 0) {
      _enable = false;
    }
    getCoupon();
  }

  Future<void> getCoupon() async {
    try {
      coupons = await services.getCoupons();
    } catch (e) {
//      print(e.toString());
    }
  }

  void showError(String message) {
    setState(() => _loading = false);
    final snackBar = SnackBar(
      content: Text(S.of(context).warning(message)),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  /// Check coupon code
  void checkCoupon(String couponCode) {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
      return;
    }

    setState(() => _loading = true);

    Services().widget.applyCoupon(context, coupons: coupons, code: couponCode,
        success: (Coupon coupon) {
      widget.model.couponObj = coupon;
      setState(() {
        _enable = false;
        _loading = false;
      });
    }, error: showError);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    final smallAmountStyle = TextStyle(color: Theme.of(context).accentColor);
    final largeAmountStyle =
        TextStyle(color: Theme.of(context).accentColor, fontSize: 20);
    final formatter = NumberFormat.currency(
        symbol: defaultCurrency['symbol'],
        decimalDigits: defaultCurrency['decimalDigits']);
    final couponController = TextEditingController();

    String couponMsg = S.of(context).couponMsgSuccess;
    if (widget.model.couponObj != null) {
      if (widget.model.couponObj.discountType == "percent") {
        couponMsg += "${widget.model.couponObj.amount}%";
      } else {
        couponMsg += " - ${formatter.format(widget.model.couponObj.amount)}";
      }
    }
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: Container(
        width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: _enable
                          ? BoxDecoration(
                              color: Theme.of(context).backgroundColor)
                          : BoxDecoration(color: Color(0xFFF1F2F3)),
                      child: TextField(
                        controller: couponController,
                        enabled: _enable && !_loading,
                        decoration: InputDecoration(
                            labelText: _enable
                                ? S.of(context).couponCode
                                : widget.model.couponObj.code,
                            //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                            contentPadding: EdgeInsets.all(2)),
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  RaisedButton.icon(
                    elevation: 0.0,
                    label: Text(_loading
                        ? S.of(context).loading
                        : _enable ? S.of(context).apply : S.of(context).remove),
                    icon: Icon(
                      FontAwesomeIcons.clipboardCheck,
                      size: 15,
                    ),
                    color: Theme.of(context).primaryColorLight,
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      if (_enable) {
                        checkCoupon(couponController.text);
                      } else {
                        setState(() {
                          _enable = true;
                          widget.model.couponObj = null;
                          widget.model.discountAmount = 0.0;
                        });
                      }
                    },
                  )
                ],
              ),
            ),
            _enable
                ? Container()
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 40, right: 40, bottom: 15),
                    child: Text(
                      couponMsg,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColorLight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(S.of(context).products,
                                style: smallAmountStyle),
                          ),
                          Text(
                            "x${widget.model.totalCartQuantity}",
                            style: smallAmountStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text('${S.of(context).total}:',
                                style: largeAmountStyle),
                          ),
                          Text(
                            Tools.getCurrecyFormatted(widget.model.getTotal(),
                                currency: currency),
                            style: largeAmountStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
