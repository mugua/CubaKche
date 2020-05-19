import '../../../common/tools.dart';
import '../../payment_method.dart';
import '../../product/product.dart';
import '../../product/product_variation.dart';

mixin CartMixin {
  PaymentMethod paymentMethod;

  String notes;
  String currency;

  final Map<String, Product> item = {};

  final Map<String, ProductVariation> productVariationInCart = {};

  // The IDs and quantities of products currently in the cart.
  final Map<String, int> productsInCart = {};

  int get totalCartQuantity => productsInCart.values.fold(0, (v, e) => v + e);

  double getSubTotal() {
    return productsInCart.keys.fold(0.0, (sum, key) {
      if (productVariationInCart[key] != null &&
          productVariationInCart[key].price != null &&
          productVariationInCart[key].price.isNotEmpty) {
        return sum +
            double.parse(productVariationInCart[key].price) *
                productsInCart[key];
      } else {
        String productId = Product.cleanProductID(key);

        String price =
            Tools.getPriceProductValue(item[productId], currency, onSale: true);
        if (price.isNotEmpty) {
          return sum + double.parse(price) * productsInCart[key];
        }
        return sum;
      }
    });
  }

  void setPaymentMethod(data) {
    paymentMethod = data;
  }

  // Returns the Product instance matching the provided id.
  Product getProductById(String id) {
    print(item[id]);
    return item[id];
  }

  // Returns the Product instance matching the provided id.
  ProductVariation getProductVariationById(String key) {
    return productVariationInCart[key];
  }

  String getCheckoutId() {
    return '';
  }
}
