import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../models/cart/cart_model.dart';
import 'services.dart';

class TapPayment extends StatefulWidget {
  final Map<String, dynamic> params;
  final Function onFinish;

  TapPayment({this.params, this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return TapPaymentState();
  }
}

class TapPaymentState extends State<TapPayment> {
  String checkoutUrl;
  TapServices services = TapServices();

  @override
  void initState() {
    super.initState();
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.startsWith(TapConfig["RedirectUrl"])) {
        final uri = Uri.parse(url);
        final tapId = uri.queryParameters['tap_id'];
        if (tapId != null) {
          widget.onFinish(tapId);
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
        }
      }
    });

    Future.delayed(Duration.zero, () async {
      try {
        final params = getOrderParams();
        try {
          final url = await services.getCheckoutUrl(params);
          setState(() {
            checkoutUrl = url;
          });
        } catch (e) {
          Scaffold.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(e.toString()),
            ));
        }
      } catch (e) {
        Scaffold.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(e.toString()),
          ));
      }
    });
  }

  Map<String, dynamic> getOrderParams() {
    CartModel cartModel = Provider.of<CartModel>(context, listen: false);

    return {
      "amount": cartModel.getTotal(),
      "currency": "KWD",
      "threeDSecure": true,
      "save_card": false,
      "receipt": {"email": false, "sms": true},
      "customer": {
        "first_name": cartModel.address.firstName,
        "last_name": cartModel.address.lastName,
        "email": cartModel.address.email
      },
      "source": {"id": "src_all"},
      "post": {"url": "http://your_website.com/post_url"},
      "redirect": {"url": TapConfig["RedirectUrl"]}
    };
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl != null) {
      return WebviewScaffold(
        url: checkoutUrl,
        appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            backgroundColor: Colors.white,
            elevation: 0.0),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(child: kLoadingWidget(context)),
      );
    } else {
      return Scaffold(
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
