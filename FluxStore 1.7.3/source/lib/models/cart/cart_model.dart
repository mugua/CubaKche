import 'cart_base.dart';
import 'cart_model_magento.dart';
import 'cart_model_shopify.dart';
import 'cart_model_woo.dart';
import 'cart_model_opencart.dart';

export 'cart_base.dart';

class CartInject {
  static final CartInject _instance = CartInject._internal();

  factory CartInject() => _instance;

  CartInject._internal();

  CartModel model;

  void init(config) {
    switch (config['type']) {
      case "magento":
        model = CartModelMagento();
        break;
      case "shopify":
        model = CartModelShopify();
        break;
      case "opencart":
        model = CartModelOpencart();
        break;
      default:
        model = CartModelWoo();
    }
    model.initData();
  }
}
