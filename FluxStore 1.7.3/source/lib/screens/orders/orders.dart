import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/order/order_model.dart';
import '../../models/user/user_model.dart';
import 'order_detail.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> with AfterLayoutMixin {
  final RefreshController _refreshController = RefreshController();

  @override
  void afterFirstLayout(BuildContext context) {
    refreshMyOrders();
  }

  Future<void> _onRefresh() async {
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: Provider.of<UserModel>(context, listen: false));
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await Provider.of<OrderModel>(context, listen: false)
        .loadMore(userModel: Provider.of<UserModel>(context, listen: false));
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<UserModel>(context).loggedIn;

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(
            S.of(context).orderHistory,
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.0,
        ),
        body: ListenableProvider.value(
            value: Provider.of<OrderModel>(context),
            child: Consumer<OrderModel>(builder: (context, model, child) {
              if (model.myOrders == null) {
                return Center(
                  child: kLoadingWidget(context),
                );
              }
              if (!isLoggedIn) {
                final LocalStorage storage = LocalStorage('data_order');
                var orders = storage.getItem('orders');
                var listOrder = [];
                for (var i in orders) {
                  listOrder.add(Order.fromJson(i));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Text("${listOrder.length} ${S.of(context).items}"),
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: listOrder.length,
                          itemBuilder: (context, index) {
                            return OrderItem(
                              order: listOrder[listOrder.length - index - 1],
                              onRefresh: () {},
                            );
                          }),
                    )
                  ],
                );
              }

              if (model.myOrders != null && model.myOrders.isEmpty) {
                return Center(child: Text(S.of(context).noOrders));
              }

              return Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Text(
                            "${model.myOrders.length} ${S.of(context).items}"),
                      ),
                      Expanded(
                        child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: !model.endPage,
                          onRefresh: _onRefresh,
                          onLoading: _onLoading,
                          header: WaterDropHeader(),
                          footer: kCustomFooter(context),
                          controller: _refreshController,
                          child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              itemCount: model.myOrders.length,
                              itemBuilder: (context, index) {
                                return OrderItem(
                                  order: model.myOrders[index],
                                  onRefresh: refreshMyOrders,
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                  model.isLoading
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.black.withOpacity(0.2),
                          child: Center(
                            child: kLoadingWidget(context),
                          ),
                        )
                      : Container()
                ],
              );
            })));
  }

  void refreshMyOrders() {
    Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: Provider.of<UserModel>(context, listen: false));
  }
}

class OrderItem extends StatelessWidget {
  final Order order;
  final VoidCallback onRefresh;

  OrderItem({this.order, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (order.statusUrl != null) {
              launch(order.statusUrl);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetail(
                          order: order,
                          onRefresh: onRefresh,
                        )),
              );
            }
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("#${order.number}",
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).orderDate),
              Text(
                DateFormat("dd/MM/yyyy").format(order.createdAt),
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).status),
              Text(
                order.status.toUpperCase(),
                style: TextStyle(
                    color: kOrderStatusColor[order.status] != null
                        ? HexColor(kOrderStatusColor[order.status])
                        : Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).paymentMethod),
              SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Text(
                order.paymentMethodTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).total),
              Text(
                Tools.getCurrecyFormatted(order.total),
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        SizedBox(height: 20)
      ],
    );
  }
}
