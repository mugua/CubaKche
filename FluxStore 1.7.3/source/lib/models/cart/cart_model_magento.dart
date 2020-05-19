import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
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

class CartModelMagento
    with
        ChangeNotifier,
        CartMixin,
        CouponMixin,
        CurrencyMixin,
        AddressMixin,
        LocalMixin,
        ShopifyMixin,
        OpencartMixin,
        MagentoMixin
    implements CartModel {
  static final CartModelMagento _instance = CartModelMagento._internal();

  factory CartModelMagento() => _instance;

  CartModelMagento._internal();

  Future<void> initData() async {
    await getShippingAddress();
    await getCartInLocal();
    await getCurrency();
  }

  double getSubTotal() {
    return productsInCart.keys.fold(0.0, (sum, key) {
      if (productVariationInCart[key] != null &&
          productVariationInCart[key].price != null &&
          productVariationInCart[key].price.isNotEmpty) {
        return sum + double.parse(productVariationInCart[key].price) * productsInCart[key];
      } else {
        String productId = Product.cleanProductID(key);

        String price = Tools.getPriceProductValue(item[productId], currency, onSale: true);
        if (price.isNotEmpty) {
          return sum + double.parse(price) * productsInCart[key];
        }
        return sum;
      }
    });
  }

  /// Magento: get item total
  double getItemTotal({ProductVariation productVariation, Product product, int quantity = 1}) {
    double subtotal = double.parse(product.price) * quantity;
    print('getItemTotal $subtotal');
    if (discountAmount > 0) {
      return subtotal - discountAmount;
    } else {
      if (couponObj != null) {
        if (couponObj.discountType == "percent") {
          return subtotal - subtotal * couponObj.amount / 100;
        } else {
          return subtotal - (couponObj.amount * quantity);
        }
      } else {
        return subtotal;
      }
    }
  }

  /// Magento: get coupon
  String getCoupon() {
    if (discountAmount > 0) {
      return "-" + Tools.getCurrecyFormatted(discountAmount, currency: currency);
    } else {
      if (couponObj != null) {
        if (couponObj.discountType == "percent") {
          return "-${couponObj.amount}%";
        } else {
          return "-" + Tools.getCurrecyFormatted(couponObj.amount * totalCartQuantity, currency: currency);
        }
      } else {
        return "";
      }
    }
  }

  /// Magento: get total
  double getTotal() {
    double subtotal = getSubTotal();

    if (discountAmount > 0) {
      subtotal -= discountAmount;
    } else {
      if (couponObj != null) {
        if (couponObj.discountType == "percent") {
          subtotal -= subtotal * couponObj.amount / 100;
        } else {
          subtotal -= (couponObj.amount * totalCartQuantity);
        }
      }
    }
    if (kPaymentConfig['EnableShipping']) {
      subtotal += getShippingCost();
    }
    return subtotal;
  }

  /// Magento: get coupon cost
  double getCouponCost(subTotal) {
    if (discountAmount > 0) {
      return discountAmount;
    } else {
      double subtotal = getSubTotal();
      if (couponObj != null) {
        if (couponObj.discountType == "percent") {
          return subtotal * couponObj.amount / 100;
        } else {
          return couponObj.amount * totalCartQuantity;
        }
      } else {
        return 0.0;
      }
    }
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
      productSkuInCart.remove(key);
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
    productSkuInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    couponObj = null;
    notes = null;
    discountAmount = 0.0;
    notifyListeners();
  }

  void setOrderNotes(String note) {
    notes = note;
    notifyListeners();
  }

  Future getCurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currency") ?? (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
  }

  String addProductToCart({
    Product product,
    int quantity = 1,
    ProductVariation variation,
    Function notify,
    isSaveLocal = true,
    Map<String, dynamic> options,
  }) {
    String message = super.addProductToCart(
        product: product, quantity: quantity, variation: variation, isSaveLocal: isSaveLocal, notify: notifyListeners);

    var key = "${product.id}";
    if (variation != null) {
      if (variation.id != null) {
        key += "-${variation.id}";
      }
      for (var attribute in variation.attributes) {
        if (attribute.id == null) {
          key += "-" + attribute.name + attribute.option;
        }
      }
    }
    productSkuInCart[key] = variation != null ? variation.sku : product.sku;
    return message;
  }
}
