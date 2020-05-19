import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/product/product.dart';
import '../../../screens/cart/cart.dart';
import '../../../widgets/product/opencart_product_option.dart';
import '../product_variant_mixin.dart';

mixin OpencartVariantMixin on ProductVariantMixin {
  Map<String, dynamic> selectedOptions = Map<String, dynamic>();
  Map<String, double> productExtraPrice = Map<String, double>();

  Future<void> getProductVariantions(
      {context,
      Product product,
      onLoad({productInfo, variations, mapAttribute, variation})}) async {
    updateVariation(null, null);
    return;
  }

  bool couldBePurchased(productVariation, product, mapAttribute) {
    final isAvailable =
        productVariation != null ? productVariation.sku != null : true;
    return isPurchased(productVariation, product, mapAttribute, isAvailable);
  }

  void onSelectProductVariant(attr, val, variations, mapAttribute, onFinish) {
    mapAttribute.update(attr.name, (value) {
      final option = attr.options
          .firstWhere((o) => o["label"] == val.toString(), orElse: () => null);
      if (option != null) {
        return option["value"].toString();
      }
      return val.toString();
    }, ifAbsent: () => val.toString());
    final productVariantion = updateVariation(variations, mapAttribute);
    onFinish(mapAttribute, productVariantion);
  }

  List<Widget> getProductAttributeWidget(
      lang, Product product, mapAttribute, onSelectProductVariant) {
    List<Widget> listWidget = [];
    if (product.options != null && product.options.isNotEmpty) {
      product.options.forEach((option) {
        listWidget.add(OpencartOptionInput(
          value: selectedOptions[option["product_option_id"]],
          option: option,
          onChanged: (selected) {
            selectedOptions.addAll(Map<String, dynamic>.from(selected));
          },
          onPriceChanged: (extraPrice) {
            productExtraPrice.addAll(Map<String, double>.from(extraPrice));
          },
        ));
      });
    }
    return listWidget;
  }

  List<Widget> getProductTitleWidget(context, productVariation, product) {
    final isAvailable =
        productVariation != null ? productVariation.sku != null : true;
    return makeProductTitleWidget(
        context, productVariation, product, isAvailable);
  }

  List<Widget> getBuyButtonWidget(context, productVariation, product,
      mapAttribute, maxQuantity, quantity, addToCart, onChangeQuantity) {
    final isAvailable =
        productVariation != null ? productVariation.sku != null : true;
    return makeBuyButtonWidget(context, productVariation, product, mapAttribute,
        maxQuantity, quantity, addToCart, onChangeQuantity, isAvailable);
  }

  @override
  void addToCart(context, Product product, quantity, productVariation,
      [buyNow = false, bool inStock = false]) {
    if (!inStock) {
      return;
    }

    final cartModel = Provider.of<CartModel>(context, listen: false);
    if (product.type == "external") {
      openWebView(context, product);
      return;
    }

    double extraPrice = productExtraPrice.keys.fold(0.0, (sum, key) {
      return sum + productExtraPrice[key];
    });
    product.price = (double.parse(product.price) + extraPrice).toString();

    String message = cartModel.addProductToCart(
        product: product,
        quantity: quantity,
        variation: productVariation,
        options: selectedOptions);

    if (message.isNotEmpty) {
      showFlash(
        context: context,
        duration: Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).errorColor,
            controller: controller,
            style: FlashStyle.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              message: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
    } else {
      if (buyNow) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: CartScreen(isModal: true, isBuyNow: true),
            ),
            fullscreenDialog: true,
          ),
        );
      }
      showFlash(
        context: context,
        duration: Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            borderRadius: BorderRadius.circular(3.0),
            backgroundColor: Theme.of(context).primaryColor,
            controller: controller,
            style: FlashStyle.floating,
            position: FlashPosition.top,
            horizontalDismissDirection: HorizontalDismissDirection.horizontal,
            child: FlashBar(
              icon: Icon(
                Icons.check,
                color: Colors.white,
              ),
              title: Text(
                product.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15.0,
                ),
              ),
              message: Text(
                S.of(context).addToCartSucessfully,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
