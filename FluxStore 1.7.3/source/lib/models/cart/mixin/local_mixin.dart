import 'package:localstorage/localstorage.dart';

import '../../../common/constants.dart';
import '../../product/product.dart';
import '../../product/product_variation.dart';
import 'cart_mixin.dart';

/// Everything relate to Local storage
mixin LocalMixin on CartMixin {
  Future<void> saveCartToLocal(
      {Product product, int quantity = 1, ProductVariation variation}) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          items.add({
            "product": product.toJson(),
            "quantity": quantity,
            "variation": variation != null ? variation.toJson() : "null"
          });
        } else {
          items = [
            {
              "product": product.toJson(),
              "quantity": quantity,
              "variation": variation != null ? variation.toJson() : "null"
            }
          ];
        }
        await storage.setItem(kLocalKey["cart"], items);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> updateQuantityCartLocal({String key, int quantity = 1}) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        List results = [];
        if (items != null && items.isNotEmpty) {
          for (var item in items) {
            final product = Product.fromLocalJson(item["product"]);
            final ids = key.split("-");
            ProductVariation variant = item["variation"] != "null"
                ? ProductVariation.fromLocalJson(item["variation"])
                : null;
            if ((product.id == ids[0].toString() && ids.length == 1) ||
                (variant != null &&
                    product.id == ids[0].toString() &&
                    // ignore: unrelated_type_equality_checks
                    variant.id == ids[1])) {
              results.add(
                {
                  "product": product.toJson(),
                  "quantity": quantity,
                  "variation": variant
                },
              );
            } else {
              results.add(item);
            }
          }
        }
        await storage.setItem(kLocalKey["cart"], results);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> clearCartLocal() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey["cart"]);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> removeProductLocal(String key) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          final ids = key.split("-");
          var item = items.firstWhere(
              (item) => Product.fromLocalJson(item["product"]).id == ids[0],
              orElse: () => null);
          if (item != null) {
            items.remove(item);
          }
          await storage.setItem(kLocalKey["cart"], items);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getCartInLocal() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        List items = await storage.getItem(kLocalKey["cart"]);
        if (items != null && items.isNotEmpty) {
          items.forEach((item) {
            addProductToCart(
                product: Product.fromLocalJson(item["product"]),
                quantity: item["quantity"],
                variation: item["variation"] != "null"
                    ? ProductVariation.fromLocalJson(item["variation"])
                    : null,
                isSaveLocal: false);
          });
        }
      }
    } catch (err) {
      print(err);
    }
  }

  // Adds a product to the cart.
  String addProductToCart({
    Product product,
    int quantity = 1,
    ProductVariation variation,
    Function notify,
    isSaveLocal = true,
  }) {
    String message = '';

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

    //Check product's quantity before adding to cart
    int total = !productsInCart.containsKey(key)
        ? quantity
        : productsInCart[key] + quantity;
    int stockQuantity =
        variation == null ? product.stockQuantity : variation.stockQuantity;
//    print('stock is here');
//    print(product.manageStock);

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
            ? message =
                'You can only purchase ${product.maxQuantity} for this product'
            : productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity != null) {
        if (total >= product.minQuantity && total <= product.maxQuantity) {
          productsInCart[key] = total;
        } else {
          if (total < product.minQuantity) {
            message = 'Minimum quantity is ${product.minQuantity}';
          }
          if (total > product.maxQuantity) {
            message =
                'You can only purchase ${product.maxQuantity} for this product';
          }
        }
      }
    } else {
      message = 'Currently we only have $stockQuantity of this product';
    }

    if (message.isEmpty) {
      item[product.id] = product;
      productVariationInCart[key] = variation;

      if (isSaveLocal) {
        saveCartToLocal(
            product: product, quantity: quantity, variation: variation);
      }
    }

    notify();
    return message;
  }
}
