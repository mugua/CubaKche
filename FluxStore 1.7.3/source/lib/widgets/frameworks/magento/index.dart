import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

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
import '../../../models/user/user_model.dart';
import '../../../models/product/product.dart';
import '../../../models/product/product_variation.dart';
import '../../../screens/cart/my_cart.dart';
import '../../../screens/checkout/index.dart';
import '../../../services/index.dart';
import '../../../services/magento.dart';
import '../index.dart';
import '../product_variant_mixin.dart';
import 'magento_payment.dart';
import 'magento_variant_mixin.dart';

class MagentoWidget
    with ProductVariantMixin, MagentoVariantMixin
    implements BaseFrameworks {
  static final MagentoWidget _instance = MagentoWidget._internal();

  factory MagentoWidget() => _instance;

  MagentoWidget._internal();

  @override
  bool get enableProductReview => false;

  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error}) async {
    try {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      await MagentoApi().addItemsToCart(
          cartModel, userModel.user != null ? userModel.user.cookie : null);
      final discountAmount = await MagentoApi().applyCoupon(
          userModel.user != null ? userModel.user.cookie : null, code);
      cartModel.discountAmount = discountAmount;
      success(Coupon.fromJson({
        "amount": discountAmount,
        "code": code,
        "discount_type": "fixed_cart"
      }));
    } catch (err) {
      error(err.toString());
    }
  }

  Future<void> doCheckout(context, {Function success, Function error}) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    final userModel = Provider.of<UserModel>(context, listen: false);
    try {
      await MagentoApi().addItemsToCart(
          cartModel, userModel.user != null ? userModel.user.cookie : null);
      if (cartModel.couponObj != null) {
        final discountAmount = await MagentoApi().applyCoupon(
            userModel.user != null ? userModel.user.cookie : null,
            cartModel.couponObj.code);
        cartModel.discountAmount = discountAmount;
      }
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
    final LocalStorage storage = LocalStorage('data_order');
    var listOrder = [];
    bool isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
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
      if (kMagentoPayments.contains(cartModel.paymentMethod.id)) {
        onLoading(false);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MagentoPayment(
                    onFinish: (order) => success(order),
                    order: order,
                  )),
        );
      } else {
        success(order);
      }
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
    print(paymentMethod.id);

    createOrder(context,
        cod: true, onLoading: onLoading, success: success, error: error);
  }

  Map<String, dynamic> getPaymentUrl(context) {
    return null;
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
    if (currentPassword.isEmpty && !loggedInUser.isSocial) {
      onError('Please enter current password');
      return;
    }

    var params = {
      "user_id": loggedInUser.id,
      "display_name": userDisplayName,
      "user_email": userEmail,
      "user_nicename": userNiceName,
      "user_url": userUrl,
    };
    if (userEmail == loggedInUser.email && !loggedInUser.isSocial) {
      params["user_email"] = "";
    }
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.of(context).currentPassword,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            )),
        SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: Theme.of(context).primaryColorLight, width: 1.5)),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(border: InputBorder.none),
            controller: currentPassword,
          ),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  @override
  Future<void> onLoadedAppConfig(callback) async {
    return await MagentoApi().getAllAttributes();
  }

  @override
  Widget renderVariantCartItem(variation) {
    return Container();
  }

  @override
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
    await Services().updateOrder(order.id,
        status: 'cancelled', token: userModel.user.cookie);
    order.status = "canceled";
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: userModel);
    return order;
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
