import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/product/product.dart';
import '../../models/product/product_attribute.dart';
import '../../models/product/product_model.dart';
import '../../models/product/product_variation.dart';
import '../../screens/cart/cart.dart';
import '../common/webview.dart';
import '../product/product_variant.dart';

mixin ProductVariantMixin {
  ProductVariation updateVariation(variations, mapAttribute) {
    if (variations != null) {
      var variation = variations.firstWhere((item) {
        bool isCorrect = true;
        for (var attribute in item.attributes) {
          if (attribute.option != mapAttribute[attribute.name] &&
              (attribute.id != null ||
                  checkVariantLengths(variations, mapAttribute))) {
            isCorrect = false;
            break;
          }
        }
        if (isCorrect) {
          for (var key in mapAttribute.keys.toList()) {
            bool check = false;
            for (var attribute in item.attributes) {
              if (key == attribute.name) {
                check = true;
                break;
              }
            }
            if (!check) {
              Attribute att = Attribute()
                ..id = null
                ..name = key
                ..option = mapAttribute[key];
              item.attributes.add(att);
            }
          }
        }
        return isCorrect;
      }, orElse: () {
        return null;
      });
      if (variation == null && variations.isNotEmpty) variation = variations[0];
      return variation;
    }
    return null;
  }

  bool checkVariantLengths(variations, mapAttribute) {
    for (var variant in variations) {
      if (variant.attributes.length == mapAttribute.keys.toList().length) {
        bool check = true;
        for (var i = 0; i < variant.attributes.length; i++) {
          if (variant.attributes[i].option !=
              mapAttribute[variant.attributes[i].name]) {
            check = false;
            break;
          }
        }
        if (check) {
          return true;
        }
      }
    }
    return false;
  }

  bool isPurchased(productVariation, product, mapAttribute, isAvailable) {
    bool inStock =
        productVariation != null ? productVariation.inStock : product.inStock;

    final isValidAttribute = product.attributes.length == mapAttribute.length &&
        (product.attributes.length == mapAttribute.length ||
            product.type != "variable");

    return inStock && isValidAttribute && isAvailable;
  }

  List<Widget> makeProductTitleWidget(
      context, productVariation, product, isAvailable) {
    List<Widget> listWidget = [];

    bool inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    String stockQuantity =
        product.stockQuantity != null ? ' (${product.stockQuantity}) ' : '';
    if (Provider.of<ProductModel>(context, listen: false).productVariation !=
        null) {
      stockQuantity = Provider.of<ProductModel>(context, listen: false)
                  .productVariation
                  .stockQuantity !=
              null
          ? ' (${Provider.of<ProductModel>(context, listen: false).productVariation.stockQuantity}) '
          : '';
    }

    if (isAvailable) {
      listWidget.add(
        SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            Text(
              "${S.of(context).availability}: ",
              style:
                  TextStyle(fontSize: 15, color: Theme.of(context).accentColor),
            ),
            product.backOrdered != null && product.backOrdered
                ? Text(
                    '${S.of(context).backOrder}',
                    style: TextStyle(
                      color: Color(0xFFEAA601),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                : Text(
                    inStock
                        ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
                        : S.of(context).outOfStock,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  )
          ],
        ),
      );

      listWidget.add(
        SizedBox(height: 10.0),
      );
    }

    return listWidget;
  }

  List<Widget> makeBuyButtonWidget(
      context,
      productVariation,
      Product product,
      mapAttribute,
      maxQuantity,
      quantity,
      addToCart,
      onChangeQuantity,
      isAvailable) {
    final ThemeData theme = Theme.of(context);

    bool inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    final isExternal = product.type == "external" ? true : false;

    return [
      SizedBox(height: 10),
      Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => addToCart(true, inStock),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isExternal
                      ? (inStock &&
                              (product.attributes.length ==
                                  mapAttribute.length) &&
                              isAvailable)
                          ? theme.primaryColor
                          : theme.disabledColor
                      : theme.primaryColor,
                ),
                child: Center(
                  child: Text(
                    ((inStock && isAvailable) || isExternal)
                        ? S.of(context).buyNow.toUpperCase()
                        : (isAvailable
                            ? S.of(context).outOfStock.toUpperCase()
                            : S.of(context).unavailable.toUpperCase()),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          if (isAvailable && inStock && !isExternal)
            Expanded(
              child: GestureDetector(
                onTap: () => addToCart(false, inStock),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: Center(
                    child: Text(
                      S.of(context).addToCart.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(width: 10),
          if (!isExternal)
            Container(
              decoration: BoxDecoration(color: theme.backgroundColor),
              child: QuantitySelection(
                value: quantity,
                color: theme.accentColor,
                limitSelectQuantity: maxQuantity,
                onChanged: onChangeQuantity,
              ),
            )
        ],
      )
    ];
  }

  /// Add to Cart & Buy Now function
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

    String message = cartModel.addProductToCart(
        product: product, quantity: quantity, variation: productVariation);

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

  /// Support Affiliate product
  void openWebView(context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Center(
            child: Text("Not found"),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebView(
          url: product.affiliateUrl,
          title: product.name,
        ),
      ),
    );
  }
}
