import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/product/product.dart';
import 'services.dart';

class PaypalPayment extends StatefulWidget {
  final Function onFinish;

  PaypalPayment({this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl;
  String executeUrl;
  String accessToken;
  PaypalServices services = PaypalServices();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        }
      } catch (e) {
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  Map<String, dynamic> getOrderParams() {
    CartModel cartModel = Provider.of<CartModel>(context, listen: false);
    Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];
    List items = cartModel.productsInCart.keys.map(
      (key) {
        String productId = Product.cleanProductID(key);

        final product = cartModel.getProductById(productId);
        final variation = cartModel.getProductVariationById(key);
        final price = variation != null ? variation.price : product.price;

        return {
          "name": product.name,
          "quantity": cartModel.productsInCart[key],
          "price": price.toString(),
          "currency": defaultCurrency["currency"]
        };
      },
    ).toList();

    // this should add Shipping Cost + Coupon...

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": cartModel.getTotal().toString(),
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": cartModel.getSubTotal().toString(),
              "shipping": cartModel.getShippingCost().toString(),
              "shipping_discount":
                  ((-1.0) * cartModel.getCouponCost(cartModel.getSubTotal()))
                      .toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (kPaymentConfig['EnableShipping'] &&
                kPaymentConfig['EnableAddress'])
              "shipping_address": {
                "recipient_name": cartModel.address.firstName +
                    " " +
                    cartModel.address.lastName,
                "line1": cartModel.address.street,
                "line2": "",
                "city": cartModel.address.city,
                "country_code": cartModel.address.country,
                "postal_code": cartModel.address.zipCode,
                "phone": cartModel.address.phoneNumber,
                "state": cartModel.address.state
              },
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": PaypalConfig["returnUrl"],
        "cancel_url": PaypalConfig["cancelUrl"]
      }
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(checkoutUrl);

    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith(PaypalConfig["returnUrl"])) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              if (payerID != null) {
                services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                  widget.onFinish(id);
                  Navigator.of(context).pop();
                });
              } else {
                Navigator.of(context).pop();
              }
              Navigator.of(context).pop();
            }
            if (request.url.startsWith(PaypalConfig["cancelUrl"])) {
              Navigator.of(context).pop();
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: kGrey200,
          elevation: 0.0,
        ),
        body: Container(child: kLoadingWidget(context)),
      );
    }
  }
}
