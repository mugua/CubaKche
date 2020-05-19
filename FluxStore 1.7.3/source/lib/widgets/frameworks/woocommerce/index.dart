import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/address.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/coupon.dart';
import '../../../models/order/order.dart';
import '../../../models/order/order_model.dart';
import '../../../models/payment_method.dart';
import '../../../models/shipping_method.dart';
import '../../../models/product/product.dart';
import '../../../models/product/product_variation.dart';
import '../../../models/user/user_model.dart';
import '../../../screens/cart/my_cart.dart';
import '../../../screens/checkout/index.dart';
import '../../../screens/checkout/payment_webview.dart';
import '../../../screens/checkout/webview_checkout_success.dart';
import '../../../services/index.dart';
import '../index.dart';
import '../product_variant_mixin.dart';
import 'woo_variant_mixin.dart';

class WooWidget
    with ProductVariantMixin, WooVariantMixin
    implements BaseFrameworks {
  static final WooWidget _instance = WooWidget._internal();

  factory WooWidget() => _instance;

  WooWidget._internal();

  @override
  bool get enableProductReview => true;

  bool checkValidCoupon(context, Coupon coupon, String couponCode) {
    final totalCart =
        Provider.of<CartModel>(context, listen: false).getSubTotal();

    if ((coupon.minimumAmount > totalCart && coupon.minimumAmount != 0.0) ||
        (coupon.maximumAmount < totalCart && coupon.maximumAmount != 0.0)) {
      print(coupon.minimumAmount);
      print(coupon.maximumAmount);
      return false;
    }

    if (coupon.dateExpires != null &&
        coupon.dateExpires.isBefore(DateTime.now())) {
      return false;
    }

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

    if (kPaymentConfig["EnableOnePageCheckout"]) {
      var params = Order().toJson(
          cartModel, userModel.user != null ? userModel.user.id : null, true);
      params["token"] = userModel.user != null ? userModel.user.cookie : null;
      String url = await Services().getCheckoutUrl(params);
      url = url.replaceAll("mstore-checkout", "checkout");

      /// Navigate to Webview payment
      String orderNum;
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentWebview(
                  url: url,
                  onFinish: (number) async {
                    orderNum = number;
                    cartModel.clearCart();
                  },
                )),
      );
      if (orderNum != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebviewCheckoutSuccess(
                    order: Order(number: orderNum),
                  )),
        );
      }
      return;
    }

    /// return success to navigate to Native payment
    success();
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
      if (cod && kPaymentConfig["UpdateOrderStatus"]) {
        await Services().updateOrder(order.id, status: 'processing');
      }
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
    Provider.of<CartModel>(context, listen: false)
        .setPaymentMethod(paymentMethod);

    if (paymentMethod.id == "cod") {
      createOrder(context,
          cod: true, onLoading: onLoading, success: success, error: error);
    } else {
      final user = Provider.of<UserModel>(context, listen: false).user;
      var params =
          Order().toJson(cartModel, user != null ? user.id : null, true);
      params["token"] = user != null ? user.cookie : null;
      makePaymentWebview(context, params, onLoading, success, error);
    }
  }

  Future<void> makePaymentWebview(context, Map<String, dynamic> params,
      Function onLoading, Function success, Function error) async {
    try {
      if (params["token"] == null) {
        final snackBar = SnackBar(
          content: Text("Payment Webview doesn't support Guest Checkout"),
        );
        Scaffold.of(context).showSnackBar(snackBar);
        return;
      }
      onLoading(true);
      String url = await Services().getCheckoutUrl(params);
      if (kPaymentConfig["NativeOnePageCheckout"]) {
        url = url.replaceAll("mstore-checkout", "checkout");
      }
      onLoading(false);
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentWebview(
                url: url,
                onFinish: (number) {
                  success(Order(number: number));
                })),
      );
    } catch (e, trace) {
      error(e.toString());
      print(trace.toString());
    }
  }

  Map<String, dynamic> getPaymentUrl(context) {
    return null;
  }

  @override
  Widget renderCartPageView({context, isModal, isBuyNow, pageController}) {
    bool isEmptyCart =
        Provider.of<CartModel>(context, listen: false).totalCartQuantity == 0;
    bool enableSwipping =
        !kPaymentConfig["EnableOnePageCheckout"] && !isEmptyCart;
    return PageView(
      controller: pageController,
      physics: enableSwipping ? null : NeverScrollableScrollPhysics(),
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
  Future<void> onLoadedAppConfig(callback) async {
    if (kAdvanceConfig['isCaching']) {
      final configCache = await Services().getHomeCache();
      if (configCache != null) {
        callback(configCache);
      }
    }
  }

  @override
  Widget renderVariantCartItem(variation) {
    List<Widget> list = List<Widget>();
    for (var att in variation.attributes) {
      list.add(Row(
        children: <Widget>[
          ConstrainedBox(
            child:
                Text("${att.name[0].toUpperCase()}${att.name.substring(1)}: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
            constraints: BoxConstraints(minWidth: 50.0, maxWidth: 200),
          ),
          att.name == "color"
              ? Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: HexColor(
                      kNameToHex[att.option.toLowerCase()],
                    ),
                  ),
                )
              : Expanded(child: Text(att.option)),
          Container(
            height: 10,
          )
        ],
      ));
    }

    return Column(children: list);
  }

  void loadShippingMethods(context, Address address, bool beforehand) {
    if (!beforehand) return;
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
    final newOrder = await Services().updateOrder(order.id,
        status: 'cancelled', token: userModel.user.cookie);
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: userModel);
    return newOrder;
  }

  Widget renderButtons(Order order, cancelOrder, createRefund) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: cancelOrder,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (order.status == 'cancelled' ||
                            order.status == 'canceled')
                        ? Colors.blueGrey
                        : Colors.red),
                child: Text(
                  'Cancel'.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: createRefund,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: order.status == 'refunded'
                        ? Colors.blueGrey
                        : Colors.lightBlue),
                child: Text(
                  'Refunds'.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  String getPriceItemInCart(
      Product product, ProductVariation variation, String currency) {
    return variation != null && variation.id != null
        ? Tools.getVariantPriceProductValue(variation, currency, onSale: true)
        : Tools.getPriceProduct(product, currency, onSale: true);
  }
}
