import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/config.dart';
import '../../screens/products/products.dart';
import '../../services/config.dart';
import '../../widgets/layout/layout_web.dart';
import '../app.dart';
import 'product_attribute.dart';
import 'product_model.dart';
import 'product_variation.dart';

class Product {
  String id;
  String sku;
  String name;
  String description;
  String permalink;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  double averageRating;
  int ratingCount;
  List<String> images;
  String imageFeature;
  List<ProductAttribute> attributes;
  List<ProductAttribute> infors = [];
  String categoryId;
  String videoUrl;
  List<int> groupedProducts;
  List<String> files;
  int stockQuantity;
  int minQuantity;
  int maxQuantity;
  bool manageStock;
  bool backOrdered = false;

  /// is to check the type affiliate, simple, variant
  String type;
  String affiliateUrl;
  Map<String, dynamic> multiCurrencies;
  List<ProductVariation> variations;

  List<Map<String, dynamic>> options; //for opencart

  Product.empty(this.id) {
    name = '';
    price = '0.0';
    imageFeature = '';
  }

  bool isEmptyProduct() {
    return name == '' && price == '0.0' && imageFeature == '';
  }

  Product.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["id"].toString();

      name = parsedJson["name"];
      type = parsedJson["type"];
      description = isNotBlank(parsedJson["description"])
          ? parsedJson["description"]
          : parsedJson["short_description"];
      permalink = parsedJson["permalink"];
      price = parsedJson["price"] != null ? parsedJson["price"].toString() : "";

      regularPrice = parsedJson["regular_price"] != null
          ? parsedJson["regular_price"].toString()
          : null;
      salePrice = parsedJson["sale_price"] != null
          ? parsedJson["sale_price"].toString()
          : null;
      onSale = parsedJson["on_sale"];
      inStock =
          parsedJson["in_stock"] ?? parsedJson["stock_status"] == "instock";
      backOrdered = parsedJson["backordered"] ?? false;

      averageRating = double.parse(parsedJson["average_rating"]);
      ratingCount = int.parse(parsedJson["rating_count"].toString());
      categoryId = parsedJson["categories"] != null &&
              parsedJson["categories"].length > 0
          ? parsedJson["categories"][0]["id"].toString()
          : '0';

      manageStock = parsedJson['manage_stock'] ?? false;

      // add stock limit
      if (parsedJson['manage_stock'] == true) {
        stockQuantity = parsedJson['stock_quantity'];
      }

      //minQuantity = parsedJson['meta_data']['']

      List<ProductAttribute> attributeList = [];
      parsedJson["attributes"].forEach((item) {
        if (item['visible'] && item['variation']) {
          attributeList.add(ProductAttribute.fromJson(item));
        }
      });
      attributes = attributeList;

      parsedJson["attributes"].forEach((item) {
        infors.add(ProductAttribute.fromJson(item));
      });

      List<String> list = [];
      if (parsedJson["images"] != null) {
        for (var item in parsedJson["images"]) {
          list.add(item["src"]);
        }
      }

      images = list;
      imageFeature = images[0];

      /// get video links, support following plugins
      /// - WooFeature Video: https://wordpress.org/plugins/woo-featured-video/
      ///- Yith Feature Video: https://wordpress.org/plugins/yith-woocommerce-featured-video/
      var video = parsedJson['meta_data'].firstWhere(
        (item) =>
            item['key'] == '_video_url' || item['key'] == '_woofv_video_embed',
        orElse: () => null,
      );
      if (video != null) {
        videoUrl = video['value'] is String
            ? video['value']
            : video['value']['url'] ?? '';
      }

      affiliateUrl = parsedJson['external_url'];
      multiCurrencies = parsedJson['multi-currency-prices'];

      List<int> groupedProductList = [];
      parsedJson['grouped_products'].forEach((item) {
        groupedProductList.add(item);
      });
      groupedProducts = groupedProductList;
      List<String> files = [];
      parsedJson['downloads'].forEach((item) {
        files.add(item['file']);
      });
      this.files = files;

      if (parsedJson['meta_data'] != null) {
        for (var item in parsedJson['meta_data']) {
          try {
            if (item['key'] == '_minmax_product_max_quantity') {
              int quantity = int.parse(item['value']);
              quantity == 0 ? maxQuantity = null : maxQuantity = quantity;
            }
          } catch (e) {
            print('maxQuantity $e');
          }

          try {
            if (item['key'] == '_minmax_product_min_quantity') {
              int quantity = int.parse(item['value']);
              quantity == 0 ? minQuantity = null : minQuantity = quantity;
            }
          } catch (e) {
            print('minQuantity $e');
          }
        }
      }
    } catch (e) {
      debugPrintStack();
      print(e.toString());
    }
  }

  Product.fromOpencartJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["product_id"] != null ? parsedJson["product_id"] : '0';
      name = HtmlUnescape().convert(parsedJson["name"]);
      description = parsedJson["description"];
      permalink = parsedJson["permalink"];
      regularPrice = parsedJson["price"];
      salePrice = parsedJson["special"];
      price = salePrice ?? regularPrice;
      onSale = salePrice != null;
      inStock = parsedJson["stock_status"] == "In Stock" ||
          int.parse(parsedJson["quantity"]) > 0;
      averageRating = parsedJson["rating"] != null
          ? double.parse(parsedJson["rating"].toString())
          : 0.0;
      ratingCount = parsedJson["reviews"] != null
          ? int.parse(parsedJson["reviews"].toString())
          : 0.0;
      attributes = [];

      List<String> list = [];
      if (parsedJson["images"] != null && parsedJson["images"].length > 0) {
        for (var item in parsedJson["images"]) {
          list.add(item);
        }
      }
      if (list.isEmpty && parsedJson['image'] != null) {
        list.add('${Config().url}/image/${parsedJson['image']}');
      }
      images = list;
      imageFeature = images.isNotEmpty ? images[0] : "";
      options = List<Map<String, dynamic>>.from(parsedJson['options']);
    } catch (e) {
      debugPrintStack();
      print(e.toString());
    }
  }

  Product.fromMagentoJson(Map<String, dynamic> parsedJson) {
    try {
      id = "${parsedJson["id"]}";
      sku = parsedJson["sku"];
      name = parsedJson["name"];
      permalink = parsedJson["permalink"];
      inStock = parsedJson["status"] == 1;
      averageRating = 0.0;
      ratingCount = 0;
      categoryId = "${parsedJson["category_id"]}";
      attributes = [];
    } catch (e) {
      debugPrintStack();
      print(e.toString());
    }
  }

  Product.fromShopify(Map<String, dynamic> json) {
    try {
      var priceV2 = json['variants']['edges'][0]['node']['priceV2'];
      var compareAtPriceV2 =
          json['variants']['edges'][0]['node']['compareAtPriceV2'];
      var compareAtPrice =
          compareAtPriceV2 != null ? compareAtPriceV2['amount'] : null;
      var categories =
          json['collections'] != null ? json['collections']['edges'] : null;
      var defaultCategory = categories != null ? categories[0]['node'] : null;

      categoryId = json['categoryId'] ?? defaultCategory['id'];
      id = json['id'];
      sku = json['sku'];
      name = json['title'];
      description = json['description'];
      price = priceV2 != null ? priceV2['amount'] : null;
      regularPrice = compareAtPrice ?? price;
      onSale = compareAtPrice != null && compareAtPrice != price;
      inStock = json['availableForSale'];
      ratingCount = 0;
      averageRating = 0;

      List<String> imgs = [];

      if (json['images']['edges'] != null) {
        for (var item in json['images']['edges']) {
          imgs.add(item['node']['src']);
        }
      }

      images = imgs;
      imageFeature = images[0];

      List<ProductAttribute> attrs = [];

      if (json['options'] != null) {
        for (var item in json['options']) {
          attrs.add(ProductAttribute.fromShopify(item));
        }
      }

      attributes = attrs;
      List<ProductVariation> variants = [];

      if (json['variants']['edges'] != null) {
        for (var item in json['variants']['edges']) {
          variants.add(ProductVariation.fromShopifyJson(item['node']));
        }
      }

      variations = variants;
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  /// Show the product list
  static showList(
      {cateId, cateName, context, List<Product> products, config, noRouting}) {
    try {
      var categoryId = cateId ?? config['category'].toString();
      var categoryName = cateName ?? config['name'];
      final product = Provider.of<ProductModel>(context, listen: false);

      if (kLayoutWeb) {
        LayoutWebCustom.changeStateMenu(false);
      }
      // for caching current products list
      if (products != null && products.isNotEmpty) {
        product.setProductsList(products);
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductsPage(products: products, categoryId: categoryId)));
      }
      product.updateTagId(tagId: config != null ? config['tag'] : null);

      // for fetching beforehand
      if (categoryId != null) {
        product.fetchProductsByCategory(
            categoryId: categoryId, categoryName: categoryName);
      }

      product.setProductsList(List<Product>()); //clear old products
      product.getProductsList(
        categoryId: categoryId,
        page: 1,
        lang: Provider.of<AppModel>(context, listen: false).locale,
      );

      if (noRouting == null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductsPage(
                    products: products ?? [], categoryId: categoryId)));
      } else {
        return ProductsPage(products: products ?? [], categoryId: categoryId);
      }
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "name": name,
      "description": description,
      "permalink": permalink,
      "price": price,
      "regularPrice": regularPrice,
      "salePrice": salePrice,
      "onSale": onSale,
      "inStock": inStock,
      "averageRating": averageRating,
      "ratingCount": ratingCount,
      "images": images,
      "imageFeature": imageFeature,
      "attributes": attributes,
      "categoryId": categoryId,
      "multiCurrencies": multiCurrencies,
      "stock_quantity": stockQuantity
    };
  }

  Product.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'].toString();
      sku = json['sku'];
      name = json['name'];
      description = json['description'];
      permalink = json['permalink'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      salePrice = json['salePrice'];
      onSale = json['onSale'];
      inStock = json['inStock'];
      averageRating = json['averageRating'];
      ratingCount = json['ratingCount'];
      List<String> imgs = [];

      if (json['images'] != null) {
        for (var item in json['images']) {
          imgs.add(item);
        }
      }
      images = imgs;
      imageFeature = json['imageFeature'];
      List<ProductAttribute> attrs = [];

      if (json['attributes'] != null) {
        for (var item in json['attributes']) {
          attrs.add(ProductAttribute.fromLocalJson(item));
        }
      }

      attributes = attrs;
      categoryId = "${json['categoryId']}";
      multiCurrencies = json['multiCurrencies'];
      stockQuantity = json['stock_quantity'];
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  @override
  String toString() => 'Product { id: $id name: $name }';

  /// Get product ID from mix String productID-ProductVariantID
  static String cleanProductID(productString) {
    if (productString.contains("-")) {
      return productString.split("-")[0].toString();
    } else {
      return productString.toString();
    }
  }
}

class BookingDate1 {
  int value;
  String unit;

  BookingDate1.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
  }
}
