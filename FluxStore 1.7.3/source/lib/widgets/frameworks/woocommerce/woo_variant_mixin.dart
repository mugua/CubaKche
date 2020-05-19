import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../models/product/product.dart';
import '../../../models/product/product_model.dart';
import '../../../models/product/product_variation.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_variant.dart';
import '../product_variant_mixin.dart';

mixin WooVariantMixin on ProductVariantMixin {
  Future<void> getProductVariantions(
      {context,
      Product product,
      onLoad({mapAttribute, productInfo, variation, variations})}) async {
    if (product.attributes.isEmpty) {
      return;
    }

    Map<String, String> mapAttribute = HashMap();
    List<ProductVariation> variations = [];
    Product productInfo;

    await Services().getProductVariations(product).then((value) {
      variations = value.toList();
    });

    if (variations.isEmpty) {
      for (var attr in product.attributes) {
        mapAttribute.update(attr.name, (value) => attr.options[0],
            ifAbsent: () => attr.options[0]);
      }
    } else {
      await Services().getProduct(product.id).then((onValue) {
        if (onValue != null) {
          productInfo = onValue;
        }
      });
      for (var variant in variations) {
        if (variant.price == product.price) {
          for (var attribute in variant.attributes) {
            for (var attr in product.attributes) {
              mapAttribute.update(attr.name, (value) => attr.options[0],
                  ifAbsent: () => attr.options[0]);
            }
            mapAttribute.update(attribute.name, (value) => attribute.option,
                ifAbsent: () => attribute.option);
          }
          break;
        }
        if (mapAttribute.isEmpty) {
          for (var attribute in product.attributes) {
            mapAttribute.update(attribute.name, (value) => value, ifAbsent: () {
              return attribute.options[0];
            });
          }
        }
      }
    }

    final productVariantion = updateVariation(variations, mapAttribute);
    if (productVariantion != null) {
      Provider.of<ProductModel>(context, listen: false)
          .changeProductVariation(productVariantion);
    }
    onLoad(
        productInfo: productInfo,
        variations: variations,
        mapAttribute: mapAttribute);
    return;
  }

  bool couldBePurchased(productVariation, product, mapAttribute) {
    final isAvailable =
        productVariation != null ? productVariation.id != null : true;

    return isPurchased(productVariation, product, mapAttribute, isAvailable);
  }

  void onSelectProductVariant(attr, val, variations, mapAttribute, onFinish) {
    mapAttribute.update(attr.name, (value) => val.toString(),
        ifAbsent: () => val.toString());
    final productVariantion = updateVariation(variations, mapAttribute);
    onFinish(mapAttribute, productVariantion);
  }

  List<Widget> getProductAttributeWidget(
      lang, product, mapAttribute, onSelectProductVariant) {
    List<Widget> listWidget = [];

    final checkProductAttribute =
        product.attributes != null && product.attributes.isNotEmpty;
    if (checkProductAttribute) {
      for (var attr in product.attributes) {
        if (attr.name != null && attr.name.isNotEmpty) {
          List<String> options = List<String>.from(attr.options);

          String selectedValue =
              mapAttribute[attr.name] != null ? mapAttribute[attr.name] : "";

          listWidget.add(
            BasicSelection(
              options: options,
              title: (kProductVariantLanguage[lang] != null &&
                      kProductVariantLanguage[lang][attr.name.toLowerCase()] !=
                          null)
                  ? kProductVariantLanguage[lang][attr.name.toLowerCase()]
                  : attr.name.toLowerCase(),
              type: ProductVariantLayout[attr.name.toLowerCase()] ?? 'box',
              value: selectedValue,
              onChanged: (val) => onSelectProductVariant(attr, val),
            ),
          );
          listWidget.add(
            SizedBox(height: 20.0),
          );
        }
      }
    }
    return listWidget;
  }

  List<Widget> getProductTitleWidget(context, productVariation, product) {
    final isAvailable =
        productVariation != null ? productVariation.id != null : true;
    return makeProductTitleWidget(
        context, productVariation, product, isAvailable);
  }

  List<Widget> getBuyButtonWidget(context, productVariation, product,
      mapAttribute, maxQuantity, quantity, addToCart, onChangeQuantity) {
    final isAvailable =
        productVariation != null ? productVariation.id != null : true;

    return makeBuyButtonWidget(context, productVariation, product, mapAttribute,
        maxQuantity, quantity, addToCart, onChangeQuantity, isAvailable);
  }
}
