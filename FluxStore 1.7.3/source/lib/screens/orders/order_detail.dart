import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/order/order_model.dart';
import '../../models/order/order_note.dart';
import '../../models/product/product.dart';
import '../../models/user/user_model.dart';
import '../../services/index.dart';
import '../../widgets/orders/tracking.dart';

class OrderDetail extends StatefulWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderDetail({this.order, this.onRefresh});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final services = Services();
  String tracking;
  Order order;

  @override
  void initState() {
    super.initState();
    getTracking();
    order = widget.order;
  }

  void getTracking() {
    services.getAllTracking().then((onValue) {
      if (onValue != null && onValue.trackings != null) {
        for (var track in onValue.trackings) {
          if (track.orderId == order.number) {
            setState(() {
              tracking = track.trackingNumber;
            });
          }
        }
      }
    });
  }

  void cancelOrder() {
    Services().widget.cancelOrder(context, order).then((onValue) {
      setState(() {
        order = onValue;
      });
    });
  }

  void createRefund() {
    if (order.status == 'refunded') return;
    services.updateOrder(order.id, status: 'refunded').then((onValue) {
      setState(() {
        order = onValue;
      });
      Provider.of<OrderModel>(context, listen: false).getMyOrder(
          userModel: Provider.of<UserModel>(context, listen: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          S.of(context).orderNo + " #${order.number}",
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: <Widget>[
            for (var item in order.lineItems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child: Text(item.name)),
                    SizedBox(
                      width: 15,
                    ),
                    Text("x${item.quantity}"),
                    SizedBox(width: 20),
                    Text(
                      Tools.getCurrecyFormatted(item.total),
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    if (!kPaymentConfig['EnableShipping'] ||
                        !kPaymentConfig['EnableAddress'])
                      DownloadButton(item.productId)
                  ],
                ),
              ),
            Container(
              decoration:
                  BoxDecoration(color: Theme.of(context).primaryColorLight),
              padding: const EdgeInsets.all(15),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).subtotal,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      Text(
                        Tools.getCurrecyFormatted(order.lineItems
                            .fold(0, (sum, e) => sum + double.parse(e.total))),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  (order.shippingMethodTitle != null &&
                          kPaymentConfig['EnableShipping'])
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              S.of(context).shippingMethod,
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                            Text(
                              order.shippingMethodTitle,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        )
                      : Container(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).totalTax,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      Text(
                        Tools.getCurrecyFormatted(order.totalTax),
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        S.of(context).total,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      Text(
                        Tools.getCurrecyFormatted(order.total),
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            tracking != null ? SizedBox(height: 20) : Container(),
            tracking != null
                ? GestureDetector(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: <Widget>[
                          Text("${S.of(context).trackingNumberIs} "),
                          Text(
                            tracking,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      return Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebviewScaffold(
                            url: "${afterShip['tracking_url']}/$tracking",
                            appBar: AppBar(
                              leading: GestureDetector(
                                child: Icon(Icons.arrow_back_ios),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              title: Text(S.of(context).trackingPage),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                S.of(context).status,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 15),
            Align(
              child: TimelineTracking(
                axisTimeLine: kLayoutWeb ? Axis.horizontal : Axis.vertical,
                status: order.status,
                createdAt: order.createdAt,
                dateModified: order.dateModified,
              ),
              alignment: Alignment.center,
            ),
            SizedBox(height: 40),
            Services().widget.renderButtons(order, cancelOrder, createRefund),
            SizedBox(height: 40),
            Text(S.of(context).shippingAddress,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (order.billing != null)
              Text(
                order.billing.street +
                    ", " +
                    order.billing.city +
                    ", " +
                    getCountryName(order.billing.country),
              ),
            if (order.status == "processing")
              Column(
                children: <Widget>[
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 45,
                          child: RaisedButton(
                              textColor: Colors.white,
                              color: HexColor("#056C99"),
                              onPressed: refundOrder,
                              child: Text(
                                  S.of(context).refundRequest.toUpperCase(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700))),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<OrderNote>>(
              future: services.getOrderNote(
                  userModel: userModel, orderId: order.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).orderNotes,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        snapshot.data.length,
                        (index) {
                          return Padding(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CustomPaint(
                                  painter: BoxComment(
                                      color: Theme.of(context).primaryColor),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 15,
                                          bottom: 25),
                                      child: HtmlWidget(
                                        snapshot.data[index].note,
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            height: 1.2),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  formatTime(DateTime.parse(
                                      snapshot.data[index].dateCreated)),
                                  style: TextStyle(fontSize: 13),
                                )
                              ],
                            ),
                            padding: const EdgeInsets.only(bottom: 15),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  String getCountryName(country) {
    try {
      return CountryPickerUtils.getCountryByIsoCode(country).name;
    } catch (err) {
      return country;
    }
  }

  Future<void> refundOrder() async {
    _showLoading();
    try {
      await services.updateOrder(order.id, status: "refunded");
      _hideLoading();
      widget.onRefresh();
      Navigator.of(context).pop();
    } catch (err) {
      _hideLoading();

      final snackBar = SnackBar(
        content: Text(err.toString()),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(5.0)),
            padding: EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ),
        );
      },
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  String formatTime(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }
}

class BoxComment extends CustomPainter {
  final Color color;

  BoxComment({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 10);
    path.lineTo(30, size.height - 10);
    path.lineTo(20, size.height);
    path.lineTo(20, size.height - 10);
    path.lineTo(0, size.height - 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DownloadButton extends StatefulWidget {
  final String id;

  DownloadButton(this.id);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final services = Services();
    return InkWell(
      onTap: () async {
        setState(() {
          isLoading = true;
        });

        Product product = await services.getProduct(widget.id);
        setState(() {
          isLoading = false;
        });
        await Share.share(product.files[0]);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: <Widget>[
            isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 15.0,
                      height: 15.0,
                      child: Center(
                        child: kLoadingWidget(context),
                      ),
                    ),
                  )
                : Icon(
                    Icons.file_download,
                    color: Theme.of(context).primaryColor,
                  ),
            Text(
              S.of(context).download,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
