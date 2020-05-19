import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../common/tools.dart';
import '../../../models/address.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/coupon.dart';
import '../../../models/order/order.dart';
import '../../../models/order/order_model.dart';
import '../../../models/payment_method.dart';
import '../../../models/shipping_method.dart';
import '../../../models/user/user_model.dart';
import '../../../models/product/product.dart';
import '../../../models/product/product_variation.dart';
import '../../../screens/cart/my_cart.dart';
import '../../../screens/checkout/index.dart';
import '../../../screens/checkout/payment_webview.dart';
import '../../../services/config.dart';
import '../../../services/index.dart';
import '../../../services/opencart.dart';
import '../index.dart';
import '../product_variant_mixin.dart';
import 'opencart_variant_mixin.dart';

class OpencartWidget
    with ProductVariantMixin, OpencartVariantMixin
    implements BaseFrameworks {
  static final OpencartWidget _instance = OpencartWidget._internal();

  factory OpencartWidget() => _instance;

  OpencartWidget._internal();

  @override
  bool get enableProductReview => true;

  bool checkValidCoupon(context, Coupon coupon, String couponCode) {
    return coupon.code == couponCode;
  }

  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    bool isExisted = false;
    for (var _coupon in coupons.coupons) {
      if (checkValidCoupon(context, _coupon, code.toLowerCase())) {
        success(_coupon);
        isExisted = true;
        break;
      }
    }
    if (!isExisted) {
      error(S.of(context).couponInvalid);
    }
  }

  Future<void> doCheckout(context, {Function success, Function error}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    try {
      await OpencartApi().addItemsToCart(
          cartModel, userModel.user != null ? userModel.user.cookie : null);
      success();
    } catch (e, trace) {
      error(e.toString());
      print(trace.toString());
    }
  }

  Future<void> createOrder(context,
      {Function onLoading,
      Function success,
      Function error,
      paid = false,
      cod = false}) async {
    var listOrder = [];
    bool isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final LocalStorage storage = LocalStorage('data_order');
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);

    try {
      onLoading(true);
      final order = await Services()
          .createOrder(cartModel: cartModel, user: userModel, paid: paid);

      if (!isLoggedIn) {
        var items = storage.getItem('orders');
        if (items != null) {
          listOrder = items;
        }
        listOrder.add(order.toOrderJson(cartModel, null));
        await storage.setItem('orders', listOrder);
      }
      success(order);
    } catch (e, trace) {
      error(e.toString());
      print(trace.toString());
    }
  }

  void placeOrder(context,
      {CartModel cartModel,
      PaymentMethod paymentMethod,
      Function onLoading,
      Function success,
      Function error}) {
    if (paymentMethod.id == "cod") {
      createOrder(context,
          cod: true, onLoading: onLoading, success: success, error: error);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebview(onFinish: (number) {
            success(Order(number: number));
          }),
        ),
      );
    }
  }

  Map<String, dynamic> getPaymentUrl(context) {
    return {
      "headers": {"cookie": OpencartApi().cookie},
      "url": Config().url + "/index.php?route=checkout/confirm"
    };
  }

  @override
  Widget renderCartPageView({context, isModal, isBuyNow, pageController}) {
    return PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        MyCart(
          controller: pageController,
          isBuyNow: isBuyNow,
          isModal: isModal,
        ),
        Checkout(controller: pageController, isModal: isModal),
      ],
    );
  }

  @override
  void updateUserInfo(
      {User loggedInUser,
      context,
      onError,
      onSuccess,
      currentPassword,
      userDisplayName,
      userEmail,
      userNiceName,
      userUrl,
      userPassword}) {
    var params = {
      "user_id": loggedInUser.id,
      "display_name": userDisplayName,
      "user_email": userEmail,
      "user_nicename": userNiceName,
      "user_url": userUrl,
    };
    if (!loggedInUser.isSocial && userPassword.isNotEmpty) {
      params["user_pass"] = userPassword;
    }
    if (!loggedInUser.isSocial && currentPassword.isNotEmpty) {
      params["current_pass"] = currentPassword;
    }
    Services().updateUserInfo(params, loggedInUser.cookie).then((value) {
      var param = value['data'] ?? value;
      param['password'] = userPassword;
      onSuccess(param);
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  Widget renderCurrentPassInputforEditProfile({context, currentPassword}) {
    // TODO: implement renderCurrentPassInputforEditProfile
    return Container();
  }

  @override
  Future<void> onLoadedAppConfig(callback) {
    // TODO: implement onLoadedAppConfig
    return null;
  }

  @override
  Widget renderVariantCartItem(variation) {
    return Container();
  }

  @override
  void loadShippingMethods(context, Address address, bool beforehand) {
    if (beforehand) {
      return;
    }
    final cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      final token = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user.cookie
          : null;
      Provider.of<ShippingMethodModel>(context, listen: false)
          .getShippingMethods(
              address: address,
              token: token,
              checkoutId: cartModel.getCheckoutId());
    });
  }

  @override
  Future<Order> cancelOrder(BuildContext context, Order order) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (order.status == 'cancelled' || order.status == 'canceled') return order;
    await Services().updateOrder(order.id,
        status: 'cancelled', token: userModel.user.cookie);
    order.status = "canceled";
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: userModel);
    return order;
  }

  Widget renderButtons(Order order, cancelOrder, createRefund) {
    return Container();
  }

  @override
  String getPriceItemInCart(
      Product product, ProductVariation variation, String currency) {
    return Tools.getCurrecyFormatted(product.price, currency: currency);
  }
}
