import 'package:flutter/material.dart';

import '../product/product.dart';
import '../product/product_variation.dart';
import 'mixin/address_mixin.dart';
import 'mixin/cart_mixin.dart';
import 'mixin/coupon_mixin.dart';
import 'mixin/currency_mixin.dart';
import 'mixin/local_mixin.dart';
import 'mixin/magento_mixin.dart';
import 'mixin/shopify_mixin.dart';
import 'mixin/opencart_mixin.dart';

abstract class CartModel
    with
        CartMixin,
        AddressMixin,
        LocalMixin,
        CouponMixin,
        CurrencyMixin,
        MagentoMixin,
        ShopifyMixin,
        OpencartMixin,
        ChangeNotifier {
  double getSubTotal();

  double getItemTotal({ProductVariation productVariation, Product product, int quantity = 1});

  double getTotal();

  String updateQuantity(Product product, String key, int quantity);

  void removeItemFromCart(String key);

  Product getProductById(String id);

  ProductVariation getProductVariationById(String key);

  void clearCart();

  void setOrderNotes(String note);

  void initData();

  String addProductToCart({
    Product product,
    int quantity = 1,
    ProductVariation variation,
    Function notify,
    isSaveLocal = true,
    Map<String, dynamic> options,
  });
}
