import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../product/product.dart';
import '../product/product_variation.dart';
import 'cart_base.dart';
import 'mixin/address_mixin.dart';
import 'mixin/cart_mixin.dart';
import 'mixin/coupon_mixin.dart';
import 'mixin/currency_mixin.dart';
import 'mixin/local_mixin.dart';
import 'mixin/magento_mixin.dart';
import 'mixin/shopify_mixin.dart';
import 'mixin/opencart_mixin.dart';

class CartModelWoo
    with
        ChangeNotifier,
        CartMixin,
        MagentoMixin,
        AddressMixin,
        LocalMixin,
        CurrencyMixin,
        CouponMixin,
        ShopifyMixin,
        OpencartMixin
    implements CartModel {
  static final CartModelWoo _instance = CartModelWoo._internal();

  factory CartModelWoo() => _instance;

  CartModelWoo._internal();

  Future<void> initData() async {
    await getShippingAddress();
    await getCartInLocal();
    await getCurrency();
  }

  double getTotal() {
    double subtotal = getSubTotal();

    if (couponObj != null) {
      if (couponObj.discountType == "percent") {
        subtotal -= subtotal * couponObj.amount / 100;
      } else if (couponObj.discountType == "fixed_cart") {
        subtotal -= couponObj.amount;
      } else if (couponObj.discountType == "fixed_product") {
        subtotal -= couponObj.amount * totalCartQuantity;
      }
    }

    if (kPaymentConfig['EnableShipping']) {
      subtotal += getShippingCost();
    }
    return subtotal;
  }

  double getItemTotal({ProductVariation productVariation, Product product, int quantity = 1}) {
    double subtotal = double.parse(product.price) * quantity;
    if (productVariation != null) {
      subtotal = double.parse(productVariation.price) * quantity;
    } else {
      subtotal = double.parse(product.price) * quantity;
    }
    print('getItemTotal $subtotal');
    return subtotal;
//    if (couponObj != null) {
//      if (couponObj.discountType == "percent") {
//        return subtotal - subtotal * couponObj.amount / 100;
//      } else {
//        return subtotal - (couponObj.amount * quantity);
//      }
//    } else {
//      return subtotal;
//    }
  }

  String updateQuantity(Product product, String key, int quantity) {
    String message = '';
    int total = quantity;
    ProductVariation variation;

    if (key.contains('-')) {
      variation = getProductVariationById(key);
    }
    int stockQuantity = variation == null ? product.stockQuantity : variation.stockQuantity;

    if (product.manageStock == null || !product.manageStock) {
      productsInCart[key] = total;
    } else if (total <= stockQuantity) {
      if (product.minQuantity == null && product.maxQuantity == null) {
        productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity == null) {
        total < product.minQuantity
            ? message = 'Minimum quantity is ${product.minQuantity}'
            : productsInCart[key] = total;
      } else if (product.minQuantity == null && product.maxQuantity != null) {
        total > product.maxQuantity
            ? message = 'You can only purchase ${product.maxQuantity} for this product'
            : productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity != null) {
        if (total >= product.minQuantity && total <= product.maxQuantity) {
          productsInCart[key] = total;
        } else {
          if (total < product.minQuantity) {
            message = 'Minimum quantity is ${product.minQuantity}';
          }
          if (total > product.maxQuantity) {
            message = 'You can only purchase ${product.maxQuantity} for this product';
          }
        }
      }
    } else {
      message = 'Currently we only have $stockQuantity of this product';
    }
    if (message.isEmpty) {
      updateQuantityCartLocal(key: key, quantity: quantity);
      notifyListeners();
    }
    return message;
  }

  // Removes an item from the cart.
  void removeItemFromCart(String key) {
    if (productsInCart.containsKey(key)) {
      productsInCart.remove(key);
      productVariationInCart.remove(key);
      removeProductLocal(key);
    }
    notifyListeners();
  }

  // Removes everything from the cart.
  void clearCart() {
    clearCartLocal();
    productsInCart.clear();
    item.clear();
    productVariationInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    couponObj = null;
    notes = null;
    notifyListeners();
  }

  void setOrderNotes(String note) {
    notes = note;
    notifyListeners();
  }

  String addProductToCart({
    Product product,
    int quantity = 1,
    ProductVariation variation,
    Function notify,
    isSaveLocal = true,
    Map<String, dynamic> options,
  }) {
    return super.addProductToCart(
        product: product, quantity: quantity, variation: variation, isSaveLocal: isSaveLocal, notify: notifyListeners);
  }
}
