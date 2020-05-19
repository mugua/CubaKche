import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/product/product.dart';
import '../../models/product/product_model.dart';
import '../../models/product/product_variation.dart';
import '../../services/helper/flash_helper.dart';
import '../../services/index.dart';
import '../../widgets/common/webview.dart';

class ProductVariant extends StatefulWidget {
  final Product product;

  ProductVariant(this.product);

  @override
  StateProductVariant createState() => StateProductVariant(product);
}

class StateProductVariant extends State<ProductVariant> {
  Product product;
  ProductVariation productVariation;

  StateProductVariant(this.product);

  final services = Services();
  Map<String, String> mapAttribute = HashMap();
  List<ProductVariation> variations = [];

  int quantity = 1;

  /// Get product variants
  Future<void> getProductVariantions() async {
    await services.widget.getProductVariantions(
        context: context,
        product: product,
        onLoad: ({productInfo, variations, mapAttribute, variation}) {
          setState(() {
            if (productInfo != null) {
              product = productInfo;
            }
            this.variations = variations;
            this.mapAttribute = mapAttribute;
            if (variation != null) {
              productVariation = variation;
              Provider.of<ProductModel>(context, listen: false)
                  .changeProductVariation(productVariation);
            }
          });
        });
  }

  @override
  void initState() {
    super.initState();
    getProductVariantions();
  }

  @override
  void dispose() {
    FlashHelper.dispose();
    super.dispose();
  }

  /// Support Affiliate product
  void openWebView() {
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
            child: Text(S.of(context).notFound),
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
                )));
  }

  /// Add to Cart & Buy Now function
  void addToCart([buyNow = false, bool inStock = false]) {
    services.widget.addToCart(
        context, product, quantity, productVariation, buyNow, inStock);
  }

  /// check limit select quality by maximum available stock
  int getMaxQuantity() {
    int limitSelectQuantity = kProductDetail['maxAllowQuantity'] ?? 100;
    if (product.stockQuantity != null) {
      limitSelectQuantity =
          math.min(product.stockQuantity, kProductDetail['maxAllowQuantity']);
    }
    return limitSelectQuantity;
  }

  /// Check The product is valid for purchase
  bool couldBePurchased() {
    return services.widget
        .couldBePurchased(productVariation, product, mapAttribute);
  }

  void onSelectProductVariant(attr, val) {
    services.widget.onSelectProductVariant(attr, val, variations, mapAttribute,
        (mapAttribute, variation) {
      setState(() {
        this.mapAttribute = mapAttribute;
      });
      if (variation != null) {
        productVariation = variation;
        Provider.of<ProductModel>(context, listen: false)
            .changeProductVariation(variation);
      }
    });
  }

  List<Widget> getProductAttributeWidget() {
    final lang = Provider.of<AppModel>(context, listen: false).locale ?? 'en';
    return services.widget.getProductAttributeWidget(
        lang, product, mapAttribute, onSelectProductVariant);
  }

  List<Widget> getBuyButtonWidget() {
    return services.widget.getBuyButtonWidget(context, productVariation,
        product, mapAttribute, getMaxQuantity(), quantity, addToCart, (val) {
      setState(() {
        quantity = val;
      });
    });
  }

  List<Widget> getProductTitleWidget() {
    return services.widget
        .getProductTitleWidget(context, productVariation, product);
  }

  @override
  Widget build(BuildContext context) {
    FlashHelper.init(context);

    return Column(
      children: <Widget>[
        ...getProductTitleWidget(),
        ...getProductAttributeWidget(),
        ...getBuyButtonWidget(),
      ],
    );
  }
}
