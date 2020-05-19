import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../generated/l10n.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  WebViewScreen({this.title, @required this.url});

  @override
  _StateWebViewScreen createState() => _StateWebViewScreen();
}

class _StateWebViewScreen extends State<WebViewScreen> {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).noBackHistoryItem)),
                  );
                  return;
                }
              },
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () async {
                if (await _controller.canGoForward()) {
                  await _controller.goForward();
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).noForwardHistoryItem)),
                  );
                  return;
                }
              },
              child: Icon(Icons.arrow_forward_ios),
            ),
          )
        ],
      ),
      body: Platform.isMacOS || Platform.isWindows || Platform.isFuchsia
          ? Center(
              child: Text(S.of(context).thisPlatformNotSupportWebview),
            )
          : WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.url,
              onWebViewCreated: (WebViewController controller) {
                _controller = controller;
              },
            ),
    );
  }
}
