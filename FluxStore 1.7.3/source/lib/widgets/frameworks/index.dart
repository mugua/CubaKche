import 'package:flutter/material.dart';

import '../../models/address.dart';
import '../../models/cart/cart_model.dart';
import '../../models/coupon.dart';
import '../../models/order/order.dart';
import '../../models/payment_method.dart';
import '../../models/product/product.dart';
import '../../models/product/product_variation.dart';
import '../../models/user/user_model.dart';

export 'magento/index.dart';
export 'opencart/index.dart';
export 'woocommerce/index.dart';

abstract class BaseFrameworks {
  bool get enableProductReview;

  Future<void> doCheckout(context, {Function success, Function error});

  Future<void> applyCoupon(context,
      {Coupons coupons, String code, Function success, Function error});

  Future<void> createOrder(context,
      {Function success, Function error, paid = false, cod = false});

  void placeOrder(context,
      {CartModel cartModel,
      PaymentMethod paymentMethod,
      Function onLoading,
      Function success,
      Function error});

  Map<String, dynamic> getPaymentUrl(context);

  /// For Cart Screen
  Widget renderCartPageView(
      {isModal, isBuyNow, pageController, BuildContext context});

  Widget renderVariantCartItem(variation);

  String getPriceItemInCart(
      Product product, ProductVariation variation, String currency);

  /// For Update User Screen
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
      userPassword});

  Widget renderCurrentPassInputforEditProfile({context, currentPassword});

  /// For app model
  Future<void> onLoadedAppConfig(callback);

  /// For Shipping Address checkout
  void loadShippingMethods(context, Address address, bool beforehand);

  /// For Order Detail Screen
  Future<Order> cancelOrder(BuildContext context, Order order);

  Widget renderButtons(Order order, cancelOrder, createRefund);

  /// For product variant
  Future<void> getProductVariantions(
      {context,
      Product product,
      onLoad({productInfo, variations, mapAttribute, variation})});

  bool couldBePurchased(productVariation, Product product, mapAttribute);

  void onSelectProductVariant(attr, val, variations, mapAttribute, onFinish);

  List<Widget> getProductAttributeWidget(
      lang, Product product, mapAttribute, onSelectProductVariant);

  List<Widget> getProductTitleWidget(
      context, productVariation, Product product);

  List<Widget> getBuyButtonWidget(context, productVariation, Product product,
      mapAttribute, maxQuantity, quantity, addToCart, onChangeQuantity);

  void addToCart(context, Product product, quantity, productVariation,
      [buyNow = false, bool inStock = false]);
}
