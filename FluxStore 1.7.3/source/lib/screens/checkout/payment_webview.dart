import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../../common/constants.dart';
import '../../services/index.dart';

class PaymentWebview extends StatefulWidget {
  final String url;
  final Function onFinish;

  PaymentWebview({this.onFinish, this.url});

  @override
  State<StatefulWidget> createState() {
    return PaymentWebviewState();
  }
}

class PaymentWebviewState extends State<PaymentWebview> with AfterLayoutMixin {
  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    initWebView();
  }

  void initWebView() {
    final flutterWebviewPlugin = FlutterWebviewPlugin();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      print("URL: " + url);
      if (url.contains("/order-received/")) {
        final items = url.split("/order-received/");
        if (items.length > 1) {
          final number = items[1].split("/")[0];
          widget.onFinish(number);
          Navigator.of(context).pop();
        }
      }
      if (url.contains("checkout/success")) {
        widget.onFinish("0");
        Navigator.of(context).pop();
      }

      // shopify url final checkout
      if (url.contains("thank_you")) {
        widget.onFinish("0");
        Navigator.of(context).pop();
      }
    });

//    var givenJS = rootBundle.loadString('assets/extra_webview.js');
//    // ignore: missing_return
//    givenJS.then((String js) {
//      flutterWebviewPlugin.onStateChanged.listen((viewState) async {
//        if (viewState.type == WebViewState.finishLoad) {
//          await flutterWebviewPlugin.evalJavascript(js);
//        }
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> checkoutMap = {"url": "", "headder": {}};

    if (widget.url != null) {
      checkoutMap['url'] = widget.url;
    } else {
      checkoutMap = Services().widget.getPaymentUrl(context);
    }

    return WebviewScaffold(
      withJavascript: true,
      appCacheEnabled: true,
      url: checkoutMap['url'],
      headers: checkoutMap['headers'],
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(child: kLoadingWidget(context)),
    );
  }
}
