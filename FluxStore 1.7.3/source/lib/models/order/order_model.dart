import 'package:flutter/material.dart';

import '../../services/index.dart';
import '../user/user_model.dart';
import 'order.dart';
import '../../common/constants.dart';
export 'order.dart';

class OrderModel extends ChangeNotifier {
  List<Order> myOrders;
  bool isLoading = true;
  String errMsg;
  int page = 1;
  bool endPage = false;

  Future<void> getMyOrder({UserModel userModel}) async {
    try {
      isLoading = true;
      notifyListeners();
      myOrders = await Services().getMyOrders(userModel: userModel, page: 1);
      page = 1;
      errMsg = null;
      isLoading = false;
      endPage = myOrders.isEmpty || myOrders.length < ApiPageSize;
      notifyListeners();
    } catch (err) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({UserModel userModel}) async {
    try {
      isLoading = true;
      page = page + 1;
      notifyListeners();
      var orders =
          await Services().getMyOrders(userModel: userModel, page: page);

      endPage = orders.isEmpty || orders.length < ApiPageSize;
      bool isExisted = myOrders
              .indexWhere((o) => orders.isNotEmpty && o.id == orders[0].id) >
          -1;
      if (!isExisted) {
        if (page == 0 || page == 1) {
          myOrders = orders;
        } else {
          myOrders = [...myOrders, ...orders];
        }
      } else {
        endPage = true;
      }

      errMsg = null;
      isLoading = false;
      notifyListeners();
    } catch (err) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
